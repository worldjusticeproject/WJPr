#' Plot a Bar Chart following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_bars()` takes a data frame with long-format data and returns a ggplot
#' object with a vertical or horizontal bar chart following WJP style guidelines.
#' Values are expected on a 0-100 percentage scale.
#'
#' @details
#' The function expects one row per bar: a category in `grouping` and its value
#' in `target`. For stacked bars (`stacked = TRUE`), supply one row per segment
#' (each `grouping` and `colors` combination) and precompute the label
#' coordinates (`lab_pos`) at the center of each segment, or use
#' `value_position = "center"`; segment labels are drawn in white.
#'
#' \strong{Side-by-side series.} With `position = "dodge"`, rows that share a
#' category are drawn next to each other (e.g., a country and the EU average),
#' in the order of the `colors` values (factor levels or first appearance):
#' the first series at the top of horizontal charts and at the left of
#' vertical ones (`series_reverse = TRUE` swaps them). Value labels and the
#' optional 100% `track` follow their bars.
#'
#' \strong{Value labels.} `value_position = "end"` (default) centers each label
#' on the end of its bar, as in earlier versions, or on `lab_pos` when given.
#' `"outside"` anchors it `value_offset` points after the end of the bar, and
#' `"center"` puts it in the middle of the bar (or of its stacked segment), and
#' `"column"` aligns the labels `value_offset` points after the 100% mark.
#' Rows with a missing value draw their label at the start of the axis.
#'
#' \strong{Centered bars.} `align = "center"` centers every bar on the middle of
#' the value axis (funnel-like layouts); see also [wjp_funnel()].
#'
#' \strong{Geometry in points.} With a [wjp_layout()], horizontal charts keep a
#' fixed label column (`label_width`, `label_gap`), a 100% track of
#' `track_width` points followed by the value column (`value_gap`,
#' `value_width`), a fixed row pitch (`row_height`) and bar height
#' (`bar_height`), and `margins`. Vertical charts use `row_height` as the column
#' pitch, `bar_height` as the column width, and `track_width` as the height of
#' 100%. The category labels of horizontal charts are then drawn as a text
#' layer in the label column.
#'
#' Like all WJPr chart functions, the returned object is a regular ggplot, so
#' further customizations can be layered with `+`.
#'
#' @param data Data frame containing the data to plot.
#' @param target String. Column name of the variable that supplies the values to plot.
#' @param grouping String. Column name of the variable that supplies the categories
#'   (X-axis for vertical bars, Y-axis for horizontal bars).
#' @param labels String. Column name of the variable containing the value labels to
#'   display. Default is `NULL` (no labels).
#' @param colors String. Column name of the variable that contains the color grouping
#'   (the series of stacked or side-by-side bars).
#'   Default is `NULL` (colors follow `grouping`).
#' @param cvec Named vector of colors. Names should match the values of the `colors`
#'   variable. Default is `NULL` (the WJP palette, see [wjp_palette()], is applied).
#' @param direction String. Either `"vertical"` (default) or `"horizontal"`.
#' @param stacked Logical. Set to `TRUE` for stacked bars (several rows per
#'   category, one per segment) so value labels are drawn in white inside each
#'   segment. Default is `FALSE`.
#' @param lab_pos String. Column name of the variable that contains the coordinates
#'   for the value labels. Default is `NULL` (labels follow `value_position`).
#' @param expand Logical. If `TRUE`, the axis is expanded to give extra space for value
#'   labels above 100%. Default is `FALSE`.
#' @param order String. Column name of the variable that contains the display order of
#'   categories. Default is `NULL` (data order).
#' @param width Numeric value between 0 and 1. Width of bars as a fraction of the space
#'   available for each category. Default is `0.9`.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#' @param show_legend Logical. If `TRUE`, displays a horizontal legend above the
#'   chart using the `colors` values. This is most useful when `colors` differs
#'   from `grouping`, such as in stacked or side-by-side bars. Default is `FALSE`.
#' @param position String. `"stack"` (default) stacks the rows of a category;
#'   `"dodge"` draws them side by side.
#' @param dodge_width Numeric. Distance between the centers of side-by-side
#'   groups, as a fraction of the category space. Default is `NULL` (`width`).
#' @param series_reverse Logical. Reverse the order of side-by-side series.
#'   Default is `FALSE`.
#' @param align String. `"start"` (default, bars start at 0) or `"center"`
#'   (bars centered on the middle of the value axis).
#' @param track Logical. Draw a 100% background track behind each bar.
#'   Default is `FALSE`.
#' @param track_color String. Color of the track. Default is `"#E5E8E8"`.
#' @param value_position String. Position of the value labels: `"end"`
#'   (default), `"outside"`, `"center"`, or `"column"`. See Details.
#' @param value_offset Numeric. Distance, in points, between the end of a bar
#'   and its label when `value_position = "outside"`. Default is `5`.
#' @param value_size Numeric. Size of the value labels, in points. Default is `10`.
#' @param value_fontface String. Font face of the value labels: `"plain"`,
#'   `"bold"` (default), `"italic"`, `"bold.italic"`, or a weight face such as
#'   `"semibold.italic"` (see [wjp_fonts()]).
#' @param value_colors Color of the value labels: one color, or a vector named
#'   by the `colors` values (one color per series). Default is `NULL`
#'   (`"#4a4a49"`, white for stacked bars).
#' @param limits Numeric vector of length 2 with the limits of the value axis.
#'   Use `NA` for a limit computed from the data (e.g., `c(0, NA)` scales the
#'   axis to the largest value). Default is `NULL` (`c(0, 110)`, or larger with
#'   `expand = TRUE`).
#' @param breaks Numeric vector with the breaks of the value axis. Default is
#'   `NULL` (every 20 points from 0 to 100).
#' @param axis_labels Labels of the value-axis breaks: a character vector or a
#'   function. Default is `NULL` (percentages).
#' @param expand_mult Numeric vector of length 1 or 2. Multiplicative expansion
#'   of the value axis. Default is `NULL` (ggplot2's default; none with a
#'   `layout`).
#' @param expand_discrete Numeric of length 1 or 2. Space added before the
#'   first and after the last category (in reading order: top then bottom for
#'   horizontal charts, left then right for vertical ones), in categories.
#'   Default is `NULL` (0.6, or 0.5 with a `layout`).
#' @param value_axis Logical. Show the labels of the value axis. Default is `TRUE`.
#' @param grid Logical. Draw grid lines across the value axis. Default is `TRUE`.
#' @param grid_color String. Color of the grid lines. Default is `"#d1cfd1"`.
#' @param ylab String. Title of the value axis (shown on vertical charts).
#'   Default is `"% of respondents"`; `NULL` removes it.
#' @param baseline Logical. Draw a line at the start of the value axis.
#'   Default is `FALSE`.
#' @param baseline_color String. Color of the baseline. Default is `"#1A1A1A"`.
#' @param label_align String. Alignment of the category labels: `"left"`,
#'   `"right"`, or `"center"`. Default is `NULL` (left for horizontal charts,
#'   centered for vertical ones).
#' @param label_size Numeric. Size of the category labels, in points. Default
#'   is `NULL` (the size of `ptheme`).
#' @param label_colour String. Color of the category labels. Default is `NULL`
#'   (the color of `ptheme`).
#' @param label_wrap Numeric. Maximum number of characters per line of the
#'   category labels. Default is `NULL` (no wrapping; existing line breaks are kept).
#' @param label_lineheight Numeric. Line height of multi-line category labels.
#'   Default is `NULL`.
#' @param ref_lines Reference lines: a numeric vector with positions on the
#'   category axis (in category units, e.g. `3.5` between the third and fourth
#'   categories), or a data frame with columns `axis` (`"category"` or
#'   `"value"`), `position` and, optionally, `colour`, `linetype`, and
#'   `linewidth` (points). Default is `NULL`.
#' @param clip String. Whether to clip drawing to the panel: `"on"` (default)
#'   or `"off"` (keeps labels next to 100% visible).
#' @param layout A [wjp_layout()] with the geometry of the chart in points.
#'   Default is `NULL`.
#' @param legend_position Legend position: `"top"` (default), `"bottom"`,
#'   `"left"`, `"right"`, or `c(x, y)` inside the panel.
#' @param legend_text_size Numeric. Size of the legend text, in points. Default is `11`.
#' @param legend_key_size Numeric. Size of the legend keys, in points.
#'   Default is `NULL`.
#' @param legend_fontface String. Font face of the legend text. Default is `"bold"`.
#' @param legend_justification String. Horizontal justification of a legend
#'   above or below the chart: `"left"` (default), `"center"`, or `"right"`.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Percentage of people that trust their institutions, by country
#' data4bars <- WJPr::gpp %>%
#'   filter(year == 2022) %>%
#'   mutate(
#'     q1a   = as.double(unclass(q1a)),
#'     trust = case_when(q1a <= 2 ~ 1, q1a <= 4 ~ 0)
#'   ) %>%
#'   group_by(country) %>%
#'   summarise(trust = mean(trust, na.rm = TRUE) * 100, .groups = "drop") %>%
#'   mutate(
#'     value_label    = paste0(round(trust, 0), "%"),
#'     label_position = trust + 6
#'   )
#'
#' # Vertical bars (default)
#' wjp_bars(
#'   data4bars,
#'   target   = "trust",
#'   grouping = "country",
#'   labels   = "value_label",
#'   lab_pos  = "label_position",
#'   cvec     = c("Atlantis"  = "#482d8b",
#'                "Narnia"    = "#2894aa",
#'                "Neverland" = "#f26b21")
#' )
#'
#' # Horizontal bars
#' wjp_bars(
#'   data4bars,
#'   target    = "trust",
#'   grouping  = "country",
#'   labels    = "value_label",
#'   lab_pos   = "label_position",
#'   direction = "horizontal"
#' )
#'
#' # Stacked bars: one row per segment, labels centered on each segment
#' data4stacked <- WJPr::gpp %>%
#'   filter(year == 2022) %>%
#'   mutate(
#'     q1a   = as.double(unclass(q1a)),
#'     level = case_when(q1a <= 2 ~ "Trust", q1a <= 4 ~ "No trust")
#'   ) %>%
#'   filter(!is.na(level)) %>%
#'   count(country, level) %>%
#'   group_by(country) %>%
#'   mutate(
#'     percentage     = n / sum(n) * 100,
#'     value_label    = paste0(round(percentage, 0), "%"),
#'     level          = factor(level, levels = c("No trust", "Trust")),
#'     label_position = if_else(
#'       level == "Trust", percentage / 2, 100 - percentage / 2
#'     )
#'   ) %>%
#'   ungroup()
#'
#' wjp_bars(
#'   data4stacked,
#'   target   = "percentage",
#'   grouping = "country",
#'   labels   = "value_label",
#'   lab_pos  = "label_position",
#'   colors   = "level",
#'   stacked  = TRUE,
#'   show_legend = TRUE,
#'   cvec     = c("Trust" = "#482d8b", "No trust" = "#f26b21")
#' )
#'
#' # Country and EU average side by side, with a 100% track and values after
#' # each bar (fictional data)
#' paired <- data.frame(
#'   category = rep(c("Consumer", "Housing", "Employment"), 2),
#'   series   = rep(c("Atlantis", "EU Average"), each = 3),
#'   value    = c(40, 10, 19, 21, 7, 10)
#' )
#' paired$text <- paste0(paired$value, "%")
#'
#' wjp_bars(
#'   paired,
#'   target         = "value",
#'   grouping       = "category",
#'   labels         = "text",
#'   colors         = "series",
#'   cvec           = c("Atlantis" = "#575796", "EU Average" = "#A8A8C8"),
#'   direction      = "horizontal",
#'   position       = "dodge",
#'   track          = TRUE,
#'   value_position = "outside",
#'   value_colors   = c("Atlantis" = "#575796", "EU Average" = "#7D7DA8"),
#'   value_axis     = FALSE,
#'   grid           = FALSE,
#'   label_align    = "right",
#'   show_legend    = TRUE,
#'   layout         = wjp_layout(label_width = 90, label_gap = 6,
#'                               track_width = 250, value_gap = 5,
#'                               value_width = 30, row_height = 21,
#'                               bar_height = 8)
#' )
#'
wjp_bars <- function(
    data,
    target,
    grouping,
    labels           = NULL,
    colors           = NULL,
    cvec             = NULL,
    direction        = "vertical",
    stacked          = FALSE,
    lab_pos          = NULL,
    expand           = FALSE,
    order            = NULL,
    width            = 0.9,
    ptheme           = WJP_theme(),
    show_legend      = FALSE,
    position         = c("stack", "dodge"),
    dodge_width      = NULL,
    series_reverse   = FALSE,
    align            = c("start", "center"),
    track            = FALSE,
    track_color      = "#E5E8E8",
    value_position   = c("end", "outside", "center", "column"),
    value_offset     = 5,
    value_size       = 10,
    value_fontface   = "bold",
    value_colors     = NULL,
    limits           = NULL,
    breaks           = NULL,
    axis_labels      = NULL,
    expand_mult      = NULL,
    expand_discrete  = NULL,
    value_axis       = TRUE,
    grid             = TRUE,
    grid_color       = "#d1cfd1",
    ylab             = "% of respondents",
    baseline         = FALSE,
    baseline_color   = "#1A1A1A",
    label_align      = NULL,
    label_size       = NULL,
    label_colour     = NULL,
    label_wrap       = NULL,
    label_lineheight = NULL,
    ref_lines        = NULL,
    clip             = "on",
    layout           = NULL,
    legend_position  = "top",
    legend_text_size = 11,
    legend_key_size  = NULL,
    legend_fontface  = "bold",
    legend_justification = "left"
){

  if (!direction %in% c("vertical", "horizontal")) {
    stop('`direction` must be one of "vertical" or "horizontal".', call. = FALSE)
  }
  position       <- match.arg(position)
  align          <- match.arg(align)
  value_position <- match.arg(value_position)
  horizontal     <- direction == "horizontal"
  for (nm in c("stacked", "expand", "series_reverse", "track", "value_axis", "grid",
               "baseline")) {
    v <- get(nm)
    if (length(v) != 1 || !is.logical(v) || is.na(v)) {
      stop("`", nm, "` must be TRUE or FALSE.", call. = FALSE)
    }
  }
  wjp_check_number(width, "width", 0, 1, lower_open = TRUE)
  wjp_check_number(value_offset, "value_offset", 0)
  wjp_check_number(value_size, "value_size", 0, lower_open = TRUE)
  if (!is.null(dodge_width)) wjp_check_number(dodge_width, "dodge_width", 0, lower_open = TRUE)
  if (!is.null(label_size)) wjp_check_number(label_size, "label_size", 0, lower_open = TRUE)
  if (!is.null(label_wrap)) wjp_check_number(label_wrap, "label_wrap", 1)
  if (!clip %in% c("on", "off")) {
    stop('`clip` must be "on" or "off".', call. = FALSE)
  }
  if (!is.null(label_align) &&
      (length(label_align) != 1 || !label_align %in% c("left", "right", "center"))) {
    stop('`label_align` must be "left", "right", or "center".', call. = FALSE)
  }
  legend_theme <- wjp_legend_theme(show_legend, position = legend_position,
                                   text_size = legend_text_size,
                                   key_size = legend_key_size,
                                   text_face = legend_fontface,
                                   justification = legend_justification)

  # Renaming variables in the data frame to match the function naming
  data <- data %>%
    dplyr::ungroup() %>%
    dplyr::rename(target_var   = all_of(target),
                  grouping_var = all_of(grouping))

  # Handle labels
  if (is.null(labels)) {
    data <- data %>%
      dplyr::mutate(labels_var = "")
  } else {
    data <- data %>%
      dplyr::rename(labels_var = all_of(labels)) %>%
      dplyr::mutate(labels_var = as.character(labels_var))
  }

  # Handle lab_pos
  custom_pos <- !is.null(lab_pos)
  if (!custom_pos) {
    data <- data %>%
      dplyr::mutate(lab_pos = target_var)
  } else {
    data <- data %>%
      dplyr::rename(lab_pos = all_of(lab_pos))
  }

  # Handle colors
  if (is.null(colors) || identical(grouping, colors)) {
    data <- data %>%
      dplyr::mutate(colors_var = grouping_var)
  } else {
    data <- data %>%
      dplyr::rename(colors_var = all_of(colors))
  }

  # Handle order: reorder categories upfront so a single ggplot block suffices
  if (!is.null(order)) {
    data <- data %>%
      dplyr::rename(order_var = all_of(order)) %>%
      dplyr::mutate(grouping_var = reorder(grouping_var, order_var))
  }

  # Series order (side-by-side bars and legends)
  series_levels <- wjp_legend_breaks(data$colors_var)
  if (position == "dodge") {
    data$colors_var <- factor(as.character(data$colors_var), levels = series_levels)
  }

  # Default to the WJP palette when no color vector is supplied
  if (is.null(cvec)) {
    cvec <- wjp_default_cvec(data$colors_var)
  }
  legend_breaks <- wjp_legend_breaks(data$colors_var)

  # Missing values: no bar, label at the start of the axis
  data$na_value <- is.na(data$target_var)

  # ---------------------------------------------------------------------------
  # Layout in points
  # ---------------------------------------------------------------------------
  use_layout <- !is.null(layout)
  n_cat <- length(unique(as.character(data$grouping_var)))
  n_series <- length(series_levels)
  if (use_layout) {
    lay <- wjp_layout_resolve(layout, list(
      label_width = 120, label_gap = 6, track_width = 250, value_gap = 5,
      value_width = 30, row_height = if (horizontal) 22 else 60,
      bar_height = if (horizontal) 18 else 40, margins = c(0, 0, 0, 0)
    ))
    per_cat <- if (position == "dodge") n_series else 1
    width <- min(1, per_cat * lay$bar_height / lay$row_height)
    if (is.null(dodge_width) && position == "dodge") {
      dodge_width <- width
    }
  }

  # ---------------------------------------------------------------------------
  # Value axis
  # ---------------------------------------------------------------------------
  y_upper <- 110
  if (isTRUE(expand)) {
    max_value <- suppressWarnings(max(c(data$target_var, data$lab_pos), na.rm = TRUE))
    if (is.finite(max_value)) {
      y_upper <- max(110, max_value * 1.05)
    }
  }
  data_max <- suppressWarnings(max(data$target_var, na.rm = TRUE))
  if (!is.finite(data_max)) data_max <- 100
  if (is.null(limits)) {
    y_limits <- c(0, y_upper)
    if (use_layout && horizontal) {
      y_limits <- c(0, 100 * (lay$track_width + lay$value_gap + lay$value_width) /
                      lay$track_width)
    }
  } else {
    if (!is.numeric(limits) && !all(is.na(limits)) || length(limits) != 2) {
      stop("`limits` must be a numeric vector of length 2.", call. = FALSE)
    }
    y_limits <- as.numeric(limits)
    if (is.na(y_limits[1])) y_limits[1] <- 0
    if (is.na(y_limits[2])) y_limits[2] <- data_max
  }
  y_breaks <- if (is.null(breaks)) seq(0, 100, 20) else breaks
  y_labels <- if (is.null(axis_labels)) {
    function(x) paste0(x, "%")
  } else {
    axis_labels
  }
  if (is.null(expand_mult)) {
    y_expand <- if (use_layout) c(0, 0) else ggplot2::waiver()
  } else {
    y_expand <- ggplot2::expansion(mult = rep_len(expand_mult, 2))
  }
  # points per unit of the value axis (exact only with a layout)
  ppu <- if (use_layout) lay$track_width / 100 else NA_real_

  # ---------------------------------------------------------------------------
  # Positions
  # ---------------------------------------------------------------------------
  multi_segment <- any(duplicated(as.character(data$grouping_var)))
  bar_position <- if (position == "dodge") {
    ggplot2::position_dodge(width = if (is.null(dodge_width)) width else dodge_width,
                            reverse = xor(horizontal, series_reverse))
  } else {
    "stack"
  }
  mid <- mean(y_limits[1:2])
  if (align == "center") {
    mid <- if (is.null(limits)) 50 else mid
  }

  # ---------------------------------------------------------------------------
  # Plot
  # ---------------------------------------------------------------------------
  plt <- ggplot2::ggplot(data,
                         aes(x     = grouping_var,
                             y     = target_var,
                             label = labels_var,
                             fill  = colors_var,
                             group = colors_var))

  if (track) {
    track_data <- function(d) {
      d$target_var <- ifelse(d$na_value, 0, 100)
      d
    }
    if (align == "center") {
      plt <- plt + ggplot2::geom_tile(
        data = track_data, aes(y = mid, height = target_var),
        fill = track_color, width = width, show.legend = FALSE
      )
    } else {
      plt <- plt + ggplot2::geom_col(
        data = track_data, fill = track_color, width = width,
        position = if (position == "dodge") bar_position else "identity",
        show.legend = FALSE
      )
    }
  }

  if (align == "center") {
    plt <- plt + ggplot2::geom_tile(
      aes(y = mid, height = target_var),
      width = width, show.legend = show_legend, na.rm = TRUE
    )
  } else {
    plt <- plt + ggplot2::geom_col(
      position    = bar_position,
      width       = width,
      show.legend = show_legend,
      na.rm       = TRUE
    )
  }

  # Value labels
  if (!is.null(labels)) {
    default_colour <- if (isTRUE(stacked)) "#ffffff" else "#4a4a49"
    if (is.null(value_colors)) {
      data$value_colour <- default_colour
    } else if (length(value_colors) == 1 && is.null(names(value_colors))) {
      data$value_colour <- value_colors
    } else {
      if (is.null(names(value_colors))) {
        value_colors <- stats::setNames(rep_len(value_colors, n_series), series_levels)
      }
      data$value_colour <- unname(value_colors[as.character(data$colors_var)])
      data$value_colour[is.na(data$value_colour)] <- default_colour
    }

    # Label coordinate (value axis) and anchoring
    if (custom_pos) {
      data$label_y <- data$lab_pos
    } else if (align == "center") {
      data$label_y <- mid + ifelse(value_position == "outside",
                                   dplyr::coalesce(data$target_var, 0) / 2, 0)
    } else if (value_position == "center") {
      data$label_y <- dplyr::coalesce(data$target_var, 0) / 2
    } else if (value_position == "column") {
      data$label_y <- 100
    } else {
      data$label_y <- dplyr::coalesce(data$target_var, 0)
    }
    anchor_out <- value_position %in% c("outside", "column")
    text_position <- if (position == "dodge") {
      bar_position
    } else if (multi_segment && !custom_pos && align == "start" && value_position != "column") {
      ggplot2::position_stack(vjust = if (value_position == "center") 0.5 else 1)
    } else {
      "identity"
    }
    if (multi_segment && !custom_pos && align == "start" && position == "stack" &&
        value_position != "column") {
      data$label_y <- dplyr::coalesce(data$target_var, 0)
    }

    text_aes <- aes(y = label_y, colour = I(value_colour), group = colors_var)
    vface <- wjp_face(value_fontface)
    if (anchor_out && use_layout) {
      # exact offset in data units
      data$label_y <- data$label_y + value_offset / ppu
      plt <- plt + ggplot2::geom_text(
        data = data, mapping = text_aes,
        position = text_position,
        hjust = if (horizontal) 0 else 0.5,
        vjust = if (horizontal) 0.5 else 0,
        family = vface$family, fontface = vface$fontface,
        size = wjp_pt_text(value_size), show.legend = FALSE, na.rm = TRUE
      )
    } else if (anchor_out) {
      plt <- plt + wjp_offset_text(
        data = data, mapping = text_aes, position = text_position,
        offset = value_offset, side = if (horizontal) "right" else "top",
        family = vface$family, fontface = vface$fontface,
        size = wjp_pt_text(value_size)
      )
    } else {
      plt <- plt + ggplot2::geom_text(
        data = data, mapping = text_aes,
        position = text_position,
        family = vface$family, fontface = vface$fontface,
        size = wjp_pt_text(value_size), show.legend = FALSE, na.rm = TRUE
      )
    }
  }

  # Reference lines
  if (!is.null(ref_lines)) {
    plt <- plt + wjp_ref_line_layers(ref_lines)
  }
  if (baseline) {
    plt <- plt + ggplot2::geom_hline(yintercept = y_limits[1], colour = baseline_color,
                                     linewidth = wjp_pt_line(0.6))
  }

  plt <- plt +
    ggplot2::scale_fill_manual(values = cvec,
                               breaks = legend_breaks,
                               name = NULL)
  plt <- plt + if (is.null(ylab)) labs(y = NULL) else labs(y = ylab)

  # Category labels (wrapping)
  wrap_fun <- function(x) {
    x <- as.character(x)
    if (is.null(label_wrap)) return(x)
    vapply(x, function(s) {
      paste(vapply(strsplit(s, "\n", fixed = TRUE)[[1]], function(z) {
        paste(strwrap(z, width = label_wrap), collapse = "\n")
      }, character(1)), collapse = "\n")
    }, character(1), USE.NAMES = FALSE)
  }

  disc_add <- if (is.null(expand_discrete)) {
    if (use_layout) 0.5 else 0.6
  } else {
    if (!is.numeric(expand_discrete) || !length(expand_discrete) %in% 1:2 ||
        any(!is.finite(expand_discrete)) || any(expand_discrete < 0)) {
      stop("`expand_discrete` must be one or two non-negative numbers.", call. = FALSE)
    }
    expand_discrete
  }
  disc_add <- rep_len(disc_add, 2)
  # ggplot2 expands the lower end first; horizontal charts read from the top
  disc_expand <- if (horizontal) rev(disc_add) else disc_add
  label_layer <- use_layout && horizontal

  y_scale <- ggplot2::scale_y_continuous(limits   = y_limits,
                                         breaks   = y_breaks,
                                         labels   = y_labels,
                                         expand   = y_expand,
                                         oob      = scales::oob_keep,
                                         position = if (horizontal) "right" else "left")

  label_hjust <- switch(if (is.null(label_align)) "default" else label_align,
                        left = 0, right = 1, center = 0.5,
                        default = if (horizontal) 0 else 0.5)

  if (!horizontal) {
    plt  <- plt +
      y_scale +
      ggplot2::scale_x_discrete(labels = wrap_fun,
                                expand = ggplot2::expansion(add = disc_expand)) +
      ggplot2::coord_cartesian(clip = clip) +
      ptheme +
      ggplot2::theme(panel.grid.major.x = element_blank(),
                     panel.grid.major.y = if (grid) element_line(color = grid_color) else element_blank(),
                     axis.title.x       = element_blank())
    if (!value_axis) {
      plt <- plt + ggplot2::theme(axis.text.y = element_blank())
    }
  } else {
    plt  <- plt +
      y_scale +
      ggplot2::scale_x_discrete(limits = rev, labels = wrap_fun,
                                expand = ggplot2::expansion(add = disc_expand)) +
      ggplot2::coord_flip(clip = if (label_layer) "off" else clip) +
      ptheme +
      ggplot2::theme(panel.grid.major.y = element_blank(),
                     panel.grid.major.x = if (grid) element_line(color = grid_color) else element_blank(),
                     axis.title.y       = element_blank(),
                     axis.title.x       = element_blank(),
                     axis.text.y        = element_text(hjust = label_hjust))
    plt <- plt + labs(y = NULL)
    if (!value_axis) {
      plt <- plt + ggplot2::theme(axis.text.x = element_blank())
    }
  }

  # Category label style
  cat_axis <- if (horizontal) "axis.text.y" else "axis.text.x"
  cat_el <- list(hjust = if (!is.null(label_align) || horizontal) label_hjust else NULL,
                 size = label_size, colour = label_colour, lineheight = label_lineheight)
  cat_el <- cat_el[!vapply(cat_el, is.null, logical(1))]
  if (length(cat_el) > 0 && !label_layer) {
    plt <- plt + do.call(ggplot2::theme,
                         stats::setNames(list(do.call(ggplot2::element_text, cat_el)), cat_axis))
  }

  # Layout: fixed panel size, label column as a text layer, margins
  if (use_layout) {
    m <- lay$margins
    if (horizontal) {
      cats <- levels(factor(data$grouping_var))
      if (!is.factor(data$grouping_var)) cats <- unique(as.character(data$grouping_var))
      lab_data <- data.frame(grouping_var = cats, stringsAsFactors = FALSE)
      lab_data$text <- wrap_fun(cats)
      x_lab <- if (label_hjust == 0) {
        -(lay$label_gap + lay$label_width) / ppu
      } else if (label_hjust == 1) {
        -lay$label_gap / ppu
      } else {
        -(lay$label_gap + lay$label_width / 2) / ppu
      }
      plt <- plt + ggplot2::geom_text(
        data = lab_data,
        mapping = aes(x = grouping_var, y = x_lab, label = text),
        inherit.aes = FALSE, hjust = label_hjust,
        family = wjp_font_family(),
        size = wjp_pt_text(if (is.null(label_size)) 10 else label_size),
        colour = if (is.null(label_colour)) "#524F4C" else label_colour,
        lineheight = if (is.null(label_lineheight)) 1.2 else label_lineheight
      )
      span <- (n_cat - 1 + sum(disc_add)) * lay$row_height
      plt <- plt + ggplot2::theme(
        axis.text.y   = element_blank(),
        axis.ticks.length = wjp_bp(0),
        panel.widths  = wjp_bp(lay$track_width * diff(y_limits) / 100),
        panel.heights = wjp_bp(span),
        plot.margin   = wjp_margin_bp(m[1], m[2], m[3], m[4] + lay$label_width + lay$label_gap)
      )
    } else {
      span <- (n_cat - 1 + sum(disc_add)) * lay$row_height
      plt <- plt + ggplot2::theme(
        axis.ticks.length = wjp_bp(0),
        panel.widths  = wjp_bp(span),
        panel.heights = wjp_bp(lay$track_width * diff(y_limits) / 100),
        plot.margin   = wjp_margin_bp(m[1], m[2], m[3], m[4])
      )
    }
  }

  plt <- plt + legend_theme
  plt <- wjp_apply_ptheme(plt, ptheme)

  return(plt)

}


