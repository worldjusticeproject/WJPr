#' Plot a Horizontal Edgebars Chart following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_edgebars()` takes a data frame with long-format data and returns a
#' ggplot object with an edgebar chart following WJP style guidelines.
#' Edgebars are horizontal bars with the category label placed at the edge of
#' each bar, which makes them ideal for narrow spaces and long labels.
#' Values are expected on a 0-100 percentage scale.
#'
#' @details
#' The function expects one row per bar: the category in `grouping` and its
#' value in `target`. The text above each bar defaults to the `grouping`
#' values; pass a `labels` column to customize it (HTML is supported
#' with `label_style = "rich"` and the ggtext package installed). Percentage value labels are added
#' automatically at the end of each bar.
#'
#' @param data Data frame containing the data to plot.
#' @param target String. Column name of the variable that supplies the values to plot.
#' @param grouping String. Column name of the variable that supplies the categories.
#' @param labels String. Column name of the variable containing the text labels to
#'   display above each bar. Default is `NULL` (the `grouping` values are used).
#' @param cvec One bar color, or two colors for paired series. A named pair
#'   must match the series names. Defaults to WJP violet for single bars and
#'   violet/teal for pairs.
#' @param x_lab_pos String. Column name of the variable that contains the display
#'   order of the bars. Default is `NULL` (data order). Prefer `order` in new code.
#' @param y_lab_pos Numeric. Legacy alias for the horizontal label start.
#'   Default is `0`; prefer `label_start` in new code.
#' @param nudge_lab Numeric. Padding for the text labels in millimeters.
#'   Default is `2.5`.
#' @param margin_top Numeric. Top margin of the plot. Default is `20`.
#' @param bar_width Numeric. Width of the bars. The default of `0.35` is recommended
#'   for single bars. Paired bars occupy separate rows within each category.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#'
#' @param order Column name for numeric category order (ascending, top to bottom).
#'   Preferred alias for `x_lab_pos`; do not supply both.
#' @param sort One of `"none"`, `"ascending"`, or `"descending"`. Sorts by value;
#'   paired bars use the mean of the two values. Cannot be combined with `order`.
#' @param label_start Horizontal start of category labels. Preferred alias for
#'   `y_lab_pos`; do not supply both.
#' @param scale One of `"fixed"` (0-100, default) or `"auto"`.
#' @param na_action `"error"` (default) or `"omit"`. Omission removes entire
#'   categories with missing required values, preserving complete pairs.
#' @param label_style `"plain"` (default) or `"rich"` (requires ggtext).
#'   Rich labels support HTML; insert `<br>` for line breaks.
#' @param label_wrap Positive integer character width for plain-text wrapping.
#'   Use `Inf` to disable wrapping. Rich labels use explicit line breaks.
#' @param label_size,value_size Text sizes in millimeters.
#' @param row_spacing Positive spacing multiplier; increase for crowded exports.
#' @param accuracy Positive rounding increment for percentage labels.
#' @param label_format Optional function taking numeric percentages and returning
#'   one character label per value. Overrides `accuracy` formatting.
#' @param show_values Logical. Show numeric value labels.
#' @param value_position `"end"` or `"column"` (aligned at the right).
#'   With confidence intervals, end labels follow the upper bound.
#' @param background_track Logical. Draw a neutral track from 0 to 100.
#' @param track_color Color of the background track.
#' @param highlight Character vector of categories to highlight. Other categories
#'   use `neutral_color`. With paired bars, highlighted pairs retain series colors.
#' @param neutral_color Color for categories outside `highlight`.
#' @param series Optional column identifying exactly two series. Supply one row
#'   per category and series, with both series present in every category.
#'   First appearance determines series order, or use factor levels.
#'   For paired bars, `cvec` may be two colors named for the series.
#' @param show_legend Logical. Show the series legend for paired bars.
#' @param ci_lower,ci_upper Optional columns of precomputed confidence bounds,
#'   on the same 0-100 scale. Supply both; bounds must enclose the estimate.
#'   The function does not estimate intervals or assume a survey design.
#' @param ci_color Color of confidence interval lines and end caps.
#'
#' @details
#' Categories must be unique unless `series` is supplied. Custom labels and
#' explicit order values must be constant within a category. Invalid or infinite
#' percentages are rejected. Missing values follow `na_action`.
#' The fixed scale makes separate charts comparable; tracks always span 0-100.
#' Labels are positioned independently of optional rich-text support. Wrapped
#' labels reserve additional vertical space. Export height should grow with the
#' number of categories and label lines; very small devices can still crowd text.
#' `nudge_lab` controls the gap above bars in millimeters. Positive plot margins
#' leave room for titles and captions. Font registration is optional; use
#' `options(wjpr.family = "sans")` for a portable system font.
#'
#' @return A ggplot object representing the edgebars plot.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Percentage of people that trust their institutions, by country
#' data4edgebars <- WJPr::gpp %>%
#'   filter(year == 2022) %>%
#'   mutate(
#'     q1a   = as.double(unclass(q1a)),
#'     trust = case_when(q1a <= 2 ~ 1, q1a <= 4 ~ 0)
#'   ) %>%
#'   group_by(country) %>%
#'   summarise(trust = mean(trust, na.rm = TRUE) * 100, .groups = "drop")
#'
#' wjp_edgebars(
#'   data4edgebars,
#'   target   = "trust",
#'   grouping = "country",
#'   cvec     = "#2894aa"
#' )
#'
#' # Custom rich-text labels above each bar (requires ggtext)
#' data4edgebars_lab <- data4edgebars %>%
#'   mutate(
#'     bar_label = paste0(
#'       "<b>", country, "</b> — % that trust their institutions"
#'     )
#'   )
#'
#' wjp_edgebars(
#'   data4edgebars_lab,
#'   target   = "trust",
#'   grouping = "country",
#'   labels   = "bar_label",
#'   label_style = "rich"
#' )
#'
#' # 100% background tracks behind each bar (fictional data; see examples/edgebars.R)
#' institutions <- data.frame(
#'   institution = c("Police", "Courts", "Local government", "Parliament"),
#'   trust       = c(72.4, 64.8, 51.2, 38.6),
#'   bar_label   = c(
#'     "Trust in the police", "Trust in the courts and justice system",
#'     "Trust in local government officials", "Trust in members of parliament"
#'   )
#' )
#'
#' wjp_edgebars(
#'   institutions,
#'   target   = "trust",
#'   grouping = "institution",
#'   labels   = "bar_label",
#'   background_track = TRUE
#' ) +
#'   ggplot2::labs(
#'     title    = "How much of the public trusts each institution?",
#'     subtitle = "Each light background track represents 100%",
#'     caption  = "Fictional data for demonstration only."
#'   )
#'
wjp_edgebars <- function(
    data, target, grouping, labels = NULL, cvec = NULL,
    x_lab_pos = NULL, y_lab_pos = 0, nudge_lab = 2.5,
    margin_top = 20, bar_width = 0.35, ptheme = WJP_theme(),
    order = NULL, sort = c("none", "ascending", "descending"),
    label_start = NULL, scale = c("fixed", "auto"),
    na_action = c("error", "omit"), label_style = c("plain", "rich"),
    label_wrap = 55, label_size = 3.514598, value_size = 3.514598,
    row_spacing = 1, accuracy = 1, label_format = NULL,
    show_values = TRUE, value_position = c("end", "column"),
    background_track = FALSE, track_color = "#ecebed",
    highlight = NULL, neutral_color = "#b9b7bf", series = NULL,
    show_legend = TRUE, ci_lower = NULL, ci_upper = NULL,
    ci_color = "#333333"
) {
  sort <- match.arg(sort)
  scale <- match.arg(scale)
  na_action <- match.arg(na_action)
  label_style <- match.arg(label_style)
  value_position <- match.arg(value_position)
  fail <- function(message) stop(message, call. = FALSE)
  scalar_number <- function(x, name, lower = -Inf, upper = Inf) {
    if (!is.numeric(x) || length(x) != 1L || !is.finite(x) ||
        x < lower || x > upper) {
      fail(paste0("`", name, "` must be a finite number between ", lower, " and ", upper, "."))
    }
  }
  for (name in c("show_values", "background_track", "show_legend")) {
    x <- get(name)
    if (!is.logical(x) || length(x) != 1L || is.na(x))
      fail(paste0("`", name, "` must be TRUE or FALSE."))
  }
  for (name in c("label_size", "value_size", "row_spacing", "accuracy")) {
    scalar_number(get(name), name, .Machine$double.eps)
  }
  scalar_number(bar_width, "bar_width", 0.01, 0.8)
  scalar_number(nudge_lab, "nudge_lab", 0)
  scalar_number(margin_top, "margin_top", 0)
  if (!is.numeric(label_wrap) || length(label_wrap) != 1L || is.na(label_wrap) ||
      label_wrap < 1 || (is.finite(label_wrap) && label_wrap != floor(label_wrap)))
    fail("`label_wrap` must be a positive integer or Inf.")
  if (!is.null(order) && !is.null(x_lab_pos))
    fail("Supply only one of `order` and `x_lab_pos`.")
  if (!is.null(label_start) && !missing(y_lab_pos))
    fail("Supply only one of `label_start` and `y_lab_pos`.")
  order_col <- if (is.null(order)) x_lab_pos else order
  label_start <- if (is.null(label_start)) y_lab_pos else label_start
  scalar_number(label_start, "label_start", 0, 100)
  if (sort != "none" && !is.null(order_col))
    fail("Use either `sort` or an ordering column, not both.")
  if (xor(is.null(ci_lower), is.null(ci_upper)))
    fail("Supply both `ci_lower` and `ci_upper`.")
  has_ci <- !is.null(ci_lower)
  paired <- !is.null(series)
  if (!is.data.frame(data) || nrow(data) == 0L)
    fail("`data` must be a non-empty data frame.")
  column <- function(name, arg) {
    if (!is.character(name) || length(name) != 1L || is.na(name) || !name %in% names(data))
      fail(paste0("`", arg, "` must name an existing column in `data`."))
    data[[name]]
  }
  # A fresh frame prevents internal names from overwriting user columns and
  # allows the same source column to supply more than one plotting role.
  d <- data.frame(
    category = as.character(column(grouping, "grouping")),
    value = column(target, "target"), stringsAsFactors = FALSE
  )
  d$label <- if (is.null(labels)) d$category else as.character(column(labels, "labels"))
  d$order <- if (is.null(order_col)) match(d$category, unique(d$category)) else column(order_col, "order")
  source_series <- if (paired) column(series, "series") else rep("Value", nrow(d))
  d$series <- as.character(source_series)
  d$lower <- if (has_ci) column(ci_lower, "ci_lower") else d$value
  d$upper <- if (has_ci) column(ci_upper, "ci_upper") else d$value
  for (name in c("value", "lower", "upper", "order")) {
    if (!is.numeric(d[[name]])) fail(paste0("The ", name, " column must be numeric."))
    if (any(is.infinite(d[[name]]))) fail(paste0("The ", name, " column must contain finite values."))
  }
  incomplete <- !stats::complete.cases(d)
  if (any(incomplete)) {
    if (na_action == "error") fail("Missing required values; use `na_action = \"omit\"` to omit affected categories.")
    bad_categories <- unique(d$category[incomplete])
    remove <- incomplete | d$category %in% bad_categories
    warning("Omitted ", sum(remove), " row(s) from categories with missing required values.", call. = FALSE)
    d <- d[!remove, , drop = FALSE]
    if (!nrow(d)) fail("No complete categories remain after omitting missing values.")
  }
  if (any(!nzchar(trimws(d$category))) || any(!nzchar(trimws(d$series))))
    fail("Category and series names must not be empty.")
  if (any(d$value < 0 | d$value > 100 | d$lower < 0 | d$upper > 100))
    fail("Values and confidence bounds must be between 0 and 100.")
  if (any(d$lower > d$value | d$upper < d$value))
    fail("Confidence bounds must enclose each estimate: lower <= value <= upper.")
  if (anyDuplicated(d[c("category", "series")]))
    fail(if (paired) "Supply one row per category and series; duplicate pairs found." else
      "Supply one row per category; use `series` for paired bars.")
  series_levels <- if (is.factor(source_series)) {
    levels(source_series)[levels(source_series) %in% d$series]
  } else unique(d$series)
  if (paired && (length(series_levels) != 2L || any(table(d$category) != 2L)))
    fail("Paired bars require exactly two series and both series in every category.")
  categories <- unique(d$category)
  for (cat in categories) {
    rows <- d$category == cat
    if (length(unique(d$label[rows])) != 1L || length(unique(d$order[rows])) != 1L)
      fail("Labels and ordering values must be constant within each category.")
  }
  category_order <- vapply(categories, function(cat) {
    if (sort == "none") d$order[match(cat, d$category)] else mean(d$value[d$category == cat])
  }, numeric(1))
  categories <- categories[base::order(if (sort == "descending") -category_order else category_order,
                                     seq_along(categories))]
  if (!is.null(highlight) && (!is.character(highlight) || anyNA(highlight) ||
                             any(!highlight %in% categories)))
    fail("`highlight` must contain category names present in the plotted data.")
  check_colors <- function(x, name) {
    if (!is.character(x) || !length(x) || anyNA(x)) fail(paste0("Invalid `", name, "`."))
    tryCatch(grDevices::col2rgb(x), error = function(e) fail(paste0("Invalid color in `", name, "`.")))
  }
  for (name in c("track_color", "neutral_color", "ci_color")) {
    if (length(get(name)) != 1L) fail(paste0("`", name, "` must be one color."))
    check_colors(get(name), name)
  }
  if (is.null(cvec)) cvec <- if (paired) c("#482d8b", "#2894aa") else "#482d8b"
  check_colors(cvec, "cvec")
  if (length(cvec) != length(series_levels))
    fail(if (paired) "`cvec` must supply two series colors." else "`cvec` must supply one color.")
  if (paired && !is.null(names(cvec))) {
    if (anyDuplicated(names(cvec)) || !setequal(names(cvec), series_levels))
      fail("Names of `cvec` must match the two series names.")
    cvec <- cvec[series_levels]
  }
  cvec <- stats::setNames(unname(cvec), series_levels)
  d$series <- factor(d$series, levels = series_levels)
  d$fill <- unname(cvec[as.character(d$series)])
  if (!is.null(highlight)) d$fill[!d$category %in% highlight] <- neutral_color
  if (!is.null(label_format) && !is.function(label_format)) fail("`label_format` must be a function.")
  value_labels <- if (is.null(label_format)) scales::number(d$value, accuracy = accuracy, suffix = "%") else label_format(d$value)
  if (!is.character(value_labels) || length(value_labels) != nrow(d) || anyNA(value_labels))
    fail("`label_format` must return one non-missing character label per value.")
  d$value_label <- value_labels
  if (label_style == "rich" && !requireNamespace("ggtext", quietly = TRUE))
    fail("`label_style = \"rich\"` requires the ggtext package.")
  label_data <- d[match(categories, d$category), c("category", "label"), drop = FALSE]
  if (label_style == "plain" && is.finite(label_wrap)) {
    label_data$label <- vapply(label_data$label, function(x) {
      paragraphs <- strsplit(x, "\n", fixed = TRUE)[[1]]
      paste(vapply(paragraphs, function(z) paste(strwrap(z, width = label_wrap), collapse = "\n"), character(1)), collapse = "\n")
    }, character(1))
  }
  count_text <- gsub("<br\\s*/?>", "\n", label_data$label, ignore.case = TRUE)
  nlines <- lengths(strsplit(count_text, "\n", fixed = TRUE))
  # Numeric row coordinates reserve space for multiline headings and paired bars.
  # Both label backends use physical padding above the top bar.
  # The heading baseline clears the top edge even when bar_width changes.
  heading_gap <- 0.18 + nudge_lab / 10
  line_height <- 0.38 * label_size / 3.514598
  block_height <- (if (paired) 1.65 else 0.9) + heading_gap + pmax(1, nlines) * line_height
  block_height <- block_height * row_spacing
  top <- -c(0, head(cumsum(block_height), -1))
  label_data$x <- label_start
  first_center <- top - (pmax(1, nlines) - 1) * line_height - heading_gap - bar_width / 2
  label_data$y <- first_center + bar_width / 2
  d$y <- first_center[match(d$category, categories)] -
    (as.integer(d$series) - 1) * (bar_width + 0.28)
  d$ymin <- d$y - bar_width / 2
  d$ymax <- d$y + bar_width / 2
  xmax <- if (scale == "fixed" || background_track) 100 else max(1, d$upper, label_start)
  d$value_x <- if (value_position == "column") xmax + 3 else d$upper + xmax * 0.015
  right_room <- if (show_values) max(12, max(nchar(c(d$value_label, scales::number(100, accuracy = accuracy, suffix = "%")))) * value_size * 0.8) else 3
  plt <- ggplot2::ggplot(d)
  if (background_track) plt <- plt + ggplot2::geom_rect(
    ggplot2::aes(xmin = 0, xmax = 100, ymin = ymin, ymax = ymax),
    fill = track_color, colour = NA
  )
  # Map actual colors through an identity scale so highlights and series can coexist.
  plt <- plt + ggplot2::geom_rect(
    ggplot2::aes(xmin = 0, xmax = value, ymin = ymin, ymax = ymax, fill = fill),
    colour = NA, show.legend = paired && show_legend
  ) + ggplot2::scale_fill_identity(
    breaks = unname(cvec), labels = names(cvec), name = NULL,
    guide = if (paired && show_legend) "legend" else "none"
  )
  if (has_ci) {
    plt <- plt + ggplot2::geom_segment(
      ggplot2::aes(x = lower, xend = upper, y = y, yend = y),
      colour = "white", linewidth = 1.4
    ) + ggplot2::geom_segment(
      ggplot2::aes(x = lower, xend = upper, y = y, yend = y),
      colour = ci_color, linewidth = 0.5
    ) + ggplot2::geom_segment(
      ggplot2::aes(x = lower, xend = lower, y = y - bar_width * 0.3, yend = y + bar_width * 0.3),
      colour = ci_color, linewidth = 0.5
    ) + ggplot2::geom_segment(
      ggplot2::aes(x = upper, xend = upper, y = y - bar_width * 0.3, yend = y + bar_width * 0.3),
      colour = ci_color, linewidth = 0.5
    )
  }
  if (label_style == "rich") {
    plt <- plt + ggtext::geom_richtext(
      data = label_data, ggplot2::aes(x = x, y = y, label = label),
      inherit.aes = FALSE, hjust = 0, vjust = 0, size = label_size,
      family = wjp_font_family(), fill = NA, label.color = NA,
      label.padding = grid::unit(c(0, 0, nudge_lab, 0), "mm")
    )
  } else {
    # geom_label supplies millimeter padding below the heading. The borderless
    # box is requested differently before and after ggplot2 4.0.0.
    no_border <- if (utils::packageVersion("ggplot2") >= "4.0.0") {
      list(border.colour = NA)
    } else {
      list(label.size = NA)
    }
    plt <- plt + do.call(ggplot2::geom_label, c(list(
      data = label_data, mapping = ggplot2::aes(x = x, y = y, label = label),
      inherit.aes = FALSE, hjust = 0, vjust = 0, size = label_size,
      lineheight = 1, family = wjp_font_family(), fill = NA,
      label.padding = grid::unit(c(0, 0, nudge_lab, 0), "mm")
    ), no_border))
  }
  if (paired) plt <- plt + ggplot2::geom_text(
    ggplot2::aes(x = -2, y = y, label = series),
    hjust = 1, size = value_size * 0.85, family = wjp_font_family(), colour = "#4a4a49"
  )
  if (show_values) plt <- plt + ggplot2::geom_text(
    ggplot2::aes(x = value_x, y = y, label = value_label),
    hjust = 0, size = value_size, family = wjp_font_family(),
    fontface = "bold", colour = "#4a4a49"
  )
  plt + ggplot2::scale_x_continuous(limits = c(if (paired) -max(10, max(nchar(series_levels)) * value_size * 0.7) else 0, xmax + right_room), expand = c(0, 0)) +
    ggplot2::scale_y_continuous(limits = c(min(d$ymin) - 0.3, 0.25), expand = c(0, 0)) +
    ggplot2::coord_cartesian(clip = "off") + ptheme +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(), panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor.x = ggplot2::element_blank(), panel.grid.minor.y = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_blank(), axis.text.y = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(margin_top, 20, 15, 10),
      plot.background = ggplot2::element_blank()
    ) + wjp_legend_theme(paired && show_legend)
}
