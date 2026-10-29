#' Plot a Funnel Chart following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_funnel()` draws the stages of a pathway (e.g., the justice journey) as
#' centered horizontal bars whose width is proportional to their value, joined
#' by light connectors, with the value printed inside each bar and the stage
#' labels in a column at the left.
#'
#' @details
#' The function expects one row per stage: the stage label in `grouping` and
#' its value in `target`. The widest bar (the largest value) spans the whole
#' bar area; the others are scaled relative to it and centered. Stages are
#' drawn from top to bottom in data order, or in the order given by the
#' `order` column. The printed values come from the `labels` column as given;
#' without it, values are printed as rounded percentages.
#'
#' Stage labels keep their line breaks (newline characters); labels without them
#' are wrapped to `label_width` points when it is supplied. They are
#' right-aligned `label_gap` points before the bar area, and centered on
#' their bar.
#'
#' Geometry is set in points: each bar is `bar_height` points high, bars are
#' `gap` points apart, and `margins` surround the chart. The bar area is
#' `panel_width` points wide, or fills a figure of `width` points (the label
#' column is measured with the active font family). With either of them, the
#' chart has a definite size and [wjp_save()] needs no `width` or `height`.
#' The label column is measured with \pkg{systemfonts} when it knows the font
#' family (see [wjp_fonts()]), and estimated otherwise.
#'
#' @section Example charts:
#' These examples use the WJP Lato font and color palette. Values are
#' illustrative.
#'
#' Justice journey with a starting cohort and step-to-step drop-offs:
#' \figure{wjp_funnel_journey.svg}{options: width='100%' alt='Justice journey funnel showing the original cohort and stage drop-offs.'}
#'
#' Public service pathway with a starting cohort and step-to-step drop-offs:
#' \figure{wjp_funnel_service_path.svg}{options: width='100%' alt='Public service pathway funnel showing the original cohort and stage drop-offs.'}
#'
#' Pathway stages without connectors:
#' \figure{wjp_funnel_order_no_connectors.svg}{options: width='100%' alt='Funnel chart with ordered stages and no connectors.'}
#'
#' @param data Data frame containing the data to plot.
#' @param target String. Column name of the variable with the value of each
#'   stage (it sets the width of the bars).
#' @param grouping String. Column name of the variable with the stage labels.
#' @param labels String. Column name of the variable with the printed values.
#'   Default is `NULL` (rounded percentages of `target`).
#' @param order String. Column name of the variable with the display order of
#'   the stages (top to bottom). Default is `NULL` (data order).
#' @param bar_height Numeric. Height of each bar, in points. Default is `40`.
#' @param gap Numeric. Vertical gap between bars, in points. Default is `18`.
#' @param connectors Logical. Draw connectors between consecutive bars.
#'   Default is `TRUE`.
#' @param connector_color String. Color of the connectors. Default is `"#A8A8C8"`.
#' @param connector_alpha Numeric. Opacity of the connectors. Default is `0.45`.
#' @param color String. Color of the bars. Default is `"#575796"`.
#' @param value_face String. Font face of the values: `"plain"`, `"bold"`,
#'   `"italic"`, `"bold.italic"`, or a weight face such as `"semibold.italic"`
#'   (see [wjp_fonts()]). Default is `"bold"`.
#' @param value_size Numeric. Size of the values, in points. Default is `11`.
#' @param value_color String. Color of the values. Default is `"#FFFFFF"`.
#' @param label_size Numeric. Size of the stage labels, in points. Default is `10`.
#' @param label_colour String. Color of the stage labels. Default is `"#524F4C"`.
#' @param label_width Numeric. Maximum width of a label line, in points, used to
#'   wrap labels without line breaks. Default is `NULL` (no wrapping).
#' @param label_gap Numeric. Gap between the label column and the bar area, in
#'   points. Default is `16`.
#' @param label_lineheight Numeric. Distance between the baselines of label
#'   lines, in multiples of the label size. Default is `1.22`.
#' @param panel_width Numeric. Width of the bar area, in points. Default is
#'   `NULL` (see `width`).
#' @param width Numeric. Total width of the figure, in points; the bar area
#'   takes the space left by the label column and the margins. Default is
#'   `NULL` (the bar area fills the device when `panel_width` is also `NULL`).
#' @param margins Numeric vector of four margins (top, right, bottom, left), in
#'   points. Default is `c(4, 4, 4, 2)`.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Stages of the justice journey (fictional data)
#' journey <- data.frame(
#'   stage = c("Had access to information and advice",
#'             "Obtained appropriate assistance\nwhen they needed it",
#'             "Turned to a dispute resolution\nmechanism when they needed it"),
#'   value = c(61, 32, 28)
#' )
#' journey$text <- paste0(journey$value, "%")
#'
#' wjp_funnel(
#'   journey,
#'   target   = "value",
#'   grouping = "stage",
#'   labels   = "text",
#'   width    = 468
#' )
#'
wjp_funnel <- function(data,
                       target,
                       grouping,
                       labels           = NULL,
                       order            = NULL,
                       bar_height       = 40,
                       gap              = 18,
                       connectors       = TRUE,
                       connector_color  = "#A8A8C8",
                       connector_alpha  = 0.45,
                       color            = "#575796",
                       value_face       = "bold",
                       value_size       = 11,
                       value_color      = "#FFFFFF",
                       label_size       = 10,
                       label_colour     = "#524F4C",
                       label_width      = NULL,
                       label_gap        = 16,
                       label_lineheight = 1.22,
                       panel_width      = NULL,
                       width            = NULL,
                       margins          = c(4, 4, 4, 2),
                       ptheme           = WJP_theme()) {

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  if (!is.data.frame(data) || nrow(data) == 0) {
    stop("`data` must be a non-empty data frame.", call. = FALSE)
  }
  column <- function(name, arg) {
    if (!is.character(name) || length(name) != 1 || !name %in% names(data)) {
      stop("`", arg, "` must name an existing column in `data`.", call. = FALSE)
    }
    data[[name]]
  }
  value <- column(target, "target")
  if (!is.numeric(value)) {
    stop("The `target` column must be numeric.", call. = FALSE)
  }
  if (any(!is.na(value) & (!is.finite(value) | value < 0))) {
    stop("The `target` column must contain non-negative finite values.", call. = FALSE)
  }
  if (all(is.na(value)) || max(value, na.rm = TRUE) <= 0) {
    stop("The `target` column must contain at least one positive value.", call. = FALSE)
  }
  if (length(connectors) != 1 || !is.logical(connectors) || is.na(connectors)) {
    stop("`connectors` must be TRUE or FALSE.", call. = FALSE)
  }
  wjp_check_number(bar_height, "bar_height", 0, lower_open = TRUE)
  wjp_check_number(gap, "gap", 0)
  wjp_check_number(connector_alpha, "connector_alpha", 0, 1)
  wjp_check_number(value_size, "value_size", 0, lower_open = TRUE)
  wjp_check_number(label_size, "label_size", 0, lower_open = TRUE)
  wjp_check_number(label_gap, "label_gap", 0)
  wjp_check_number(label_lineheight, "label_lineheight", 0, lower_open = TRUE)
  if (!is.null(label_width)) wjp_check_number(label_width, "label_width", 0, lower_open = TRUE)
  if (!is.null(panel_width)) wjp_check_number(panel_width, "panel_width", 0, lower_open = TRUE)
  if (!is.null(width)) wjp_check_number(width, "width", 0, lower_open = TRUE)
  if (!is.null(panel_width) && !is.null(width)) {
    stop("Supply only one of `panel_width` and `width`.", call. = FALSE)
  }
  if (!is.numeric(margins) || !length(margins) %in% c(1, 4) || any(!is.finite(margins)) ||
      any(margins < 0)) {
    stop("`margins` must be one or four non-negative numbers (points).", call. = FALSE)
  }
  margins <- rep_len(margins, 4)

  # ---------------------------------------------------------------------------
  # Stages, from the top
  # ---------------------------------------------------------------------------
  d <- data.frame(
    label = as.character(column(grouping, "grouping")),
    value = value,
    stringsAsFactors = FALSE
  )
  d$text <- if (is.null(labels)) {
    ifelse(is.na(d$value), "", paste0(round(d$value), "%"))
  } else {
    txt <- as.character(column(labels, "labels"))
    ifelse(is.na(txt), "", txt)
  }
  if (!is.null(order)) {
    ord <- column(order, "order")
    d <- d[base::order(ord), , drop = FALSE]
  }
  n <- nrow(d)
  d$frac <- dplyr::coalesce(d$value / max(d$value, na.rm = TRUE), 0)

  # Label lines: explicit breaks are kept; others wrap to label_width points
  family <- wjp_font_family()
  wrap_pt <- function(s) {
    if (grepl("\n", s, fixed = TRUE) || is.null(label_width)) {
      return(strsplit(s, "\n", fixed = TRUE)[[1]])
    }
    words <- strsplit(s, " ", fixed = TRUE)[[1]]
    lines <- character()
    cur <- ""
    for (w in words) {
      cand <- if (cur == "") w else paste(cur, w)
      if (cur != "" && wjp_text_width_pt(cand, label_size, family) > label_width) {
        lines <- c(lines, cur)
        cur <- w
      } else {
        cur <- cand
      }
    }
    c(lines, cur)
  }
  label_lines <- lapply(d$label, wrap_pt)
  label_col <- max(vapply(unlist(label_lines), wjp_text_width_pt, numeric(1),
                          size_pt = label_size, family = family))

  # Vertical geometry in points, y increasing downwards from the top bar
  d$top <- (seq_len(n) - 1) * (bar_height + gap)
  d$mid <- d$top + bar_height / 2
  total_h <- n * bar_height + (n - 1) * gap

  # Bar area: x from 0 to 100, the widest bar spans it
  d$xmin <- 50 - 50 * d$frac
  d$xmax <- 50 + 50 * d$frac

  # Text rows: one per label line, centered on the cap height
  step <- label_size * label_lineheight
  lab_rows <- do.call(rbind, lapply(seq_len(n), function(i) {
    ls <- label_lines[[i]]
    base <- d$mid[i] - step * (length(ls) - 1) / 2 + WJP_CAP_HALF_EM * label_size
    data.frame(text = ls,
               y = base + (seq_along(ls) - 1) * step - WJP_CAP_HALF_EM * label_size,
               stringsAsFactors = FALSE)
  }))

  plt <- ggplot2::ggplot()

  if (connectors && n > 1) {
    conn <- do.call(rbind, lapply(seq_len(n - 1), function(i) {
      data.frame(
        id = i,
        x = c(d$xmin[i], d$xmax[i], d$xmax[i + 1], d$xmin[i + 1]),
        y = c(d$top[i] + bar_height, d$top[i] + bar_height, d$top[i + 1], d$top[i + 1])
      )
    }))
    plt <- plt + ggplot2::geom_polygon(
      data = conn, ggplot2::aes(x = x, y = y, group = id),
      fill = connector_color, alpha = connector_alpha, colour = NA
    )
  }

  vface <- wjp_face(value_face)
  plt <- plt +
    ggplot2::geom_rect(
      data = d,
      ggplot2::aes(xmin = xmin, xmax = xmax, ymin = top, ymax = top + bar_height),
      fill = color, colour = NA
    ) +
    ggplot2::geom_text(
      data = d,
      ggplot2::aes(x = 50, y = mid, label = text),
      family = vface$family, fontface = vface$fontface,
      size = wjp_pt_text(value_size), colour = value_color
    ) +
    wjp_offset_text(
      data = transform(lab_rows, x = 0),
      mapping = ggplot2::aes(x = x, y = y, label = text),
      offset = label_gap, side = "left", family = family,
      fontface = "plain", size = wjp_pt_text(label_size), colour = label_colour
    ) +
    ggplot2::scale_x_continuous(limits = c(0, 100), expand = c(0, 0), breaks = NULL,
                                oob = scales::oob_keep) +
    ggplot2::scale_y_reverse(limits = c(total_h, 0), expand = c(0, 0), breaks = NULL,
                             oob = scales::oob_keep) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(x = NULL, y = NULL) +
    ptheme +
    ggplot2::theme(
      panel.grid.major  = ggplot2::element_blank(),
      panel.grid.minor  = ggplot2::element_blank(),
      axis.text         = ggplot2::element_blank(),
      axis.text.x       = ggplot2::element_blank(),
      axis.text.y       = ggplot2::element_blank(),
      axis.ticks.length = wjp_bp(0),
      panel.heights     = wjp_bp(total_h),
      plot.margin       = wjp_margin_bp(margins[1], margins[2], margins[3],
                                        margins[4] + label_col + label_gap)
    )

  bar_area <- if (!is.null(panel_width)) {
    panel_width
  } else if (!is.null(width)) {
    width - margins[2] - margins[4] - label_col - label_gap
  } else {
    NULL
  }
  if (!is.null(bar_area)) {
    if (bar_area <= 0) {
      stop("`width` leaves no room for the bars after the label column.", call. = FALSE)
    }
    plt <- plt + ggplot2::theme(panel.widths = wjp_bp(bar_area))
  }

  wjp_apply_ptheme(plt, ptheme)
}