#' Check a numeric scalar argument
#' @noRd
wjp_check_number <- function(x, name, lower = -Inf, upper = Inf, lower_open = FALSE) {
  ok <- length(x) == 1 && is.numeric(x) && is.finite(x) && x <= upper &&
    (if (lower_open) x > lower else x >= lower)
  if (!ok) {
    bound <- if (is.finite(upper)) paste0(" between ", lower, " and ", upper) else
      paste0(if (lower_open) " greater than " else " of at least ", lower)
    stop("`", name, "` must be a single number", bound, ".", call. = FALSE)
  }
  invisible(x)
}

#' Text layer anchored a fixed number of points away from its position
#'
#' Uses a transparent `geom_label()` whose padding provides the offset, so the
#' distance is exact whatever the size of the panel.
#'
#' @param offset Distance in points.
#' @param side Side of the anchor where the text goes: `"right"`, `"left"`,
#'   `"top"`, or `"bottom"`.
#' @noRd
wjp_offset_text <- function(data, mapping, position = "identity", offset = 5,
                            side = "right", family = wjp_font_family(),
                            fontface = "plain", size = 3.514598, ...) {
  pad <- switch(side,
                right  = wjp_margin_bp(0, 0, 0, offset),
                left   = wjp_margin_bp(0, offset, 0, 0),
                top    = wjp_margin_bp(0, 0, offset, 0),
                bottom = wjp_margin_bp(offset, 0, 0, 0))
  args <- list(
    data = data, mapping = mapping, position = position,
    hjust = switch(side, right = 0, left = 1, 0.5),
    vjust = switch(side, top = 0, bottom = 1, 0.5),
    family = family, fontface = fontface, size = size,
    fill = NA, label.padding = pad, label.r = grid::unit(0, "pt"),
    show.legend = FALSE, na.rm = TRUE, ...
  )
  args <- args[!vapply(args, is.null, logical(1))]
  if (utils::packageVersion("ggplot2") >= "4.0.0") {
    args$border.colour <- NA
  } else {
    args$label.size <- 0
  }
  do.call(ggplot2::geom_label, args)
}

