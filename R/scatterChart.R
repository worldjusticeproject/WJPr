#' Plot a Scatter Chart following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_scatter()` takes a data frame with one row per point and returns a
#' ggplot object with an x-y scatter chart following WJP style guidelines,
#' optionally split into side-by-side panels (`facet`). A subset of the points
#' can be highlighted and labeled, points with small samples can be drawn
#' hollow, and a linear trend line can be added to each panel.
#'
#' @details
#' Points with a missing `x` or `y` are not drawn. Highlighted points (`highlight`)
#' use the first color of `colors` and the rest use the second; when
#' `highlight` is `NULL` every point is highlighted. Labels (`labels`) are drawn
#' for the highlighted points only. With `repel = TRUE` and the \pkg{ggrepel}
#' package installed, labels are moved away from the points and from each
#' other with a fixed `seed`, so the layout is reproducible for a given figure
#' size; otherwise they are drawn just above their points.
#'
#' Points flagged by the logical column `hollow` (for example, estimates based
#' on fewer than 30 observations) are drawn as open circles.
#'
#' The trend (`trend = "lm"`) is an ordinary least-squares line fitted to all
#' the drawn points of each panel, as [ggplot2::geom_smooth()] with
#' `method = "lm"` and no confidence band.
#'
#' Sizes are given in points: `point_size` is the diameter of a point and
#' `point_stroke` the width of the outline of hollow points.
#'
#' @param data Data frame with one row per point.
#' @param x,y Strings. Column names of the horizontal and vertical values.
#' @param labels String. Column name of the point labels. Default is `NULL`
#'   (no labels).
#' @param facet String. Column name of the variable that splits the chart into
#'   panels, in order of its factor levels or first appearance. Default is
#'   `NULL` (one panel).
#' @param highlight Character vector of `labels` values to highlight. Default
#'   is `NULL` (all points highlighted).
#' @param hollow String. Column name of a logical variable; `TRUE` draws the
#'   point as an open circle. Default is `NULL`.
#' @param colors Character vector of length 2: color of the highlighted points
#'   and labels, and color of the other points. Default is the WJP violet and a
#'   light gray.
#' @param point_size Numeric. Diameter of the points, in points. Default is `7`.
#' @param trend String. `"none"` (default) or `"lm"` (a dashed linear trend per
#'   panel).
#' @param repel Logical. Repel labels with \pkg{ggrepel} when installed.
#'   Default is `TRUE`.
#' @param seed Integer. Seed of the label repulsion. Default is `1`.
#' @param repel_args Named list of further arguments for
#'   [ggrepel::geom_text_repel()] (e.g., `box.padding`, `force`). The search
#'   runs up to `max.iter` iterations (`max.time = 30` seconds), so the layout
#'   does not depend on the speed of the machine.
#' @param point_stroke Numeric. Outline width of hollow points, in points.
#'   Default is `1.3`.
#' @param label_size Numeric. Size of the point labels, in points. Default is `9.5`.
#' @param label_fontface String. Font face of the point labels. Default is
#'   `"plain"`. Weight faces such as `"semibold"` are accepted (see [wjp_fonts()]).
#' @param label_colour String. Color of the point labels. Default is `NULL`
#'   (the highlight color).
#' @param xlim,ylim Numeric vectors of length 2 with the axis limits. Default
#'   is `NULL` (range of the data).
#' @param x_breaks,y_breaks Numeric vectors with the axis breaks. Default is
#'   `NULL` (automatic).
#' @param x_labels,y_labels Labels of the axis breaks: a character vector or a
#'   function (e.g., `function(x) paste0(x, "%")`). Default is `NULL`
#'   (automatic).
#' @param x_title,y_title Strings. Axis titles. Default is `NULL` (none).
#' @param facet_nrow Integer. Number of rows of panels. Default is `1`.
#' @param strip_size Numeric. Size of the panel titles, in points. Default is `11`.
#' @param strip_fontface String. Font face of the panel titles. Default is
#'   `"bold.italic"`.
#' @param strip_colour String. Color of the panel titles. Default is `NULL`
#'   (the highlight color).
#' @param trend_color String. Color of the trend line. Default is `"#9aa0a6"`.
#' @param trend_width Numeric. Width of the trend line, in points. Default is `0.75`.
#' @param grid_color String. Color of the grid lines. Default is `"#eeeeee"`;
#'   `NA` removes them.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Prevalence and seriousness of problems by area (fictional data)
#' problems <- data.frame(
#'   area     = rep(c("Rural", "Urban"), each = 6),
#'   category = rep(c("Consumer", "Housing", "Family", "Employment",
#'                    "Land", "Education"), 2),
#'   prevalence  = c(41, 9, 21, 18, 20, 9, 39, 10, 17, 19, 18, 9),
#'   seriousness = c(4.6, 4.3, 5.5, 6.0, 4.5, 5.6, 4.8, 4.9, 5.6, 6.4, 5.2, 5.9),
#'   n           = c(215, 49, 99, 96, 105, 25, 480, 126, 210, 230, 211, 104)
#' )
#' problems$small <- problems$n < 30
#'
#' wjp_scatter(
#'   problems,
#'   x         = "prevalence",
#'   y         = "seriousness",
#'   labels    = "category",
#'   facet     = "area",
#'   highlight = c("Consumer", "Housing", "Family"),
#'   hollow    = "small",
#'   trend     = "lm",
#'   xlim      = c(0, 50),
#'   ylim      = c(4, 8),
#'   x_labels  = function(x) paste0(x, "%"),
#'   x_title   = "Prevalence",
#'   y_title   = "Mean seriousness (0-10)"
#' )
#'
wjp_scatter <- function(
    data,
    x,
    y,
    labels         = NULL,
    facet          = NULL,
    highlight      = NULL,
    hollow         = NULL,
    colors         = c("#482d8b", "#c4c4c4"),
    point_size     = 7,
    trend          = c("none", "lm"),
    repel          = TRUE,
    seed           = 1,
    repel_args     = list(),
    point_stroke   = 1.3,
    label_size     = 9.5,
    label_fontface = "plain",
    label_colour   = NULL,
    xlim           = NULL,
    ylim           = NULL,
    x_breaks       = NULL,
    y_breaks       = NULL,
    x_labels       = NULL,
    y_labels       = NULL,
    x_title        = NULL,
    y_title        = NULL,
    facet_nrow     = 1,
    strip_size     = 11,
    strip_fontface = "bold.italic",
    strip_colour   = NULL,
    trend_color    = "#9aa0a6",
    trend_width    = 0.75,
    grid_color     = "#eeeeee",
    ptheme         = WJP_theme()
) {
  trend <- match.arg(trend)
  if (!is.data.frame(data) || nrow(data) == 0) {
    stop("`data` must be a non-empty data frame.", call. = FALSE)
  }
  column <- function(name, arg) {
    if (!is.character(name) || length(name) != 1 || is.na(name) || !name %in% names(data)) {
      stop("`", arg, "` must name an existing column in `data`.", call. = FALSE)
    }
    data[[name]]
  }
  x_val <- column(x, "x")
  y_val <- column(y, "y")
  if (!is.numeric(x_val) || !is.numeric(y_val)) {
    stop("`x` and `y` must name numeric columns.", call. = FALSE)
  }
  if (length(colors) != 2) {
    stop("`colors` must contain two colors (highlighted, other).", call. = FALSE)
  }
  if (length(repel) != 1 || !is.logical(repel) || is.na(repel)) {
    stop("`repel` must be TRUE or FALSE.", call. = FALSE)
  }
  wjp_check_number(point_size, "point_size", 0, lower_open = TRUE)
  wjp_check_number(point_stroke, "point_stroke", 0)
  wjp_check_number(label_size, "label_size", 0, lower_open = TRUE)
  wjp_check_number(strip_size, "strip_size", 0, lower_open = TRUE)
  wjp_check_number(trend_width, "trend_width", 0)
  wjp_check_number(seed, "seed")
  wjp_check_number(facet_nrow, "facet_nrow", 1)
  for (nm in c("xlim", "ylim")) {
    v <- get(nm)
    if (!is.null(v) && (!is.numeric(v) || length(v) != 2)) {
      stop("`", nm, "` must be a numeric vector of length 2.", call. = FALSE)
    }
  }
  if (is.null(label_colour)) label_colour <- colors[1]
  if (is.null(strip_colour)) strip_colour <- colors[1]

  d <- data.frame(.x = x_val, .y = y_val, stringsAsFactors = FALSE)
  d$.label <- if (is.null(labels)) NA_character_ else as.character(column(labels, "labels"))
  if (!is.null(facet)) {
    f <- column(facet, "facet")
    lv <- if (is.factor(f)) levels(droplevels(f)) else unique(as.character(f[!is.na(f)]))
    d$panel <- factor(as.character(f), levels = lv)
  }
  if (!is.null(hollow)) {
    h <- column(hollow, "hollow")
    if (!is.logical(h)) {
      stop("`hollow` must name a logical column.", call. = FALSE)
    }
    d$.hollow <- !is.na(h) & h
  } else {
    d$.hollow <- FALSE
  }
  if (!is.null(highlight)) {
    if (!is.character(highlight)) {
      stop("`highlight` must be a character vector of `labels` values.", call. = FALSE)
    }
    if (is.null(labels)) {
      stop("`highlight` requires `labels`.", call. = FALSE)
    }
    d$.highlight <- d$.label %in% highlight
  } else {
    d$.highlight <- TRUE
  }
  d <- d[is.finite(d$.x) & is.finite(d$.y), , drop = FALSE]
  if (nrow(d) == 0) {
    stop("No point has finite `x` and `y` values.", call. = FALSE)
  }
  d$.colour <- ifelse(d$.highlight, colors[1], colors[2])
  d$.shape <- ifelse(d$.hollow, 1, 16)

  # Point size: diameter (pt) of the circle; the outline of hollow points is
  # centered on it. ggplot2: fontsize = size * .pt + stroke * .stroke / 2,
  # radius = 0.375 * fontsize, outline width = stroke * .stroke / 2 (1/96 in).
  stroke_gg <- point_stroke / (0.75 * ggplot2::.stroke / 2)
  size_gg <- max(0, (point_size / 0.75 - point_stroke / 0.75) / ggplot2::.pt)

  plt <- ggplot2::ggplot(d, ggplot2::aes(x = .data[[".x"]], y = .data[[".y"]]))
  if (trend == "lm") {
    plt <- plt + ggplot2::geom_smooth(
      method = "lm", formula = y ~ x, se = FALSE, colour = trend_color,
      linewidth = wjp_pt_line(trend_width), linetype = "dashed", na.rm = TRUE
    )
  }
  plt <- plt + ggplot2::geom_point(
    ggplot2::aes(colour = I(.data[[".colour"]]), shape = I(.data[[".shape"]])),
    size = size_gg, stroke = stroke_gg, na.rm = TRUE
  )

  lab <- d[d$.highlight & !is.na(d$.label) & nzchar(d$.label), , drop = FALSE]
  if (!is.null(labels) && nrow(lab) > 0) {
    lface <- wjp_face(label_fontface)
    if (isTRUE(repel) && requireNamespace("ggrepel", quietly = TRUE)) {
      if (!is.list(repel_args)) {
        stop("`repel_args` must be a named list.", call. = FALSE)
      }
      rargs <- utils::modifyList(list(
        data = lab, mapping = ggplot2::aes(label = .data[[".label"]]),
        family = lface$family, fontface = lface$fontface,
        size = wjp_pt_text(label_size), colour = label_colour,
        seed = seed, min.segment.length = 0.3, max.time = 30, na.rm = TRUE
      ), repel_args)
      plt <- plt + do.call(ggrepel::geom_text_repel, rargs)
    } else {
      # Above the point: half the point plus a small gap
      plt <- plt + wjp_offset_text(
        data = lab, mapping = ggplot2::aes(label = .data[[".label"]]),
        offset = point_size / 2 + 2, side = "top",
        family = lface$family, fontface = lface$fontface,
        size = wjp_pt_text(label_size), colour = label_colour
      )
    }
  }

  scale_args <- function(limits, breaks, labs) {
    out <- list(limits = limits, oob = scales::oob_keep)
    if (!is.null(breaks)) out$breaks <- breaks
    if (!is.null(labs)) out$labels <- labs
    out
  }
  plt <- plt +
    do.call(ggplot2::scale_x_continuous, scale_args(xlim, x_breaks, x_labels)) +
    do.call(ggplot2::scale_y_continuous, scale_args(ylim, y_breaks, y_labels)) +
    ggplot2::labs(x = x_title, y = y_title)

  if (!is.null(facet)) {
    plt <- plt + ggplot2::facet_wrap(ggplot2::vars(!!as.name("panel")), nrow = facet_nrow)
  }

  sface <- wjp_face(strip_fontface)
  grid_el <- if (is.na(grid_color)) {
    ggplot2::element_blank()
  } else {
    ggplot2::element_line(colour = grid_color, linetype = "solid",
                          linewidth = wjp_pt_line(0.6))
  }
  plt <- plt +
    ptheme +
    ggplot2::theme(
      panel.grid.major  = grid_el,
      panel.grid.minor  = ggplot2::element_blank(),
      strip.background  = ggplot2::element_blank(),
      strip.text        = ggplot2::element_text(family = sface$family, face = sface$fontface,
                                                colour = strip_colour, size = strip_size),
      legend.position   = "none"
    )

  wjp_apply_ptheme(plt, ptheme)
}
