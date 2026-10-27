#' Texts and Marks Drawn by a Chart
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_drawn()` builds a chart and returns what it draws as a data frame, so
#' the printed texts, their positions, and their fonts can be checked without
#' rasterizing the figure (for example in tests, or to compare a chart with a
#' published table).
#'
#' @details
#' With `what = "text"`, one row per text: labels of the text layers
#' (`geom_text()`, `geom_label()`, ggtext and ggrepel layers), axis labels,
#' and facet strip labels. Rich-text markup (`<b>`, `<span>`, ...) is removed
#' from `label`. Text layers report their position in data coordinates and
#' their size in points.
#'
#' With `what = "marks"`, one row per mark of every non-text layer (bars,
#' points, segments, polygons), with the columns that the layer computes
#' (`x`, `y`, `xmin`, `xmax`, `ymin`, `ymax`, `fill`, `colour`, ...).
#'
#' @param plot A ggplot object.
#' @param what `"text"` (default) or `"marks"`.
#'
#' @return A data frame. For `what = "text"`: `source` (`"layer"`,
#'   `"axis-x"`, `"axis-y"`, or `"strip"`), `layer`, `PANEL`, `label`, `x`,
#'   `y`, `colour`, `size` (points), `family`, `fontface`, `hjust`, and
#'   `vjust`. For `what = "marks"`: `layer`, `geom`, and the computed columns.
#'
#' @export
#'
#' @examples
#' p <- wjp_bars(
#'   data.frame(country = c("A", "B"), value = c(40, 60), lab = c("40%", "60%")),
#'   target = "value", grouping = "country", labels = "lab"
#' )
#' wjp_drawn(p)
#'
wjp_drawn <- function(plot, what = c("text", "marks")) {
  what <- match.arg(what)
  if (!inherits(plot, "ggplot")) {
    stop("`plot` must be a ggplot object.", call. = FALSE)
  }
  b <- suppressWarnings(ggplot2::ggplot_build(plot))
  text_geoms <- c("GeomText", "GeomLabel", "GeomRichText", "GeomTextBox",
                  "GeomTextRepel", "GeomLabelRepel")
  is_text <- vapply(b$plot$layers, function(l) inherits(l$geom, text_geoms), logical(1))

  if (what == "marks") {
    out <- lapply(which(!is_text), function(i) {
      d <- as.data.frame(b$data[[i]])
      d <- d[, !vapply(d, is.list, logical(1)), drop = FALSE]
      if (nrow(d) == 0) return(NULL)
      cbind(data.frame(layer = i, geom = class(b$plot$layers[[i]]$geom)[1],
                       stringsAsFactors = FALSE), d)
    })
    out <- out[!vapply(out, is.null, logical(1))]
    if (length(out) == 0) {
      return(data.frame(layer = integer(), geom = character()))
    }
    cols <- unique(unlist(lapply(out, names)))
    out <- lapply(out, function(d) {
      for (cl in setdiff(cols, names(d))) d[[cl]] <- NA
      d[cols]
    })
    out <- do.call(rbind, out)
    rownames(out) <- NULL
    return(out)
  }

  strip_markup <- function(x) {
    x <- gsub("<br\\s*/?>", "\n", x, ignore.case = TRUE)
    trimws(gsub("<[^>]+>", "", x))
  }
  col_or <- function(d, nm, default = NA) if (nm %in% names(d)) d[[nm]] else rep(default, nrow(d))

  rows <- list()
  for (i in which(is_text)) {
    d <- as.data.frame(b$data[[i]])
    if (!"label" %in% names(d) || nrow(d) == 0) next
    l <- b$plot$layers[[i]]
    par <- function(nm) {
      v <- l$aes_params[[nm]]
      if (is.null(v)) v <- l$geom_params[[nm]]
      v
    }
    lab <- as.character(d$label)
    x <- suppressWarnings(as.numeric(col_or(d, "x")))
    y <- suppressWarnings(as.numeric(col_or(d, "y")))
    ok <- !is.na(lab) & nzchar(trimws(lab)) & is.finite(x) & is.finite(y)
    if (!any(ok)) next
    family <- if ("family" %in% names(d)) d$family else rep(if (is.null(par("family"))) "" else par("family"), nrow(d))
    face <- if ("fontface" %in% names(d)) d$fontface else rep(if (is.null(par("fontface"))) 1 else par("fontface"), nrow(d))
    rows[[length(rows) + 1]] <- data.frame(
      source   = "layer",
      layer    = i,
      PANEL    = as.character(col_or(d, "PANEL"))[ok],
      label    = strip_markup(lab[ok]),
      x        = x[ok],
      y        = y[ok],
      colour   = as.character(col_or(d, "colour"))[ok],
      size     = as.numeric(col_or(d, "size")[ok]) * ggplot2::.pt,
      family   = as.character(family)[ok],
      fontface = as.character(face)[ok],
      hjust    = as.character(col_or(d, "hjust", 0.5))[ok],
      vjust    = as.character(col_or(d, "vjust", 0.5))[ok],
      stringsAsFactors = FALSE
    )
  }

  # Axis labels of every panel
  for (k in seq_along(b$layout$panel_params)) {
    pp <- b$layout$panel_params[[k]]
    for (ax in c("x", "y")) {
      sc <- pp[[ax]]
      labs <- tryCatch(sc$get_labels(), error = function(e) NULL)
      pos <- tryCatch(sc$break_positions(), error = function(e) NULL)
      if (is.null(labs) || length(labs) == 0) next
      labs <- unname(vapply(labs, function(v) paste(as.character(v), collapse = " "), character(1)))
      if (is.null(pos) || length(pos) != length(labs)) pos <- rep(NA_real_, length(labs))
      ok <- !is.na(labs) & nzchar(trimws(labs))
      if (!any(ok)) next
      # panel parameters are already in screen orientation (also with coord_flip)
      side <- ax
      rows[[length(rows) + 1]] <- data.frame(
        source = paste0("axis-", side), layer = NA_integer_,
        PANEL = as.character(b$layout$layout$PANEL[k]),
        label = strip_markup(labs[ok]),
        x = if (side == "x") pos[ok] else NA_real_,
        y = if (side == "y") pos[ok] else NA_real_,
        colour = NA_character_, size = NA_real_, family = NA_character_,
        fontface = NA_character_, hjust = NA_character_, vjust = NA_character_,
        stringsAsFactors = FALSE
      )
    }
  }

  # Facet strip labels
  lay <- b$layout$layout
  fp <- b$layout$facet_params
  facet_vars <- unique(c(names(fp$facets), names(fp$rows), names(fp$cols)))
  facet_vars <- intersect(facet_vars, names(lay))
  if (length(facet_vars) > 0) {
    for (v in facet_vars) {
      vals <- as.character(lay[[v]])
      ok <- !is.na(vals) & nzchar(trimws(vals))
      if (!any(ok)) next
      rows[[length(rows) + 1]] <- data.frame(
        source = "strip", layer = NA_integer_, PANEL = as.character(lay$PANEL[ok]),
        label = vals[ok], x = NA_real_, y = NA_real_, colour = NA_character_,
        size = NA_real_, family = NA_character_, fontface = NA_character_,
        hjust = NA_character_, vjust = NA_character_, stringsAsFactors = FALSE
      )
    }
  }

  if (length(rows) == 0) {
    return(data.frame(source = character(), layer = integer(), PANEL = character(),
                      label = character(), x = numeric(), y = numeric(),
                      colour = character(), size = numeric(), family = character(),
                      fontface = character(), hjust = character(), vjust = character(),
                      stringsAsFactors = FALSE))
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}