#' Reference line layers for bar-like charts
#'
#' @param ref_lines Numeric positions on the category axis, or a data frame
#'   with `axis`, `position`, and optional `colour`, `linetype`, `linewidth`.
#' @noRd
wjp_ref_line_layers <- function(ref_lines) {
  if (is.numeric(ref_lines)) {
    ref_lines <- data.frame(axis = "category", position = ref_lines)
  }
  if (!is.data.frame(ref_lines) || !all(c("axis", "position") %in% names(ref_lines))) {
    stop("`ref_lines` must be numeric or a data frame with `axis` and `position`.",
         call. = FALSE)
  }
  if (!all(ref_lines$axis %in% c("category", "value"))) {
    stop('`ref_lines$axis` must be "category" or "value".', call. = FALSE)
  }
  get <- function(nm, default) if (nm %in% names(ref_lines)) ref_lines[[nm]] else rep(default, nrow(ref_lines))
  ref_lines$colour <- get("colour", "#1A1A1A")
  ref_lines$linetype <- get("linetype", "dashed")
  ref_lines$linewidth <- get("linewidth", 0.75)
  lapply(seq_len(nrow(ref_lines)), function(i) {
    r <- ref_lines[i, ]
    if (r$axis == "category") {
      ggplot2::geom_vline(xintercept = r$position, colour = r$colour,
                          linetype = r$linetype, linewidth = wjp_pt_line(r$linewidth))
    } else {
      ggplot2::geom_hline(yintercept = r$position, colour = r$colour,
                          linetype = r$linetype, linewidth = wjp_pt_line(r$linewidth))
    }
  })
}
