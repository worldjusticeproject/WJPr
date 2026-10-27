#' Plot a Heat Map following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_heatmap()` draws a matrix of colored cells (e.g., the share of people
#' with one problem who also had another), with the printed value of each cell
#' and the column labels at the top.
#'
#' @details
#' The function expects one row per cell: the column category in `x`, the row
#' category in `y`, and the variable that sets the color in `fill`. Columns
#' are drawn from left to right and rows from top to bottom in order of first
#' appearance, or in the order given by `x_order` and `y_order`.
#'
#' \strong{Colors.} A categorical `fill` (character, factor, or logical; e.g.,
#' bands such as `"Less than 25%"`) uses `cvec`, a vector of colors named by
#' the fill values (or given in the order of the levels); by default a
#' sequential ramp from `"#E5E8E8"` to `"#575796"` over the levels, in factor
#' order or order of first appearance. A numeric `fill` uses a sequential
#' scale between `cvec[1]` and `cvec[2]` (see [scale_fill_wjp_seq()]). Cells
#' with a missing fill are drawn in `na_fill`. With `label_color = "auto"`,
#' labels on dark cells are white.
#'
#' \strong{Labels.} The `labels` column is printed as given (e.g., `"62%"`,
#' `"N/A"`, or a dash on the diagonal). Without it, no value is printed.
#'
#' \strong{Size.} With `cell_size`, cells are squares of that many points and
#' the chart has a definite size for [wjp_save()]; otherwise the panel fills
#' the device.
#'
#' @param data Data frame containing the data to plot.
#' @param x String. Column name of the variable with the column categories.
#' @param y String. Column name of the variable with the row categories.
#' @param fill String. Column name of the variable that sets the cell color
#'   (categorical or numeric).
#' @param labels String. Column name of the variable with the printed values.
#'   Default is `NULL` (no labels).
#' @param x_order,y_order Character vectors with the order of the columns (left
#'   to right) and rows (top to bottom). Default is `NULL` (order of first
#'   appearance).
#' @param cvec Colors: named by the fill values (categorical fill) or the low
#'   and high ends of the scale (numeric fill). Default is `NULL` (sequential
#'   WJP report colors).
#' @param na_fill String. Color of cells with a missing fill. Default is `"#FFFFFF"`.
#' @param border_color String. Color of the cell borders. Default is `"#FFFFFF"`.
#' @param label_color Color of the labels: `"auto"` (default; white on dark
#'   cells) or one color.
#' @param x_position String. Position of the column labels: `"top"` (default)
#'   or `"bottom"`.
#' @param x_angle Numeric. Angle of the column labels, in degrees. Default is `40`.
#' @param legend_position Legend position: `"top"` (default), `"bottom"`,
#'   `"left"`, `"right"`, `c(x, y)` inside the panel, or `"none"`.
#' @param border_width Numeric. Width of the cell borders, in points. Default is `1.5`.
#' @param label_size Numeric. Size of the labels, in points. Default is `9.5`.
#' @param label_fontface String. Font face of the labels. Default is `"plain"`.
#' @param label_dark String. Color of the labels on light cells with
#'   `label_color = "auto"`. Default is `"#1A1A1A"`.
#' @param axis_text_size Numeric. Size of the row and column labels, in points.
#'   Default is `10`.
#' @param axis_text_colour String. Color of the row and column labels.
#'   Default is `"#1A1A1A"`.
#' @param x_title,y_title Strings. Titles of the columns and rows. Default is
#'   `NULL` (none).
#' @param title_size Numeric. Size of the titles, in points. Default is `11`.
#' @param title_fontface String. Font face of the titles. Default is `"bold.italic"`.
#' @param title_colour String. Color of the titles. Default is `"#575796"`.
#' @param legend_text_size Numeric. Size of the legend text, in points. Default is `10`.
#' @param legend_key_size Numeric. Size of the legend keys, in points.
#'   Default is `NULL`.
#' @param legend_fontface String. Font face of the legend text. Default is `"plain"`.
#' @param legend_justification String. Horizontal alignment of a top or
#'   bottom legend: `"left"` (default), `"center"`, or `"right"`.
#' @param cell_size Numeric. Side of each (square) cell, in points. Default is
#'   `NULL` (the panel fills the device).
#' @param margins Numeric vector of four margins (top, right, bottom, left), in
#'   points. Default is `c(9, 41, 9, 9)`.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Share of people with a problem (columns) who also had another (rows)
#' # (fictional data)
#' problems <- c("Consumer", "Housing", "Employment")
#' cooc <- expand.grid(column = problems, row = problems, stringsAsFactors = FALSE)
#' cooc$value <- c(NA, 45, 62, 30, NA, 55, 18, 27, NA)
#' cooc$band <- cut(cooc$value, c(-Inf, 25, 50, Inf), right = FALSE,
#'                  labels = c("Less than 25%", "25% to 50%", "50% or more"))
#' cooc$text <- ifelse(is.na(cooc$value), "\u2013", paste0(cooc$value, "%"))
#'
#' wjp_heatmap(
#'   cooc,
#'   x       = "column",
#'   y       = "row",
#'   fill    = "band",
#'   labels  = "text",
#'   x_title = "Among people who experienced problems with:",
#'   y_title = "People who also experienced:"
#' )
#'
wjp_heatmap <- function(data,
                        x,
                        y,
                        fill,
                        labels               = NULL,
                        x_order              = NULL,
                        y_order              = NULL,
                        cvec                 = NULL,
                        na_fill              = "#FFFFFF",
                        border_color         = "#FFFFFF",
                        label_color          = "auto",
                        x_position           = c("top", "bottom"),
                        x_angle              = 40,
                        legend_position      = "top",
                        border_width         = 1.5,
                        label_size           = 9.5,
                        label_fontface       = "plain",
                        label_dark           = "#1A1A1A",
                        axis_text_size       = 10,
                        axis_text_colour     = "#1A1A1A",
                        x_title              = NULL,
                        y_title              = NULL,
                        title_size           = 11,
                        title_fontface       = "bold.italic",
                        title_colour         = "#575796",
                        legend_text_size     = 10,
                        legend_key_size      = NULL,
                        legend_fontface      = "plain",
                        legend_justification = c("left", "center", "right"),
                        cell_size            = NULL,
                        margins              = c(9, 41, 9, 9),
                        ptheme               = WJP_theme()) {

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  x_position <- match.arg(x_position)
  legend_justification <- match.arg(legend_justification)
  if (!is.data.frame(data) || nrow(data) == 0) {
    stop("`data` must be a non-empty data frame.", call. = FALSE)
  }
  column <- function(name, arg) {
    if (!is.character(name) || length(name) != 1 || !name %in% names(data)) {
      stop("`", arg, "` must name an existing column in `data`.", call. = FALSE)
    }
    data[[name]]
  }
  for (nm in c("border_width")) wjp_check_number(get(nm), nm, 0)
  for (nm in c("label_size", "axis_text_size", "title_size", "legend_text_size")) {
    wjp_check_number(get(nm), nm, 0, lower_open = TRUE)
  }
  wjp_check_number(x_angle, "x_angle", -360, 360)
  if (!is.null(cell_size)) wjp_check_number(cell_size, "cell_size", 0, lower_open = TRUE)
  if (!is.numeric(margins) || !length(margins) %in% c(1, 4) || any(!is.finite(margins)) ||
      any(margins < 0)) {
    stop("`margins` must be one or four non-negative numbers (points).", call. = FALSE)
  }
  margins <- rep_len(margins, 4)
  if (length(label_color) != 1 || !is.character(label_color)) {
    stop("`label_color` must be \"auto\" or one color.", call. = FALSE)
  }
  show_legend <- !identical(legend_position, "none")

  # ---------------------------------------------------------------------------
  # Cells
  # ---------------------------------------------------------------------------
  fill_raw <- column(fill, "fill")
  d <- data.frame(
    x = as.character(column(x, "x")),
    y = as.character(column(y, "y")),
    stringsAsFactors = FALSE
  )
  if (anyDuplicated(d)) {
    stop("Supply one row of `data` per cell (x and y combination).", call. = FALSE)
  }
  d$text <- if (is.null(labels)) "" else {
    txt <- as.character(column(labels, "labels"))
    ifelse(is.na(txt), "", txt)
  }
  x_levels <- if (is.null(x_order)) unique(d$x) else x_order
  y_levels <- if (is.null(y_order)) unique(d$y) else y_order
  if (!all(d$x %in% x_levels)) stop("`x_order` must include every column.", call. = FALSE)
  if (!all(d$y %in% y_levels)) stop("`y_order` must include every row.", call. = FALSE)
  d$xf <- factor(d$x, levels = x_levels)
  d$yf <- factor(d$y, levels = rev(y_levels))

  numeric_fill <- is.numeric(fill_raw)
  if (numeric_fill) {
    if (any(is.infinite(fill_raw))) {
      stop("The `fill` column must contain finite values.", call. = FALSE)
    }
    if (is.null(cvec)) cvec <- c("#E5E8E8", "#575796")
    if (length(cvec) != 2) {
      stop("A numeric `fill` needs `cvec` with two colors (low and high).", call. = FALSE)
    }
    d$fill_value <- fill_raw
    lims <- range(fill_raw, na.rm = TRUE)
    span <- if (diff(lims) > 0) diff(lims) else 1
    d$fill_colour <- wjp_mix_rgb(cvec[1], cvec[2], (fill_raw - lims[1]) / span)
  } else {
    bands <- if (is.factor(fill_raw)) {
      levels(droplevels(fill_raw))
    } else {
      unique(as.character(fill_raw[!is.na(fill_raw)]))
    }
    fill_chr <- as.character(fill_raw)
    if (is.null(cvec)) {
      cvec <- stats::setNames(
        wjp_mix_rgb("#E5E8E8", "#575796",
                    if (length(bands) > 1) seq(0, 1, length.out = length(bands)) else 1),
        bands)
    } else if (is.null(names(cvec))) {
      if (length(cvec) < length(bands)) {
        stop("`cvec` must have one color per fill value.", call. = FALSE)
      }
      cvec <- stats::setNames(cvec[seq_along(bands)], bands)
    } else if (!all(bands %in% names(cvec))) {
      stop("Names of `cvec` must include every fill value.", call. = FALSE)
    }
    d$fill_value <- factor(fill_chr, levels = bands)
    d$fill_colour <- unname(cvec[fill_chr])
  }
  d$fill_colour[is.na(d$fill_colour)] <- na_fill
  d$label_colour <- if (identical(label_color, "auto")) {
    wjp_contrast_text(d$fill_colour, dark = label_dark)
  } else {
    label_color
  }

  # ---------------------------------------------------------------------------
  # Plot
  # ---------------------------------------------------------------------------
  lface <- wjp_face(label_fontface)
  tface <- wjp_face(title_fontface)
  family <- wjp_font_family()

  plt <- ggplot2::ggplot(d, ggplot2::aes(x = xf, y = yf)) +
    ggplot2::geom_tile(ggplot2::aes(fill = fill_value), colour = border_color,
                       linewidth = wjp_pt_line(border_width))
  if (!is.null(labels)) {
    plt <- plt + ggplot2::geom_text(
      ggplot2::aes(label = text, colour = I(label_colour)),
      family = lface$family, fontface = lface$fontface,
      size = wjp_pt_text(label_size), show.legend = FALSE
    )
  }
  if (numeric_fill) {
    plt <- plt + scale_fill_wjp_seq(low = cvec[1], high = cvec[2], na.value = na_fill,
                                    name = NULL, guide = if (show_legend) "colourbar" else "none")
  } else {
    plt <- plt + ggplot2::scale_fill_manual(values = cvec, breaks = names(cvec)[names(cvec) %in% levels(d$fill_value)],
                                            na.value = na_fill, name = NULL,
                                            guide = if (show_legend) "legend" else "none")
  }
  plt <- plt +
    ggplot2::scale_x_discrete(position = x_position, drop = FALSE) +
    ggplot2::scale_y_discrete(drop = FALSE) +
    ggplot2::labs(x = x_title, y = y_title) +
    ptheme

  rot <- x_angle %% 360 != 0
  x_text <- ggplot2::element_text(
    family = family, size = axis_text_size, colour = axis_text_colour,
    angle = x_angle,
    hjust = if (rot) 0 else 0.5,
    vjust = if (x_position == "top") 0 else 1
  )
  title_el <- function(...) {
    ggplot2::element_text(family = tface$family, face = tface$fontface, size = title_size,
                          colour = title_colour, ...)
  }
  plt <- plt + ggplot2::theme(
    panel.grid.major   = ggplot2::element_blank(),
    panel.grid.major.x = ggplot2::element_blank(),
    panel.grid.major.y = ggplot2::element_blank(),
    panel.grid.minor   = ggplot2::element_blank(),
    axis.ticks         = ggplot2::element_blank(),
    axis.text.x        = x_text,
    axis.text.x.top    = x_text,
    axis.text.y        = ggplot2::element_text(family = family, size = axis_text_size,
                                               colour = axis_text_colour, hjust = 1),
    axis.title.x       = title_el(hjust = 0, margin = wjp_margin_bp(t = title_size / 4)),
    axis.title.x.top   = title_el(hjust = 0, margin = wjp_margin_bp(b = title_size / 4)),
    axis.title.y       = title_el(angle = 90, margin = wjp_margin_bp(r = title_size / 4)),
    plot.margin        = wjp_margin_bp(margins[1], margins[2], margins[3], margins[4])
  )
  if (is.null(x_title)) plt <- plt + ggplot2::theme(axis.title.x = ggplot2::element_blank(),
                                                    axis.title.x.top = ggplot2::element_blank())
  if (is.null(y_title)) plt <- plt + ggplot2::theme(axis.title.y = ggplot2::element_blank())

  if (show_legend) {
    plt <- plt +
      wjp_legend_theme(TRUE, position = legend_position, text_size = legend_text_size,
                       key_size = legend_key_size, text_colour = axis_text_colour,
                       text_face = legend_fontface) +
      ggplot2::theme(
        legend.justification = legend_justification,
        legend.box.margin    = ggplot2::margin(0, 0, 0, 0),
        legend.text          = ggplot2::element_text(family = family, size = legend_text_size,
                                                     colour = axis_text_colour,
                                                     face = wjp_face(legend_fontface)$fontface)
      )
  } else {
    plt <- plt + ggplot2::theme(legend.position = "none")
  }

  if (!is.null(cell_size)) {
    plt <- plt + ggplot2::theme(
      panel.widths  = wjp_bp(cell_size * length(x_levels)),
      panel.heights = wjp_bp(cell_size * length(y_levels))
    )
  }

  wjp_apply_ptheme(plt, ptheme)
}
