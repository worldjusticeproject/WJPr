#' Save a WJP Chart at Its Exact Size
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_save()` writes a chart to an SVG, PNG, or PDF file at an exact
#' physical size. SVG files can have their text converted to outlines
#' (`outline_text = TRUE`), so the figure looks the same on machines without
#' the fonts, and PNG files are rendered at `png_dpi` dots per inch.
#'
#' @details
#' The output format follows the extension of `file`:
#' \itemize{
#'   \item `.svg`: written with \pkg{svglite}. With `outline_text = TRUE`,
#'     every `<text>` element is replaced by a `<path>` with the outlines of
#'     its glyphs, read from the font files with \pkg{systemfonts} and
#'     shaped with \pkg{textshaping}. Requires the packages svglite, xml2,
#'     systemfonts, and textshaping.
#'   \item `.png`: written with [ragg::agg_png()] when \pkg{ragg} is
#'     installed (otherwise with [grDevices::png()]) at `png_dpi`.
#'   \item `.pdf`: written with [grDevices::cairo_pdf()].
#' }
#'
#' Fonts: text outlines and the SVG and PNG devices read fonts through
#' \pkg{systemfonts}. Register the WJP fonts with
#' `wjp_fonts(engine = "systemfonts")` for exact results. When \pkg{showtext}
#' is active and the families of the chart are only known to showtext (the
#' default `wjp_fonts()`), the chart is drawn with showtext, which already
#' renders text as polygons; `outline_text` then has no further effect.
#'
#' Size: when `width` or `height` is `NULL`, the size of the chart is used if
#' it is definite, i.e. when its panels have a fixed size (charts drawn with a
#' [wjp_layout()], or plots with the `panel.widths` and `panel.heights` theme
#' elements).
#'
#' @param plot A ggplot object.
#' @param file Path of the output file (`.svg`, `.png`, or `.pdf`).
#' @param width,height Size of the figure in `units`. Default is `NULL` (the
#'   definite size of the chart).
#' @param units Units of `width` and `height`: `"in"` (default), `"cm"`,
#'   `"mm"`, `"pt"` (1/72 inch), or `"px"` (pixels at `png_dpi`).
#' @param outline_text Logical. Convert the text of SVG files to outlines.
#'   Default is `TRUE`.
#' @param png_dpi Numeric. Resolution of PNG files. Default is `300`.
#' @param bg Background color. Default is `"white"`.
#'
#' @return Invisibly, a list with the `file`, its `width` and `height` in
#'   inches and, for outlined SVG files, a data frame `text` with one row per
#'   outlined text (`text`, `family`, `size`, `weight`, `italic`, `font_file`,
#'   `doubtful`; `doubtful` flags texts whose width in the SVG differs by more
#'   than 3% from the font, a sign that they were measured with another font).
#'
#' @seealso [wjp_layout()] for charts with a definite size.
#' @export
#'
#' @examples
#' \dontrun{
#' wjp_fonts(engine = "systemfonts")
#' p <- wjp_bars(
#'   data.frame(country = c("A", "B"), value = c(40, 60)),
#'   target = "value", grouping = "country"
#' )
#' wjp_save(p, "bars.svg", width = 6, height = 4)
#' wjp_save(p, "bars.png", width = 6, height = 4, png_dpi = 300)
#' }
#'
wjp_save <- function(plot,
                     file,
                     width        = NULL,
                     height       = NULL,
                     units        = c("in", "cm", "mm", "pt", "px"),
                     outline_text = TRUE,
                     png_dpi      = 300,
                     bg           = "white") {
  units <- match.arg(units)
  if (!inherits(plot, "ggplot")) {
    stop("`plot` must be a ggplot object.", call. = FALSE)
  }
  if (!is.character(file) || length(file) != 1 || is.na(file)) {
    stop("`file` must be a single path.", call. = FALSE)
  }
  ext <- tolower(tools::file_ext(file))
  if (!ext %in% c("svg", "png", "pdf")) {
    stop("`file` must end in .svg, .png, or .pdf.", call. = FALSE)
  }
  if (length(png_dpi) != 1 || !is.numeric(png_dpi) || !is.finite(png_dpi) || png_dpi <= 0) {
    stop("`png_dpi` must be a single positive number.", call. = FALSE)
  }
  if (length(outline_text) != 1 || !is.logical(outline_text) || is.na(outline_text)) {
    stop("`outline_text` must be TRUE or FALSE.", call. = FALSE)
  }

  to_in <- c("in" = 1, cm = 1 / 2.54, mm = 1 / 25.4, pt = 1 / 72, px = 1 / png_dpi)[[units]]
  if (is.null(width) || is.null(height)) {
    size <- wjp_plot_size(plot)
    if (is.null(size)) {
      stop("`width` and `height` are required: the chart has no definite size ",
           "(draw it with a `layout` or give the size).", call. = FALSE)
    }
    w_in <- if (is.null(width)) size[["width"]] else width * to_in
    h_in <- if (is.null(height)) size[["height"]] else height * to_in
  } else {
    w_in <- width * to_in
    h_in <- height * to_in
  }
  if (!is.numeric(w_in) || !is.numeric(h_in) || w_in <= 0 || h_in <= 0) {
    stop("`width` and `height` must be positive numbers.", call. = FALSE)
  }

  # Draw with showtext only when the chart families are unknown to systemfonts
  showtext_on <- wjp_showtext_active()
  families <- wjp_plot_families(plot)
  use_showtext <- showtext_on && !all(vapply(families, wjp_systemfonts_has, logical(1)))
  if (showtext_on && !use_showtext) {
    showtext::showtext_auto(FALSE)
    on.exit(showtext::showtext_auto(TRUE), add = TRUE)
  }

  dir.create(dirname(normalizePath(file, mustWork = FALSE)), recursive = TRUE,
             showWarnings = FALSE)
  draw <- function() {
    print(plot)
    invisible(NULL)
  }
  text_log <- NULL

  if (ext == "svg") {
    if (!requireNamespace("svglite", quietly = TRUE)) {
      stop("Saving SVG files requires the svglite package.", call. = FALSE)
    }
    tmp <- tempfile(fileext = ".svg")
    on.exit(unlink(tmp), add = TRUE)
    svglite::svglite(tmp, width = w_in, height = h_in, bg = bg)
    tryCatch(draw(), finally = grDevices::dev.off())
    if (outline_text && !use_showtext) {
      for (pkg in c("xml2", "systemfonts", "textshaping")) {
        if (!requireNamespace(pkg, quietly = TRUE)) {
          stop("`outline_text = TRUE` requires the ", pkg, " package.", call. = FALSE)
        }
      }
      text_log <- wjp_outline_svg(tmp)
    }
    if (!file.copy(tmp, file, overwrite = TRUE)) {
      stop("Could not write ", file, ".", call. = FALSE)
    }
  } else if (ext == "png") {
    # Lay the chart out with the text metrics of the SVG device, so the PNG is
    # the same drawing as the SVG at another resolution
    frozen <- if (!use_showtext) wjp_frozen_gtable(plot, w_in, h_in) else NULL
    if (requireNamespace("ragg", quietly = TRUE) && !use_showtext) {
      ragg::agg_png(file, width = w_in, height = h_in, units = "in", res = png_dpi,
                    background = bg)
    } else {
      grDevices::png(file, width = w_in, height = h_in, units = "in", res = png_dpi,
                     bg = bg)
    }
    if (is.null(frozen)) {
      tryCatch(draw(), finally = grDevices::dev.off())
    } else {
      tryCatch({
        grid::grid.newpage()
        grid::grid.draw(frozen)
      }, finally = grDevices::dev.off())
    }
  } else {
    grDevices::cairo_pdf(file, width = w_in, height = h_in, bg = bg)
    tryCatch(draw(), finally = grDevices::dev.off())
  }

  invisible(list(file = file, width = w_in, height = h_in, text = text_log))
}


#' Gtable of a plot laid out on an SVG device, with absolute sizes
#'
#' Text-dependent row and column sizes (axes, legends, titles) are measured
#' with svglite and frozen in points, so other devices reproduce the SVG
#' layout. Returns `NULL` when svglite is not installed.
#'
#' @noRd
wjp_frozen_gtable <- function(plot, w_in, h_in) {
  if (!requireNamespace("svglite", quietly = TRUE)) {
    return(NULL)
  }
  tmp <- tempfile(fileext = ".svg")
  old <- grDevices::dev.cur()
  svglite::svglite(tmp, width = w_in, height = h_in)
  dev <- grDevices::dev.cur()
  on.exit({
    grDevices::dev.off(dev)
    if (old > 1) grDevices::dev.set(old)
    unlink(tmp)
  }, add = TRUE)
  gt <- ggplot2::ggplotGrob(plot)
  freeze <- function(u, convert) {
    rel <- grid::unitType(u) == "null"
    vals <- convert(u, "bigpts", valueOnly = TRUE)
    out <- grid::unit(vals, "bigpts")
    if (any(rel)) {
      # relative ("null") tracks keep sharing the remaining space
      parts <- lapply(seq_along(u), function(i) if (rel[i]) u[i] else out[i])
      out <- do.call(grid::unit.c, parts)
    }
    out
  }
  gt$widths <- freeze(gt$widths, grid::convertWidth)
  gt$heights <- freeze(gt$heights, grid::convertHeight)
  gt
}

#' Is showtext enabled for new pages?
#' @noRd
wjp_showtext_active <- function() {
  hooks <- getHook("grid.newpage")
  length(hooks) > 0 && any(vapply(hooks, inherits, logical(1), "showtext_hook"))
}

#' Font families used by a ggplot (layers and theme)
#' @noRd
wjp_plot_families <- function(plot) {
  fams <- wjp_font_family()
  for (l in plot$layers) {
    for (src in list(l$aes_params, l$geom_params)) {
      if (!is.null(src$family)) fams <- c(fams, src$family)
    }
  }
  th <- plot$theme
  for (nm in names(th)) {
    el <- th[[nm]]
    fam <- tryCatch(el$family, error = function(e) NULL)
    if (is.character(fam)) fams <- c(fams, fam)
  }
  fams <- unique(fams[!is.na(fams) & nzchar(fams)])
  fams
}

#' Definite size of a plot, in inches
#'
#' The size is definite when the gtable of the plot has no relative ("null")
#' widths or heights, which is the case when the panel sizes are fixed.
#'
#' @return Named numeric `c(width, height)` or `NULL`.
#' @noRd
wjp_plot_size <- function(plot) {
  size <- tryCatch({
    tmp <- tempfile(fileext = ".png")
    if (requireNamespace("ragg", quietly = TRUE)) {
      ragg::agg_png(tmp, width = 7, height = 7, units = "in", res = 72)
    } else {
      grDevices::png(tmp, width = 7, height = 7, units = "in", res = 72)
    }
    on.exit({
      grDevices::dev.off()
      unlink(tmp)
    }, add = TRUE)
    gt <- ggplot2::ggplotGrob(plot)
    # Only top-level relative units make the size indefinite: "null" units
    # nested in sums (empty axes) evaluate to zero
    rel <- function(u) any(grid::unitType(u) == "null")
    if (rel(gt$widths) || rel(gt$heights)) {
      NULL
    } else {
      c(width  = sum(grid::convertWidth(gt$widths, "in", valueOnly = TRUE)),
        height = sum(grid::convertHeight(gt$heights, "in", valueOnly = TRUE)))
    }
  }, error = function(e) NULL)
  if (is.null(size)) {
    size <- attr(plot, "wjp_size")
  }
  size
}


# ---------------------------------------------------------------------------
# Text outlines for SVG files
# ---------------------------------------------------------------------------

.wjp_glyph_cache <- new.env(parent = emptyenv())
.WJP_REF_SIZE <- 100

#' Forget cached font files and glyphs (after fonts are registered again)
#' @noRd
.wjp_glyph_cache_reset <- function() {
  rm(list = ls(.wjp_glyph_cache, all.names = TRUE), envir = .wjp_glyph_cache)
  invisible(NULL)
}

#' Font file used for a family, weight and style
#' @noRd
wjp_font_file <- function(family, weight = 400, italic = FALSE) {
  key <- paste("file", family, weight, italic)
  hit <- .wjp_glyph_cache[[key]]
  if (!is.null(hit)) {
    return(hit)
  }
  wt <- if (is.numeric(weight)) weight else switch(weight, bold = 700, bolder = 700, 400)
  m <- if (exists("match_fonts", envir = asNamespace("systemfonts"), inherits = FALSE)) {
    systemfonts::match_fonts(family, italic = italic, weight = wt)
  } else {
    systemfonts::match_font(family, italic = italic, bold = wt >= 600)
  }
  out <- list(path = m$path[1], index = if (is.null(m$index)) 0L else m$index[1])
  .wjp_glyph_cache[[key]] <- out
  out
}

#' Glyph outlines of a font file at the reference size, cached
#' @noRd
wjp_glyph_contours <- function(font, glyph) {
  key <- paste(font$path, font$index, glyph)
  hit <- .wjp_glyph_cache[[key]]
  if (!is.null(hit)) {
    return(hit)
  }
  g <- systemfonts::glyph_outline(glyph, path = font$path, index = font$index,
                                  size = .WJP_REF_SIZE, tolerance = 0.2)
  out <- if (nrow(g) == 0) list() else lapply(split(g, g$contour), function(d) cbind(d$x, d$y))
  .wjp_glyph_cache[[key]] <- out
  out
}

#' Shape a string with a font file at the reference size
#' @noRd
wjp_shape <- function(string, font) {
  s <- textshaping::shape_text(string, path = font$path, index = font$index,
                               size = .WJP_REF_SIZE, res = 72)
  list(index = s$shape$index, x = s$shape$x_offset, width = s$metrics$width[1],
       font_path = s$shape$font_path)
}

#' Format numbers for SVG path data
#' @noRd
wjp_fmt <- function(v) {
  out <- sprintf("%.2f", v)
  out <- sub("\\.?0+$", "", out)
  out[out == "-0"] <- "0"
  out
}

#' SVG path data of a string with its baseline at (x, y)
#' @noRd
wjp_text_d <- function(string, x, y, size, font, anchor = "start", stretch = 1) {
  sh <- wjp_shape(string, font)
  k <- size / .WJP_REF_SIZE
  w <- sh$width * k * stretch
  x0 <- x - switch(anchor, middle = w / 2, end = w, 0)
  parts <- character()
  for (i in seq_along(sh$index)) {
    contours <- wjp_glyph_contours(font, sh$index[i])
    if (length(contours) == 0) next
    gx <- x0 + sh$x[i] * k * stretch
    for (m in contours) {
      px <- round(gx + m[, 1] * k * stretch, 2)
      py <- round(y - m[, 2] * k, 2)
      parts <- c(parts, paste0("M", wjp_fmt(px[1]), " ", wjp_fmt(py[1]),
                               if (length(px) > 1) {
                                 paste0("l", paste(wjp_fmt(diff(px)), wjp_fmt(diff(py)),
                                                   collapse = " "))
                               }, "z"))
    }
  }
  list(d = paste(parts, collapse = ""), width = sh$width * k)
}

#' A CSS property of an SVG node, inherited from its ancestors
#' @noRd
wjp_svg_prop <- function(node, prop) {
  css <- function(style) {
    if (is.na(style)) return(NA_character_)
    m <- regmatches(style, regexec(paste0("(?:^|;)\\s*", prop, "\\s*:\\s*([^;]+)"),
                                   style, perl = TRUE))[[1]]
    if (length(m) == 2) trimws(m[2]) else NA_character_
  }
  for (nd in c(list(node), as.list(xml2::xml_parents(node)))) {
    v <- css(xml2::xml_attr(nd, "style"))
    if (is.na(v)) v <- xml2::xml_attr(nd, prop)
    if (!is.na(v)) return(v)
  }
  NA_character_
}

#' Replace every <text> of an SVG file with the outlines of its glyphs
#'
#' @param path_in,path_out SVG files.
#' @param max_stretch Largest relative difference between the width written by
#'   the device (`textLength`) and the width of the font that is applied as a
#'   horizontal stretch; larger differences mark the text as doubtful.
#' @return Invisibly, a data frame with one row per text.
#' @noRd
wjp_outline_svg <- function(path_in, path_out = path_in, max_stretch = 0.03) {
  doc <- xml2::read_xml(path_in)
  texts <- xml2::xml_find_all(doc, "//*[local-name()='text']")
  log <- vector("list", length(texts))
  num <- function(v, default) if (is.na(v)) default else as.numeric(sub("(px|pt)$", "", v))
  for (i in seq_along(texts)) {
    node <- texts[[i]]
    if (length(xml2::xml_find_all(node, ".//*[local-name()='tspan' or local-name()='textPath']")) > 0) {
      stop("wjp_save(): <tspan> and <textPath> are not supported.", call. = FALSE)
    }
    string <- xml2::xml_text(node)
    visible <- grepl("[^\\s\\p{Z}\\p{Cc}\\p{Cf}]", string, perl = TRUE)
    if (!visible) {
      xml2::xml_remove(node)
      next
    }
    if (grepl("[\n\r\v\f]", string)) {
      stop("wjp_save(): text with a line break cannot be outlined: ",
           encodeString(string, quote = "\""), call. = FALSE)
    }
    x <- num(xml2::xml_attr(node, "x"), 0)
    y <- num(xml2::xml_attr(node, "y"), 0)
    size <- num(wjp_svg_prop(node, "font-size"), 16)
    weight <- wjp_svg_prop(node, "font-weight")
    weight <- if (is.na(weight)) 400 else if (grepl("^[0-9]+$", weight)) as.numeric(weight) else weight
    italic <- identical(wjp_svg_prop(node, "font-style"), "italic")
    anchor <- wjp_svg_prop(node, "text-anchor")
    if (is.na(anchor)) anchor <- "start"
    fill <- wjp_svg_prop(node, "fill")
    if (is.na(fill)) fill <- "#000000"
    opacity <- wjp_svg_prop(node, "fill-opacity")
    family <- wjp_svg_prop(node, "font-family")
    family <- if (is.na(family)) "" else gsub("^[\"']|[\"']$", "", trimws(strsplit(family, ",")[[1]][1]))
    font <- wjp_font_file(family, weight, italic)
    if (is.na(font$path) || !file.exists(font$path)) {
      stop("wjp_save(): no font file found for family \"", family, "\".", call. = FALSE)
    }
    w_font <- wjp_shape(string, font)$width * size / .WJP_REF_SIZE
    tl <- xml2::xml_attr(node, "textLength")
    ratio <- if (!is.na(tl) && w_font > 0) num(tl, NA_real_) / w_font else NA_real_
    stretch <- if (!is.na(ratio) && abs(ratio - 1) <= max_stretch) ratio else 1
    out <- wjp_text_d(string, x, y, size, font, anchor, stretch)
    log[[i]] <- data.frame(
      text = string, family = family, size = size, weight = as.character(weight),
      italic = italic, font_file = basename(font$path), textlength_ratio = ratio,
      doubtful = !is.na(ratio) && abs(ratio - 1) > max_stretch,
      stringsAsFactors = FALSE
    )
    if (!nzchar(out$d)) {
      xml2::xml_remove(node)
      next
    }
    p <- xml2::xml_add_sibling(node, "path", .where = "before")
    xml2::xml_set_attr(p, "d", out$d)
    xml2::xml_set_attr(p, "style", paste0("fill:", fill, ";stroke:none",
                                          if (!is.na(opacity)) paste0(";fill-opacity:", opacity)))
    tr <- xml2::xml_attr(node, "transform")
    if (!is.na(tr)) xml2::xml_set_attr(p, "transform", tr)
    xml2::xml_remove(node)
  }
  xml2::write_xml(doc, path_out, options = c("format", "no_declaration"))
  out <- do.call(rbind, log[!vapply(log, is.null, logical(1))])
  if (is.null(out)) {
    out <- data.frame(text = character(), family = character(), size = numeric(),
                      weight = character(), italic = logical(), font_file = character(),
                      textlength_ratio = numeric(), doubtful = logical())
  }
  invisible(out)
}
