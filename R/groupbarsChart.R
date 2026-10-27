#' Plot a Grouped Stacked Bar Chart following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_groupbars()` creates a faceted horizontal stacked bar chart where bars are
#' grouped by categories and show a primary value (e.g., percentage) stacked with
#' its complement. Useful for displaying survey results broken down by demographic
#' groups like gender, age, income, etc.
#'
#' Values supplied to \code{target}, \code{national_value}, \code{ci_lower}, and
#' \code{ci_upper} can be provided as proportions (0-1) or percentages (0-100),
#' or on any other scale with \code{scale_max} (e.g., \code{scale_max = 10} for
#' a 0-10 mean). Internally they are plotted on a 0-100 percentage scale.
#' Confidence intervals can be supplied directly with \code{ci_lower} and
#' \code{ci_upper}, or computed from \code{sd} and \code{sample_size}. When
#' \code{show_national = TRUE}, use \code{national_style = "line"} to draw
#' \code{national_value} as a vertical reference line, or
#' \code{national_style = "bar"} to add it as a full bar row using the same
#' geometry, confidence interval, and label logic as the other rows. With
#' \code{national_style = "bar"}, \code{national_value} can hold several named
#' values (e.g., \code{c("National Average" = 68, "EU Average" = 49)}): each
#' becomes a reference row with the same style.
#'
#' @details
#' \strong{Group headers.} With \code{group_header = "strip"} (default) each
#' group is a facet with its title in a strip, as in earlier versions. With
#' \code{group_header = "row"} the chart is drawn in a single panel: each group
#' title is a header row in the label column, right-aligned with the
#' categories, and averages and highlighted levels are styled by
#' \code{highlight_fontface} and \code{highlight_colour}. This mode is the
#' layout of WJP country reports and accepts a \code{layout}.
#'
#' \strong{Value labels.} \code{label_position = "column"} aligns the values in
#' a column after the 100% track (\code{value_gap} points after it with a
#' \code{layout}); \code{"end"} places each value after its bar. Rows with a
#' missing value draw their text from \code{labels}, or \code{na_label} (e.g.,
#' \code{"N/A"}), in the value position.
#'
#' \strong{Geometry in points.} A [wjp_layout()] fixes the label column
#' (\code{label_width}, \code{label_gap}), the track (\code{track_width}), the
#' value column (\code{value_gap}, \code{value_width}), the row pitch and bar
#' height (\code{row_height}, \code{bar_height}), the header rows
#' (\code{header_height}, \code{header_baseline}), and the \code{margins}.
#' Supplying a \code{layout} selects \code{group_header = "row"}.
#'
#' @param data A data frame containing the data to be plotted.
#' @param target String. Column name containing the numeric values to plot. Values
#'   can be proportions (0-1) or percentages (0-100).
#' @param grouping String. Column name for the faceting variable (e.g., "Gender", "Age Group").
#' @param levels String. Column name for the categories within each group (e.g., "Male", "Female").
#' @param colors Character vector of length 2 with hex colors for primary and secondary bars.
#'   Default is c("#482d8b", "#e5e8e8").
#' @param labels String. Column name containing custom labels, printed as given.
#'   If NULL, percentages are auto-generated. Default is NULL.
#' @param group_order Character vector specifying the order of all facet groups.
#'   Default is NULL (uses data order).
#' @param level_order Named list where names are group values and values are character vectors
#'   specifying the order of levels within each group. Default is NULL (uses
#'   natural ascending order from top to bottom: A-Z and lower numbers first).
#'   Custom vectors are also interpreted from top to bottom.
#' @param show_national Logical. If TRUE, adds a vertical national average line
#'   and a rich text annotation by default, or a national average bar when
#'   \code{national_style = "bar"}. Default is FALSE.
#' @param national_value Numeric. The national average value to display when
#'   show_national is TRUE. With \code{national_style = "bar"}, a named vector
#'   draws one reference row per value, labeled with its name.
#' @param national_label String. Optional single rich text label for the national
#'   average annotation. If NULL, a label is generated from \code{national_value}.
#' @param national_style String. How to display the national value when
#'   \code{show_national = TRUE}: "line", "bar", or "none". Default is "line".
#' @param national_position String. Position of the national bar when
#'   \code{national_style = "bar"}: "top" or "bottom". Default is "top".
#' @param national_ci_lower Numeric. Optional lower confidence interval bound for
#'   the national bar. Uses the same 0-1 or 0-100 scale detection as \code{target}.
#' @param national_ci_upper Numeric. Optional upper confidence interval bound for
#'   the national bar. Uses the same 0-1 or 0-100 scale detection as \code{target}.
#' @param national_group_label String. Facet label used for the national bar.
#'   Default is " " to create a blank facet strip.
#' @param draw_ci Logical. If TRUE, draws a per-category confidence interval on each
#'   primary bar. Default is FALSE.
#' @param ci_lower String. Optional column name with precomputed lower confidence
#'   interval bounds. If supplied, \code{ci_upper} must also be supplied.
#' @param ci_upper String. Optional column name with precomputed upper confidence
#'   interval bounds. If supplied, \code{ci_lower} must also be supplied.
#' @param sd String. Column name with the standard deviation used to build the
#'   confidence interval when \code{ci_lower} and \code{ci_upper} are not supplied.
#'   Default is NULL.
#' @param sample_size String. Column name with the number of observations used to
#'   build the confidence interval when \code{ci_lower} and \code{ci_upper} are not
#'   supplied. Default is NULL.
#' @param ci_level Numeric. Confidence level for the interval. Default is 0.95.
#' @param ptheme A ggplot2 theme. Default is WJP_theme().
#' @param label_position String. Position for value labels: "end", "inside",
#'   "column", or "none". Default is "end".
#' @param label_after_ci Logical. If TRUE and confidence intervals are drawn,
#'   value labels are placed at the end of the full bar (after the gray
#'   complement), keeping them clear of the interval whiskers and aligned in
#'   a single column. If FALSE, labels are placed right after the primary bar
#'   value. Default is TRUE.
#' @param facet_ncol Integer. Number of facet columns. Default is 1.
#' @param bar_width Numeric. Width of bars. Default is 0.7.
#' @param show_axis Logical. If TRUE, displays the X axis with percentage breaks
#'   (0%, 25%, 50%, 75%, 100%) at the bottom. Default is FALSE.
#' @param strip_position String. Position of facet strip labels. In single-column
#'   layouts (`facet_ncol = 1`) both options render the group title as a horizontal
#'   header above each group; "top" uses a slightly larger header. In multi-column
#'   layouts, "left" places strips on the left and "top" above each panel.
#'   Default is "left".
#' @param national_var String. Value in the \code{grouping} column that identifies
#'   the national average row (e.g., "general", "Overall"). When specified, this row
#'   is displayed in a blank facet with a special formatted label (bold, italic,
#'   colored) drawn with \code{ggtext::geom_richtext()}. The value can be used as
#'   is in \code{group_order} and \code{level_order}. Default is NULL.
#' @param national_level String. Value in the \code{levels} column corresponding to
#'   the national average label (e.g., "National Average"). Required when
#'   \code{national_var} is specified. Default is NULL.
#' @param national_value_label Character vector with the printed text of each
#'   national value (e.g., `"4.9"` or `"68%"`). Default is NULL
#'   (rounded percentages).
#' @param scale_max Numeric. Maximum of the scale of \code{target},
#'   \code{national_value} and the confidence bounds (e.g., \code{10} for a 0-10
#'   mean). Default is NULL (proportions or percentages, detected from the data).
#' @param show_complement Logical. Draw the secondary (complement) bar up to
#'   100%. Default is TRUE.
#' @param na_label String. Text printed for rows with a missing value when
#'   \code{labels} gives none (e.g., \code{"N/A"}). Default is NULL (nothing).
#' @param value_gap Numeric. Distance, in points, between the end of the track
#'   (or of the bar) and the value labels in row mode. Default is 5.
#' @param value_size Numeric. Size of the value labels, in points. Default is
#'   NULL (14.2 in strip mode, 10 in row mode).
#' @param value_fontface String. Font face of the value labels. Default is
#'   "bold". Weight faces such as "semibold.italic" are accepted (see [wjp_fonts()]).
#' @param value_colour String. Color of the value labels. Default is NULL
#'   (the primary color).
#' @param label_size Numeric. Size of the category labels, in points. Default
#'   is NULL (13 in strip mode, 10 in row mode).
#' @param label_colour String. Color of the category labels. Default is NULL.
#' @param highlight_levels Character vector of levels whose labels are
#'   highlighted (averages are always highlighted). Default is NULL.
#' @param highlight_fontface String. Font face of highlighted labels and
#'   averages. Default is "bold".
#' @param highlight_colour String. Color of highlighted labels and averages.
#'   Default is NULL (the primary color).
#' @param group_header String. "strip" or "row". Default is NULL ("row" when a
#'   \code{layout} is supplied, "strip" otherwise). See Details.
#' @param header_fontface String. Font face of the group titles. Default is "bold".
#' @param header_colour String. Color of the group titles. Default is NULL (the
#'   primary color).
#' @param header_size Numeric. Size of the group titles, in points. Default is
#'   NULL (12 or 13 in strip mode, the label size in row mode).
#' @param xlim Numeric vector of length 2 with the limits of the value axis,
#'   in percentage units. Default is NULL (0-115, or 0-100 with
#'   \code{show_axis = TRUE}).
#' @param layout A [wjp_layout()] with the geometry of the chart in points.
#'   Default is NULL.
#'
#' @return A ggplot object representing the grouped stacked bar chart.
#' @export
#'
#' @examples
#' library(dplyr)
#' library(ggplot2)
#'
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Create sample data
#' data_groups <- data.frame(
#'   group = c("Gender", "Gender", "Age", "Age", "Age"),
#'   category = c("Male", "Female", "18-29", "30-49", "50+"),
#'   value = c(0.45, 0.52, 0.38, 0.48, 0.55)
#' )
#'
#' # Basic grouped bars
#' wjp_groupbars(
#'   data_groups,
#'   target   = "value",
#'   grouping = "group",
#'   levels   = "category"
#' )
#'
#' # With custom colors and group order
#' wjp_groupbars(
#'   data_groups,
#'   target      = "value",
#'   grouping    = "group",
#'   levels      = "category",
#'   colors      = c("#482d8b", "#e5e8e8"),
#'   group_order = c("Gender", "Age")
#' )
#'
#' # With a per-category confidence interval (requires sd + sample_size columns)
#' data_ci <- data.frame(
#'   group    = c("Gender", "Gender", "Age", "Age", "Age"),
#'   category = c("Male", "Female", "18-29", "30-49", "50+"),
#'   value    = c(0.45, 0.52, 0.38, 0.48, 0.55),
#'   sd       = c(0.50, 0.50, 0.49, 0.50, 0.50),
#'   n        = c(420, 460, 180, 510, 240)
#' )
#'
#' wjp_groupbars(
#'   data_ci,
#'   target      = "value",
#'   grouping    = "group",
#'   levels      = "category",
#'   draw_ci     = TRUE,
#'   sd          = "sd",
#'   sample_size = "n"
#' )
#'
#' # Percentage-scale input with precomputed confidence intervals and a general line
#' data_pct <- data.frame(
#'   group    = c("Gender", "Gender", "Age", "Age", "Age"),
#'   category = c("Men", "Women", "18-24", "25-54", "55+"),
#'   value    = c(74.4, 70.3, 72.1, 73.1, 73.0),
#'   lower    = c(72.4, 68.4, 70.1, 71.0, 70.8),
#'   upper    = c(76.4, 72.1, 74.5, 75.2, 75.2)
#' )
#'
#' wjp_groupbars(
#'   data_pct,
#'   target         = "value",
#'   grouping       = "group",
#'   levels         = "category",
#'   group_order    = c("Gender", "Age"),
#'   level_order    = list(
#'     Gender = c("Men", "Women"),
#'     Age    = c("18-24", "25-54", "55+")
#'   ),
#'   draw_ci        = TRUE,
#'   ci_lower       = "lower",
#'   ci_upper       = "upper",
#'   show_national  = TRUE,
#'   national_value = 72.3,
#'   national_label = "General"
#' )
#'
#' # National average as its own bar with its own confidence interval
#' wjp_groupbars(
#'   data_pct,
#'   target            = "value",
#'   grouping          = "group",
#'   levels            = "category",
#'   colors            = c("#482d8b", "#e5e8e8"),
#'   group_order       = c("Gender", "Age"),
#'   level_order       = list(
#'     Gender = c("Men", "Women"),
#'     Age    = c("18-24", "25-54", "55+")
#'   ),
#'   draw_ci           = TRUE,
#'   ci_lower          = "lower",
#'   ci_upper          = "upper",
#'   show_national     = TRUE,
#'   national_value    = 72.3,
#'   national_style    = "bar",
#'   national_label    = "National Average",
#'   national_ci_lower = 70.0,
#'   national_ci_upper = 74.6
#' )
#'
#' # With visible X axis (publication-style layout)
#' wjp_groupbars(
#'   data_pct,
#'   target            = "value",
#'   grouping          = "group",
#'   levels            = "category",
#'   colors            = c("#482d8b", "#e5e8e8"),
#'   group_order       = c("Gender", "Age"),
#'   level_order       = list(
#'     Gender = c("Men", "Women"),
#'     Age    = c("18-24", "25-54", "55+")
#'   ),
#'   draw_ci           = TRUE,
#'   ci_lower          = "lower",
#'   ci_upper          = "upper",
#'   show_national     = TRUE,
#'   national_value    = 72.3,
#'   national_style    = "bar",
#'   national_label    = "National Average",
#'   national_ci_lower = 70.0,
#'   national_ci_upper = 74.6,
#'   show_axis         = TRUE
#' )
#'
#' # Using national_var and national_level for inline national average formatting
#' data_disagg <- data.frame(
#'   disaggregation = c("general", "Age Group", "Age Group", "Gender", "Gender"),
#'   demographics   = c("National Average", "18-29", "50+", "Male", "Female"),
#'   pct_weighted   = c(0.75, 0.72, 0.78, 0.77, 0.73)
#' )
#'
#' wjp_groupbars(
#'   data_disagg,
#'   target         = "pct_weighted",
#'   grouping       = "disaggregation",
#'   levels         = "demographics",
#'   group_order    = c("general", "Age Group", "Gender"),
#'   national_var   = "general",
#'   national_level = "National Average"
#' )
#'
#' # Report layout: headers as rows, national and EU averages, a suppressed
#' # cell printed as "N/A", values in a column, geometry in points
#' # (fictional data)
#' report <- data.frame(
#'   group    = c("Gender", "Gender", "Age Group", "Age Group", "Age Group"),
#'   category = c("Male", "Female", "55+", "35-54", "18-34"),
#'   value    = c(65, 71, 61, NA, 70)
#' )
#' report$text <- ifelse(is.na(report$value), "N/A", paste0(report$value, "%"))
#'
#' wjp_groupbars(
#'   report,
#'   target               = "value",
#'   grouping             = "group",
#'   levels               = "category",
#'   labels               = "text",
#'   colors               = c("#575796", "#E5E8E8"),
#'   group_order          = c("Gender", "Age Group"),
#'   level_order          = list(Gender = c("Male", "Female"),
#'                               `Age Group` = c("55+", "35-54", "18-34")),
#'   show_national        = TRUE,
#'   national_style       = "bar",
#'   national_value       = c("National Average" = 68, "EU Average" = 49),
#'   national_value_label = c("68%", "49%"),
#'   label_position       = "column",
#'   value_size           = 9,
#'   value_fontface       = "bold.italic",
#'   highlight_fontface   = "bold.italic",
#'   header_fontface      = "bold.italic",
#'   label_colour         = "#1A1A1A",
#'   layout               = wjp_layout(
#'     label_width = 149, label_gap = 6, track_width = 250,
#'     value_gap = 5, value_width = 27, row_height = 15.5,
#'     bar_height = 13.5, header_height = 22, header_baseline = 17,
#'     margins = c(2, 0, 4, 0)
#'   )
#' )
#'

wjp_groupbars <- function(
    data,
    target,
    grouping,
    levels,
    colors         = c("#482d8b", "#e5e8e8"),
    labels         = NULL,
    group_order    = NULL,
    level_order    = NULL,
    show_national  = FALSE,
    national_value = NULL,
    draw_ci        = FALSE,
    ci_lower       = NULL,
    ci_upper       = NULL,
    sd             = NULL,
    sample_size    = NULL,
    ci_level       = 0.95,
    ptheme         = WJP_theme(),
    national_label = NULL,
    national_style = "line",
    national_position = "top",
    national_ci_lower = NULL,
    national_ci_upper = NULL,
    national_group_label = " ",
    label_position = "end",
    label_after_ci = TRUE,
    facet_ncol     = 1,
    bar_width      = 0.7,
    show_axis      = FALSE,
    strip_position = "left",
    national_var   = NULL,
    national_level = NULL,
    national_value_label = NULL,
    scale_max          = NULL,
    show_complement    = TRUE,
    na_label           = NULL,
    value_gap          = 5,
    value_size         = NULL,
    value_fontface     = "bold",
    value_colour       = NULL,
    label_size         = NULL,
    label_colour       = NULL,
    highlight_levels   = NULL,
    highlight_fontface = "bold",
    highlight_colour   = NULL,
    group_header       = NULL,
    header_fontface    = "bold",
    header_colour      = NULL,
    header_size        = NULL,
    xlim               = NULL,
    layout             = NULL
) {

  # ===========================================================================
  # 1. RENAME VARIABLES
  # ===========================================================================

  data <- data %>%
    dplyr::ungroup() %>%
    dplyr::rename(
      target_var   = dplyr::all_of(target),
      grouping_var = dplyr::all_of(grouping),
      levels_var   = dplyr::all_of(levels)
    )

  if (is.null(group_header)) {
    group_header <- if (is.null(layout)) "strip" else "row"
  }
  if (length(group_header) != 1 || !group_header %in% c("strip", "row")) {
    stop('`group_header` must be "strip" or "row".', call. = FALSE)
  }
  if (!is.null(layout) && group_header != "row") {
    stop('A `layout` requires `group_header = "row"`.', call. = FALSE)
  }
  row_mode <- group_header == "row"

  # Handle national_var: convert national grouping to empty space for facet
  use_national_richtext <- !is.null(national_var) && !is.null(national_level)
  national_group_empty <- " "

  if (use_national_richtext) {
    data <- data %>%
      dplyr::mutate(
        grouping_var = dplyr::if_else(
          grouping_var == national_var,
          national_group_empty,
          as.character(grouping_var)
        )
      )
  }

  numeric_arg <- function(x, arg) {
    raw_na <- is.na(x)
    if (is.factor(x)) {
      x <- as.character(x)
    }
    x <- suppressWarnings(as.numeric(x))
    if (any(!raw_na & is.na(x))) {
      stop(paste0(arg, " must contain numeric values."), call. = FALSE)
    }
    x
  }

  if (!is.null(scale_max)) {
    wjp_check_number(scale_max, "scale_max", 0, lower_open = TRUE)
  }

  value_to_pct <- function(x, arg) {
    x <- numeric_arg(x, arg)
    observed <- x[!is.na(x)]

    if (length(observed) == 0) {
      return(x)
    }
    if (any(!is.finite(observed))) {
      stop(paste0(arg, " must contain finite numeric values."), call. = FALSE)
    }
    if (!is.null(scale_max)) {
      if (any(observed < 0 | observed > scale_max)) {
        stop(paste0(arg, " must contain values between 0 and `scale_max` (", scale_max, ")."),
             call. = FALSE)
      }
      return(x / scale_max * 100)
    }
    if (any(observed < 0 | observed > 100)) {
      stop(paste0(arg, " must contain proportions (0-1) or percentages (0-100)."), call. = FALSE)
    }
    if (max(observed) <= 1) {
      x * 100
    } else {
      x
    }
  }

  format_pct <- function(x) {
    if (!is.null(scale_max) && scale_max != 100) {
      return(format(round(x * scale_max / 100, 1), nsmall = 1, trim = TRUE))
    }
    paste0(round(x, 0), "%")
  }

  natural_sort <- function(x) {
    x <- unique(as.character(x))
    x <- x[!is.na(x)]

    natural_key <- function(value) {
      normalized <- tolower(trimws(value))
      transliterated <- iconv(normalized, from = "", to = "ASCII//TRANSLIT")
      if (!is.na(transliterated)) {
        normalized <- transliterated
      }

      parts <- regmatches(
        normalized,
        gregexpr("[0-9]+(?:\\.[0-9]+)?|[^0-9]+", normalized, perl = TRUE)
      )[[1]]

      paste0(vapply(parts, function(part) {
        if (grepl("^[0-9]", part)) {
          sprintf("%030.10f", as.numeric(part))
        } else {
          part
        }
      }, character(1)), collapse = "")
    }

    keys <- vapply(x, natural_key, character(1))
    x[order(keys, tolower(x), method = "radix")]
  }

  # Handle labels

  if (is.null(labels)) {
    data <- data %>%
      dplyr::mutate(labels_var = NA_character_)
  } else {
    data <- data %>%
      dplyr::rename(labels_var = dplyr::all_of(labels)) %>%
      dplyr::mutate(labels_var = as.character(labels_var))
  }

  data <- data %>%
    dplyr::mutate(target_pct = value_to_pct(target_var, "`target`"))

  if (length(colors) != 2) {
    stop("`colors` must be a character vector of length 2.", call. = FALSE)
  }
  if (!label_position %in% c("end", "inside", "column", "none")) {
    stop('`label_position` must be one of "end", "inside", "column", or "none".', call. = FALSE)
  }
  if (length(facet_ncol) != 1 || !is.finite(facet_ncol) || facet_ncol < 1) {
    stop("`facet_ncol` must be a positive integer.", call. = FALSE)
  }
  facet_ncol <- as.integer(facet_ncol)
  if (length(bar_width) != 1 || !is.finite(bar_width) || bar_width <= 0 || bar_width > 1) {
    stop("`bar_width` must be a single number greater than 0 and no greater than 1.", call. = FALSE)
  }
  if (length(ci_level) != 1 || !is.finite(ci_level) || ci_level <= 0 || ci_level >= 1) {
    stop("`ci_level` must be a single number between 0 and 1.", call. = FALSE)
  }
  if (!national_style %in% c("line", "bar", "none")) {
    stop('`national_style` must be one of "line", "bar", or "none".', call. = FALSE)
  }
  if (!national_position %in% c("top", "bottom")) {
    stop('`national_position` must be one of "top" or "bottom".', call. = FALSE)
  }
  if (length(label_after_ci) != 1 || !is.logical(label_after_ci)) {
    stop("`label_after_ci` must be TRUE or FALSE.", call. = FALSE)
  }
  if (length(national_group_label) != 1) {
    stop("`national_group_label` must be a single string.", call. = FALSE)
  }
  if (length(show_axis) != 1 || !is.logical(show_axis)) {
    stop("`show_axis` must be TRUE or FALSE.", call. = FALSE)
  }
  if (length(show_complement) != 1 || !is.logical(show_complement) || is.na(show_complement)) {
    stop("`show_complement` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!strip_position %in% c("left", "top")) {
    stop('`strip_position` must be one of "left" or "top".', call. = FALSE)
  }
  if (!is.null(national_var) && is.null(national_level)) {
    stop("`national_level` must be provided when `national_var` is specified.", call. = FALSE)
  }
  if (is.null(national_var) && !is.null(national_level)) {
    stop("`national_var` must be provided when `national_level` is specified.", call. = FALSE)
  }
  if (!is.null(na_label) && (length(na_label) != 1 || !is.character(na_label))) {
    stop("`na_label` must be a single string.", call. = FALSE)
  }
  if (!is.null(xlim) && (!is.numeric(xlim) || length(xlim) != 2 || any(!is.finite(xlim)))) {
    stop("`xlim` must be a numeric vector of length 2.", call. = FALSE)
  }
  wjp_check_number(value_gap, "value_gap", 0)
  if (!is.null(value_size)) wjp_check_number(value_size, "value_size", 0, lower_open = TRUE)
  if (!is.null(label_size)) wjp_check_number(label_size, "label_size", 0, lower_open = TRUE)
  if (!is.null(header_size)) wjp_check_number(header_size, "header_size", 0, lower_open = TRUE)
  if (is.null(value_colour)) value_colour <- colors[1]
  if (is.null(highlight_colour)) highlight_colour <- colors[1]
  if (is.null(header_colour)) header_colour <- colors[1]

  # ===========================================================================
  # HELPER FUNCTION: Calculate position for national average label

  # ===========================================================================

  calculate_national_label_position <- function(data2plot,
                                                 national_group,
                                                 national_level_val,
                                                 group_levels,
                                                 level_order,
                                                 colors_primary,
                                                 label_text) {
    # Build the y_id for national average
    national_y_id <- paste(national_group, national_level_val, sep = " | ")

    # Check if it exists in the data
    if (!national_y_id %in% level_order) {
      warning("`national_level` was not found in the `levels` column.", call. = FALSE)
      return(NULL)
    }

    # Create data.frame for geom_richtext
    # x = 0 (start of bar)
    # y = the corresponding factor level
    # hjust = 1.02 so text ends just before the bar
    label_df <- data.frame(
      grouping_var = factor(national_group, levels = group_levels),
      x = 0,
      y_id = factor(national_y_id, levels = level_order),
      label = paste0(
        "<b><i><span style='color:", colors_primary, "'>", label_text, "</span></i></b>"
      ),
      stringsAsFactors = FALSE
    )

    return(label_df)
  }

  national_value_pct <- NULL
  national_ci_lower_pct <- NULL
  national_ci_upper_pct <- NULL
  national_names <- NULL
  if (isTRUE(show_national) && national_style != "none") {
    if (is.null(national_value)) {
      stop("`national_value` must be provided when show_national = TRUE.", call. = FALSE)
    }
    multi_national <- length(national_value) > 1
    if (multi_national && national_style != "bar") {
      stop('Several `national_value` values require `national_style = "bar"`.', call. = FALSE)
    }
    if (multi_national && (is.null(names(national_value)) || any(!nzchar(names(national_value))))) {
      stop("Several `national_value` values must be named (the names are the row labels).",
           call. = FALSE)
    }
    if (!is.numeric(national_value) || length(national_value) < 1 || any(!is.finite(national_value))) {
      stop("`national_value` must contain finite numbers.", call. = FALSE)
    }
    upper_bound <- if (is.null(scale_max)) 100 else scale_max
    if (any(national_value < 0 | national_value > upper_bound)) {
      if (is.null(scale_max)) {
        stop("`national_value` must be a single proportion (0-1) or percentage (0-100).", call. = FALSE)
      }
      stop("`national_value` must be between 0 and `scale_max`.", call. = FALSE)
    }
    national_value_pct <- if (!is.null(scale_max)) {
      national_value / scale_max * 100
    } else {
      ifelse(national_value <= 1, national_value * 100, national_value)
    }
    if (!is.null(names(national_value)) && all(nzchar(names(national_value)))) {
      national_names <- names(national_value)
    }
    if (!is.null(national_label) && length(national_label) != 1) {
      stop("`national_label` must be a single string.", call. = FALSE)
    }
    if (!is.null(national_value_label) && length(national_value_label) != length(national_value)) {
      stop("`national_value_label` must have one label per `national_value`.", call. = FALSE)
    }
    if (!is.null(national_ci_lower) || !is.null(national_ci_upper)) {
      if (is.null(national_ci_lower) || is.null(national_ci_upper)) {
        stop("`national_ci_lower` and `national_ci_upper` must both be provided.", call. = FALSE)
      }
      if (length(national_ci_lower) != length(national_value) ||
          length(national_ci_upper) != length(national_value)) {
        stop("`national_ci_lower` and `national_ci_upper` must be single numeric values.", call. = FALSE)
      }
      national_ci_lower_pct <- value_to_pct(national_ci_lower, "`national_ci_lower`")
      national_ci_upper_pct <- value_to_pct(national_ci_upper, "`national_ci_upper`")
      if (any(national_ci_lower_pct > national_ci_upper_pct)) {
        stop("`national_ci_lower` must be less than or equal to `national_ci_upper`.", call. = FALSE)
      }
    }
  }

  # ===========================================================================
  # 2. PREPARE DATA FOR STACKED BARS
  # ===========================================================================

  # Build per-category confidence interval (normal approximation)
  if (draw_ci) {
    if (!is.null(ci_lower) || !is.null(ci_upper)) {
      if (is.null(ci_lower) || is.null(ci_upper)) {
        stop("`ci_lower` and `ci_upper` must both be provided when using precomputed intervals.", call. = FALSE)
      }
      data <- data %>%
        dplyr::rename(
          ci_lower_var = dplyr::all_of(ci_lower),
          ci_upper_var = dplyr::all_of(ci_upper)
        ) %>%
        dplyr::mutate(
          lower = pmax(0, value_to_pct(ci_lower_var, "`ci_lower`")),
          upper = pmin(100, value_to_pct(ci_upper_var, "`ci_upper`"))
        )
    } else {
      if (is.null(sd) || is.null(sample_size)) {
        stop(
          "`ci_lower` and `ci_upper`, or `sd` and `sample_size`, must be provided when draw_ci = TRUE.",
          call. = FALSE
        )
      }
      z <- stats::qnorm(1 - (1 - ci_level) / 2)
      data <- data %>%
        dplyr::rename(
          sd_var          = dplyr::all_of(sd),
          sample_size_var = dplyr::all_of(sample_size)
        ) %>%
        dplyr::mutate(
          sd_pct          = value_to_pct(sd_var, "`sd`"),
          sample_size_var = numeric_arg(sample_size_var, "`sample_size`")
        )

      if (any(!is.na(data$sample_size_var) & (!is.finite(data$sample_size_var) | data$sample_size_var <= 0))) {
        stop("`sample_size` must contain positive finite values.", call. = FALSE)
      }

      data <- data %>%
        dplyr::mutate(
          se    = sd_pct / sqrt(sample_size_var),
          lower = pmax(0, target_pct - z * se),
          upper = pmin(100, target_pct + z * se)
        )
    }

    if (any(!is.na(data$lower) & !is.na(data$upper) & data$lower > data$upper)) {
      stop("Confidence interval lower bounds must be less than or equal to upper bounds.", call. = FALSE)
    }
  }

  national_is_bar <- isTRUE(show_national) && national_style == "bar"
  national_is_line <- isTRUE(show_national) && national_style == "line"

  # Store national bar labels for later use in axis styling
  national_bar_label <- NULL

  if (national_is_bar) {
    national_bar_label <- if (!is.null(national_names)) {
      national_names
    } else if (is.null(national_label)) {
      "National Average"
    } else {
      as.character(national_label)
    }

    national_row <- data.frame(
      target_var   = national_value_pct,
      grouping_var = national_group_label,
      levels_var   = national_bar_label,
      labels_var   = if (is.null(national_value_label)) NA_character_ else as.character(national_value_label),
      target_pct   = national_value_pct,
      lower        = if (!is.null(national_ci_lower_pct)) national_ci_lower_pct else NA_real_,
      upper        = if (!is.null(national_ci_upper_pct)) national_ci_upper_pct else NA_real_,
      stringsAsFactors = FALSE
    )
    if (!is.null(national_names) || length(national_value) > 1) {
      national_row$target_var <- unname(national_value)
    } else {
      national_row$target_var <- national_value
    }

    data <- if (national_position == "top") {
      dplyr::bind_rows(national_row, data)
    } else {
      dplyr::bind_rows(data, national_row)
    }
  }

  # Labels of rows with a missing value: the `labels` text, else `na_label`
  na_text <- if (is.null(na_label)) NA_character_ else na_label

  # ===========================================================================
  # ROW MODE: a single panel with header rows and fixed geometry
  # ===========================================================================

  if (row_mode) {
    return(wjp_groupbars_rows(
      data = data, colors = colors, group_order = group_order,
      level_order = level_order, natural_sort = natural_sort,
      national_is_bar = national_is_bar, national_is_line = national_is_line,
      national_group_label = national_group_label, national_bar_label = national_bar_label,
      national_value_pct = national_value_pct, national_label = national_label,
      national_value_label = national_value_label, national_position = national_position,
      use_national_richtext = use_national_richtext, national_group_empty = national_group_empty,
      national_var = national_var, national_level = national_level,
      draw_ci = draw_ci, label_position = label_position, label_after_ci = label_after_ci,
      format_pct = format_pct, na_text = na_text, show_complement = show_complement,
      show_axis = show_axis, value_gap = value_gap, value_size = value_size,
      value_fontface = value_fontface, value_colour = value_colour,
      label_size = label_size, label_colour = label_colour,
      highlight_levels = highlight_levels, highlight_fontface = highlight_fontface,
      highlight_colour = highlight_colour, header_fontface = header_fontface,
      header_colour = header_colour, header_size = header_size,
      xlim = xlim, layout = layout, ptheme = ptheme
    ))
  }

  # Create stacked data (primary + secondary = 100%)
  data2plot <- data %>%
    dplyr::mutate(
      primary   = target_pct,
      secondary = 100 - target_pct
    ) %>%
    tidyr::pivot_longer(
      cols      = c(primary, secondary),
      names_to  = "color_type",
      values_to = "value"
    ) %>%
    dplyr::mutate(
      # Generate percentage labels for primary bars only
      label_value = dplyr::if_else(
        color_type == "primary",
        dplyr::if_else(
          is.na(value),
          if (is.na(na_text)) "NA" else na_text,
          format_pct(value)
        ),
        NA_character_
      ),
      # Use custom labels if provided
      label_value = dplyr::if_else(
        !is.na(labels_var) & color_type == "primary",
        labels_var,
        label_value
      ),
      label_x = dplyr::case_when(
        color_type != "primary" ~ NA_real_,
        label_position == "inside" ~ pmax(0, value - 2),
        label_position == "column" ~ 101,
        is.na(value) & (!is.na(labels_var) | !is.na(na_text)) ~ 1,
        TRUE ~ pmin(113, value + 1)
      )
    )

  if (draw_ci && label_position == "end" && isTRUE(label_after_ci)) {
    # Place value labels at the end of the full bar (after the gray
    # complement) so they stay clear of the interval whiskers and align
    # in a single column.
    data2plot <- data2plot %>%
      dplyr::mutate(
        label_x = dplyr::if_else(
          color_type == "primary",
          101,
          NA_real_
        )
      )
  }

  # ===========================================================================
  # 3. APPLY ORDERING
  # ===========================================================================

  # The national row is drawn in a blank facet; accept its original
  # `national_var` value in `group_order` and `level_order`
  if (use_national_richtext) {
    if (!is.null(group_order)) {
      group_order[group_order == national_var] <- national_group_empty
    }
    if (!is.null(level_order)) {
      names(level_order)[names(level_order) == national_var] <- national_group_empty
    }
  }

  # Order groups (facets)
  if (!is.null(group_order)) {
    if (national_is_bar) {
      group_order <- if (national_position == "top") {
        unique(c(national_group_label, group_order))
      } else {
        unique(c(group_order, national_group_label))
      }
    }
    missing_groups <- setdiff(unique(as.character(data2plot$grouping_var)), group_order)
    if (length(missing_groups) > 0) {
      stop("`group_order` must include all values from `grouping`.", call. = FALSE)
    }
    data2plot <- data2plot %>%
      dplyr::mutate(
        grouping_var = factor(grouping_var, levels = group_order)
      )
  }

  # Create y-axis identifier combining group and level
  data2plot <- data2plot %>%
    dplyr::mutate(
      y_id = paste(grouping_var, levels_var, sep = " | ")
    )

  # Order levels within groups
  if (!is.null(level_order)) {
    # Build ordered levels vector
    all_levels <- character(0)

    for (grp in names(level_order)) {
      lvls <- level_order[[grp]]
      # ggplot2 stores discrete y levels bottom-to-top; reverse the requested
      # vector so callers can specify the intuitive visual order top-to-bottom.
      all_levels <- c(all_levels, paste(grp, rev(lvls), sep = " | "))
    }

    # Add any remaining levels not specified
    existing_ids <- unique(data2plot$y_id)
    remaining <- setdiff(existing_ids, all_levels)
    all_levels <- c(all_levels, remaining)

    data2plot <- data2plot %>%
      dplyr::mutate(y_id = factor(y_id, levels = all_levels))
  } else {
    # Sort categories naturally within each group. Discrete y-axis levels are
    # stored bottom-to-top, so reverse each ascending vector to display A-Z and
    # lower numbers first from top to bottom.
    group_vec <- unique(as.character(data2plot$grouping_var))
    level_vec <- unlist(lapply(group_vec, function(grp) {
      group_rows <- as.character(data2plot$grouping_var) == grp
      group_levels <- natural_sort(data2plot$levels_var[group_rows])
      if (national_is_bar && identical(grp, national_group_label)) {
        group_levels <- unique(data2plot$levels_var[group_rows])
      }
      paste(grp, rev(group_levels), sep = " | ")
    }), use.names = FALSE)
    data2plot <- data2plot %>%
      dplyr::mutate(y_id = factor(y_id, levels = level_vec))
  }

  # ===========================================================================
  # 4. CREATE COLOR VECTOR
  # ===========================================================================

  cvec <- c("primary" = colors[1],
            "secondary" = if (show_complement) colors[2] else "transparent")

  national_label_data <- NULL
  if (national_is_line) {
    national_group <- if (!is.null(group_order)) {
      available_groups <- group_order[group_order %in% as.character(data2plot$grouping_var)]
      if (length(available_groups) > 0) {
        available_groups[1]
      } else {
        as.character(unique(data2plot$grouping_var))[1]
      }
    } else {
      as.character(unique(data2plot$grouping_var))[1]
    }

    national_y_levels <- data2plot$y_id[as.character(data2plot$grouping_var) == national_group]
    national_top_y <- tail(levels(droplevels(national_y_levels)), 1)
    national_y <- paste(national_group, ".national_average", sep = " | ")
    y_levels <- levels(data2plot$y_id)
    y_levels <- append(y_levels, national_y, after = match(national_top_y, y_levels))
    data2plot <- data2plot %>%
      dplyr::mutate(y_id = factor(as.character(y_id), levels = y_levels))

    national_value_text <- if (is.null(national_value_label)) {
      paste0(round(national_value_pct, 0), "%")
    } else {
      national_value_label
    }
    if (is.null(national_label)) {
      national_label <- paste0(
        "<b>National Average</b><br>",
        national_value_text
      )
    } else if (!grepl("<|%|\\n|<br", national_label)) {
      national_label <- paste0("<b>", national_label, "</b><br>", national_value_text)
    }

    national_label_data <- data.frame(
      grouping_var = national_group,
      y_id         = national_y,
      x            = national_value_pct,
      label        = national_label,
      hjust        = dplyr::case_when(
        national_value_pct <= 15 ~ 0,
        national_value_pct >= 85 ~ 1,
        TRUE                  ~ 0.5
      )
    )

    if (is.factor(data2plot$grouping_var)) {
      national_label_data$grouping_var <- factor(
        national_label_data$grouping_var,
        levels = levels(data2plot$grouping_var)
      )
    }
    national_label_data$y_id <- factor(national_label_data$y_id, levels = levels(data2plot$y_id))
  }

  # ===========================================================================
  # 5. CREATE PLOT
  # ===========================================================================

  # Label styles: national bars and highlighted levels use rich text
  md_face <- function(txt, face, colour) {
    open <- switch(face, bold = "<b>", italic = "<i>", bold.italic = "<b><i>",
                   semibold = "<b>", semibold.italic = "<b><i>", medium = "",
                   medium.italic = "<i>", "")
    close <- switch(face, bold = "</b>", italic = "</i>", bold.italic = "</i></b>",
                    semibold = "</b>", semibold.italic = "</i></b>", medium = "",
                    medium.italic = "</i>", "")
    paste0(open, "<span style='color:", colour, "'>", txt, "</span>", close)
  }
  highlighted <- unique(c(highlight_levels, if (national_is_bar) national_bar_label))
  use_markdown <- length(highlighted) > 0 && requireNamespace("ggtext", quietly = TRUE)
  legacy_national_style <- national_is_bar && is.null(highlight_levels) &&
    identical(highlight_fontface, "bold") && identical(highlight_colour, colors[1])

  plt <- ggplot2::ggplot(
    data2plot,
    ggplot2::aes(x = value, y = y_id, fill = color_type)
  ) +
    ggplot2::geom_col(
      position = ggplot2::position_stack(reverse = TRUE),
      width    = bar_width,
      na.rm    = TRUE
    ) +
    ggplot2::scale_fill_manual(values = cvec) +
    ggplot2::scale_x_continuous(
      expand   = c(0, 0),
      limits   = if (!is.null(xlim)) xlim else c(0, if (show_axis) 100 else 115),
      breaks   = if (show_axis) c(0, 25, 50, 75, 100) else ggplot2::waiver(),
      labels   = if (show_axis) function(x) paste0(x, "%") else ggplot2::waiver(),
      position = if (show_axis) "bottom" else "top",
      oob      = scales::oob_keep
    ) +
    ggplot2::scale_y_discrete(
      labels = function(x) {
        label <- sub("^.* \\| ", "", x)
        label <- ifelse(label == ".national_average", "", label)
        # Hide national_level when using national_var (will be shown via geom_richtext)
        if (use_national_richtext) {
          label <- ifelse(label == national_level, "", label)
        }
        # Color national bar labels and highlighted levels if ggtext is available
        if (use_markdown) {
          if (legacy_national_style) {
            label <- ifelse(
              label %in% national_bar_label,
              paste0("<b><span style='color:", colors[1], "'>", label, "</span></b>"),
              label
            )
          } else {
            label <- ifelse(
              label %in% highlighted,
              md_face(label, highlight_fontface, highlight_colour),
              label
            )
          }
        }
        label
      }
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(x = "", y = "")

  if (facet_ncol == 1) {
    # Single-column layouts always place the group title as a horizontal
    # header above each group (switched strips styled via theme below);
    # unswitched row strips would render rotated and clipped on the right.
    plt <- plt +
      ggplot2::facet_grid(
        rows   = ggplot2::vars(grouping_var),
        scales = "free",
        space  = "free_y",
        switch = "y"
      )
  } else {
    plt <- plt +
      ggplot2::facet_wrap(
        ggplot2::vars(grouping_var),
        scales = "free_y",
        ncol   = facet_ncol,
        strip.position = if (strip_position == "top") "top" else "left"
      )
  }

  if (label_position != "none") {
    vface <- wjp_face(value_fontface)
    plt <- plt +
      ggplot2::geom_text(
        ggplot2::aes(x = label_x, label = label_value),
        family   = vface$family,
        fontface = vface$fontface,
        color    = if (label_position == "inside") "#ffffff" else value_colour,
        hjust    = if (label_position == "inside") 1 else 0,
        size     = if (is.null(value_size)) 5 else wjp_pt_text(value_size),
        na.rm    = TRUE
      )
  }

  if (national_is_line) {
    plt <- plt +
      ggplot2::geom_vline(
        xintercept = national_value_pct,
        linetype   = "dashed",
        color      = colors[1],
        linewidth  = 0.7,
        inherit.aes = FALSE
      )

    if (requireNamespace("ggtext", quietly = TRUE)) {
      plt <- plt +
        ggtext::geom_richtext(
          data = national_label_data,
          ggplot2::aes(x = x, y = y_id, label = label, hjust = hjust),
          inherit.aes   = FALSE,
          family        = wjp_font_family(),
          fontface      = "plain",
          color         = colors[1],
          fill          = NA,
          label.color   = NA,
          label.padding = grid::unit(c(1.5, 1.5, 1.5, 1.5), "mm"),
          size          = 3.5,
          vjust         = 0.5
        )
    } else {
      plt <- plt +
        ggplot2::geom_text(
          data = national_label_data,
          ggplot2::aes(
            x     = x,
            y     = y_id,
            label = gsub("<[^>]+>", "", gsub("<br\\s*/?>", "\n", label)),
            hjust = hjust
          ),
          inherit.aes = FALSE,
          family      = wjp_font_family(),
          fontface    = "plain",
          color       = colors[1],
          size        = 3.5,
          vjust       = 0.5
        )
    }
  }

  # Overlay the confidence interval on each primary bar
  if (draw_ci) {
    plt <- plt +
      ggplot2::geom_errorbar(
        data = dplyr::filter(data2plot, color_type == "primary"),
        ggplot2::aes(y = y_id, xmin = lower, xmax = upper),
        orientation = "y",
        inherit.aes = FALSE,
        width       = 0.25,
        linewidth   = 0.6,
        color       = "#4a4a4a",
        na.rm       = TRUE
      )
  }

  # Add richtext label for national average when national_var is specified
  if (use_national_richtext && requireNamespace("ggtext", quietly = TRUE)) {
    # Get group levels and level order from the plot data
    group_levels_vec <- levels(data2plot$grouping_var)
    if (is.null(group_levels_vec)) {
      group_levels_vec <- unique(as.character(data2plot$grouping_var))
    }
    level_order_vec <- levels(data2plot$y_id)
    if (is.null(level_order_vec)) {
      level_order_vec <- unique(as.character(data2plot$y_id))
    }

    # Calculate position for national label
    national_richtext_df <- calculate_national_label_position(
      data2plot         = data2plot,
      national_group    = national_group_empty,
      national_level_val = national_level,
      group_levels      = group_levels_vec,
      level_order       = level_order_vec,
      colors_primary    = colors[1],
      label_text        = national_level
    )

    if (!is.null(national_richtext_df)) {
      plt <- plt +
        ggtext::geom_richtext(
          data        = national_richtext_df,
          ggplot2::aes(x = x, y = y_id, label = label),
          inherit.aes = FALSE,
          hjust       = 1.02,
          vjust       = 0.5,
          fill        = NA,
          label.color = NA,
          size        = 4.5,
          family      = wjp_font_family()
        )
    }
  }

  # ===========================================================================
  # 6. APPLY THEME
  # ===========================================================================

  # Base theme adjustments

  theme_base <- ggplot2::theme(
    strip.placement      = "outside",
    strip.background     = ggplot2::element_blank(),
    axis.title.x         = ggplot2::element_blank(),
    axis.title.y         = ggplot2::element_blank(),
    panel.grid.major.y   = ggplot2::element_blank(),
    panel.grid.major.x   = ggplot2::element_blank(),
    panel.grid.minor.x   = ggplot2::element_blank(),
    panel.spacing        = grid::unit(8, "mm"),
    strip.clip           = "off",
    legend.position      = "none"
  )

  # Axis X styling based on show_axis
  if (show_axis) {
    theme_axis <- ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        size   = 6.5,
        family = wjp_font_family(),
        face   = "plain",
        color  = "#4a4a4a"
      ),
      axis.ticks.x = ggplot2::element_line(color = "#d0d0d0", linewidth = 0.3),
      axis.ticks.length.x = grid::unit(2, "mm")
    )
  } else {
    theme_axis <- ggplot2::theme(
      axis.text.x = ggplot2::element_blank()
    )
  }

  # Axis Y styling - use element_markdown if ggtext available and a national
  # bar or highlighted levels exist
  axis_size <- if (is.null(label_size)) 13 else label_size
  if (use_markdown) {
    theme_axis_y <- ggplot2::theme(
      axis.text.y = ggtext::element_markdown(
        size   = axis_size,
        hjust  = 1,
        family = wjp_font_family(),
        colour = label_colour
      )
    )
  } else {
    theme_axis_y <- ggplot2::theme(
      axis.text.y = ggplot2::element_text(
        size   = axis_size,
        hjust  = 1,
        family = wjp_font_family(),
        face   = "plain",
        colour = label_colour
      )
    )
  }

  # Strip styling based on strip_position
  hface <- wjp_face(header_fontface)
  if (strip_position == "top") {
    theme_strip <- ggplot2::theme(
      # facet_wrap top strips (multi-column layouts)
      strip.text.x = ggplot2::element_text(
        size   = if (is.null(header_size)) 13 else header_size,
        color  = header_colour,
        hjust  = 0,
        family = hface$family,
        face   = hface$fontface
      ),
      # facet_grid switched strips shown as horizontal group headers
      # (single-column layouts)
      strip.text.y.left = ggplot2::element_text(
        angle  = 0,
        size   = if (is.null(header_size)) 13 else header_size,
        color  = header_colour,
        hjust  = 0,
        vjust  = 1,
        family = hface$family,
        face   = hface$fontface,
        margin = ggplot2::margin(0, -15, 0, 0)
      ),
      strip.switch.pad.grid = grid::unit(-6, "mm"),
      plot.margin = ggplot2::margin(10, 35, 10, 10)
    )
  } else {
    theme_strip <- ggplot2::theme(
      strip.text.y.left = ggplot2::element_text(
        angle  = 0,
        size   = if (is.null(header_size)) 12 else header_size,
        color  = header_colour,
        hjust  = 0,
        vjust  = 1,
        family = hface$family,
        face   = hface$fontface,
        margin = ggplot2::margin(0, -15, 0, 0)
      ),
      strip.switch.pad.grid = grid::unit(-6, "mm"),
      plot.margin = ggplot2::margin(10, 35, 10, 10)
    )
  }

  plt <- plt +
    ptheme +
    theme_base +
    theme_axis +
    theme_axis_y +
    theme_strip
  plt <- wjp_apply_ptheme(plt, ptheme)

  return(plt)
}


#' Grouped bars in a single panel with header rows (row mode)
#'
#' Internal renderer of `wjp_groupbars(group_header = "row")`: one line per
#' reference row, group header, and level, from the top; bars, tracks,
#' intervals, values, and labels are layers in one panel, so every label can
#' have its own style without rich text, and the geometry can be fixed in
#' points with a layout.
#'
#' @noRd
wjp_groupbars_rows <- function(data, colors, group_order, level_order, natural_sort,
                               national_is_bar, national_is_line, national_group_label,
                               national_bar_label, national_value_pct, national_label,
                               national_value_label, national_position,
                               use_national_richtext, national_group_empty,
                               national_var, national_level, draw_ci, label_position,
                               label_after_ci, format_pct, na_text, show_complement,
                               show_axis, value_gap, value_size, value_fontface,
                               value_colour, label_size, label_colour, highlight_levels,
                               highlight_fontface, highlight_colour, header_fontface,
                               header_colour, header_size, xlim, layout, ptheme) {
  use_layout <- !is.null(layout)
  lay <- wjp_layout_resolve(layout, list(
    label_width = 149, label_gap = 6, track_width = 250, value_gap = value_gap,
    value_width = 27, row_height = 15.5, bar_height = 13.5, header_height = 22,
    header_baseline = 17, margins = c(2, 0, 4, 0)
  ))
  if (!use_layout) {
    lay$margins <- c(10, 10, 10, 10)
  }
  label_size_pt  <- if (is.null(label_size)) 10 else label_size
  value_size_pt  <- if (is.null(value_size)) 10 else value_size
  header_size_pt <- if (is.null(header_size)) label_size_pt else header_size
  if (is.null(label_colour)) label_colour <- "#1A1A1A"

  # Which rows are averages (reference rows)
  data$grouping_var <- as.character(data$grouping_var)
  data$levels_var <- as.character(data$levels_var)
  avg_group <- if (national_is_bar) {
    national_group_label
  } else if (use_national_richtext) {
    national_group_empty
  } else {
    NA_character_
  }
  data$is_avg <- !is.na(avg_group) & data$grouping_var == avg_group

  if (use_national_richtext) {
    if (!is.null(group_order)) group_order[group_order == national_var] <- national_group_empty
    if (!is.null(level_order)) names(level_order)[names(level_order) == national_var] <- national_group_empty
  }

  groups <- unique(data$grouping_var[!data$is_avg])
  if (!is.null(group_order)) {
    group_order <- group_order[group_order != avg_group | is.na(avg_group)]
    missing_groups <- setdiff(groups, group_order)
    if (length(missing_groups) > 0) {
      stop("`group_order` must include all values from `grouping`.", call. = FALSE)
    }
    groups <- group_order[group_order %in% groups]
  }
  level_seq <- function(grp) {
    rows <- data$grouping_var == grp
    if (!is.null(level_order) && grp %in% names(level_order)) {
      lv <- level_order[[grp]]
      c(lv, setdiff(unique(data$levels_var[rows]), lv))
    } else {
      natural_sort(data$levels_var[rows])
    }
  }

  # Lines from the top: averages, then a header and the levels of each group
  avg_rows <- data[data$is_avg, , drop = FALSE]
  avg_lines <- if (nrow(avg_rows) > 0) {
    avg_levels <- if (use_national_richtext) level_seq(avg_group) else unique(avg_rows$levels_var)
    data.frame(kind = "avg", group = avg_group, label = avg_levels, stringsAsFactors = FALSE)
  } else {
    NULL
  }
  body <- do.call(rbind, lapply(groups, function(grp) {
    rbind(data.frame(kind = "header", group = grp, label = grp, stringsAsFactors = FALSE),
          data.frame(kind = "row", group = grp, label = level_seq(grp), stringsAsFactors = FALSE))
  }))
  lines <- if (national_is_bar && national_position == "bottom") {
    rbind(body, avg_lines)
  } else {
    rbind(avg_lines, body)
  }
  n <- nrow(lines)

  # Values of each line
  key <- paste(data$grouping_var, data$levels_var, sep = " | ")
  idx <- match(paste(lines$group, lines$label, sep = " | "), key)
  lines$value <- data$target_pct[idx]
  lines$text <- data$labels_var[idx]
  lines$lower <- if ("lower" %in% names(data)) data$lower[idx] else NA_real_
  lines$upper <- if ("upper" %in% names(data)) data$upper[idx] else NA_real_
  is_head <- lines$kind == "header"
  lines$text <- ifelse(is_head, NA_character_,
                       ifelse(!is.na(lines$text), lines$text,
                              ifelse(is.na(lines$value), na_text, format_pct(lines$value))))
  lines$highlight <- lines$kind == "avg" | lines$label %in% highlight_levels

  # Vertical geometry (points with a layout; rows of 1 unit otherwise)
  unit_pt <- if (use_layout) 1 else 1 / lay$row_height
  h <- ifelse(is_head, lay$header_height, lay$row_height)
  top <- lay$inset[1] + c(0, cumsum(h)[-n])
  total <- sum(h) + sum(lay$inset)
  ctr <- ifelse(is_head,
                top + lay$header_baseline - WJP_CAP_HALF_EM * header_size_pt,
                top + lay$row_height / 2)
  lines$y <- (total - ctr) * unit_pt
  half_bar <- lay$bar_height / 2 * unit_pt
  y_max <- total * unit_pt

  # Horizontal geometry: 0-100 track, value column after it
  ppu <- lay$track_width / 100
  if (!is.null(xlim)) {
    x_limits <- xlim
  } else if (use_layout) {
    x_limits <- c(0, 100 * (lay$track_width + lay$value_gap + lay$value_width) / lay$track_width)
  } else {
    x_limits <- c(0, if (show_axis) 100 else 115)
  }
  gap_units <- if (use_layout) lay$value_gap / ppu else 1

  bars <- lines[!is_head & !is.na(lines$value), , drop = FALSE]
  bars$ymin <- bars$y - half_bar
  bars$ymax <- bars$y + half_bar

  plt <- ggplot2::ggplot()
  if (show_complement && nrow(bars) > 0) {
    plt <- plt + ggplot2::geom_rect(
      data = bars,
      ggplot2::aes(xmin = 0, xmax = 100, ymin = ymin, ymax = ymax),
      fill = colors[2], colour = NA
    )
  }
  if (nrow(bars) > 0) {
    plt <- plt + ggplot2::geom_rect(
      data = bars,
      ggplot2::aes(xmin = 0, xmax = pmin(pmax(value, 0), 100), ymin = ymin, ymax = ymax),
      fill = colors[1], colour = NA
    )
  }

  if (draw_ci) {
    ci <- bars[!is.na(bars$lower) & !is.na(bars$upper), , drop = FALSE]
    if (nrow(ci) > 0) {
      plt <- plt + ggplot2::geom_errorbar(
        data = ci,
        ggplot2::aes(y = y, xmin = lower, xmax = upper),
        orientation = "y", width = half_bar, linewidth = 0.6, colour = "#4a4a4a"
      )
    }
  }

  if (national_is_line) {
    line_label <- national_label
    value_text <- if (is.null(national_value_label)) paste0(round(national_value_pct, 0), "%") else national_value_label
    if (is.null(line_label)) {
      line_label <- paste0("National Average\n", value_text)
    } else if (!grepl("%|\n", line_label)) {
      line_label <- paste0(line_label, "\n", value_text)
    }
    line_label <- gsub("<[^>]+>", "", gsub("<br\\s*/?>", "\n", line_label))
    plt <- plt +
      ggplot2::geom_segment(
        data = data.frame(x = national_value_pct, y0 = 0, y1 = y_max),
        ggplot2::aes(x = x, xend = x, y = y0, yend = y1),
        linetype = "dashed", colour = colors[1], linewidth = 0.7
      ) +
      ggplot2::geom_text(
        data = data.frame(x = national_value_pct, y = y_max, label = line_label),
        ggplot2::aes(x = x, y = y, label = label),
        vjust = -0.3, colour = colors[1], family = wjp_font_family(),
        size = wjp_pt_text(label_size_pt), lineheight = 1
      )
  }

  # Value labels
  if (label_position != "none") {
    vals <- lines[!is_head & !is.na(lines$text) & nzchar(lines$text), , drop = FALSE]
    after_track <- label_position == "column" ||
      (draw_ci && label_position == "end" && isTRUE(label_after_ci))
    vals$x <- if (label_position == "inside") {
      pmax(0, dplyr::coalesce(vals$value, 0)) - gap_units
    } else if (after_track) {
      100 + gap_units
    } else {
      dplyr::coalesce(vals$value, 0) + gap_units
    }
    vface <- wjp_face(value_fontface)
    if (nrow(vals) > 0) {
      plt <- plt + ggplot2::geom_text(
        data = vals,
        ggplot2::aes(x = x, y = y, label = text),
        hjust = if (label_position == "inside") 1 else 0,
        colour = if (label_position == "inside") "#ffffff" else value_colour,
        family = vface$family, fontface = vface$fontface,
        size = wjp_pt_text(value_size_pt)
      )
    }
  }

  # Category labels, averages and headers
  lab_x <- -lay$label_gap / ppu
  lface <- wjp_face(highlight_fontface)
  hface <- wjp_face(header_fontface)
  lines$family <- ifelse(is_head, hface$family, ifelse(lines$highlight, lface$family, wjp_font_family()))
  lines$face <- ifelse(is_head, hface$fontface, ifelse(lines$highlight, lface$fontface, "plain"))
  lines$colour <- ifelse(is_head, header_colour, ifelse(lines$highlight, highlight_colour, label_colour))
  lines$size <- wjp_pt_text(ifelse(is_head, header_size_pt, label_size_pt))
  for (fam in unique(lines$family)) {
    sub <- lines[lines$family == fam, , drop = FALSE]
    lab_aes <- ggplot2::aes(x = lab_x, y = y, label = label, colour = I(colour),
                            size = I(size), fontface = face)
    plt <- plt + if (use_layout) {
      ggplot2::geom_text(data = sub, mapping = lab_aes, family = fam, hjust = 1,
                         show.legend = FALSE)
    } else {
      # exact gap in points from the start of the bars, whatever the panel width
      wjp_offset_text(data = transform(sub, lab_x = 0), mapping = lab_aes,
                      offset = lay$label_gap, side = "left", family = fam,
                      fontface = NULL, size = NULL)
    }
  }

  plt <- plt +
    ggplot2::scale_x_continuous(
      limits = x_limits, expand = c(0, 0), oob = scales::oob_keep,
      breaks = if (show_axis) c(0, 25, 50, 75, 100) else NULL,
      labels = if (show_axis) function(x) paste0(x, "%") else NULL,
      position = "bottom"
    ) +
    ggplot2::scale_y_continuous(limits = c(0, y_max), expand = c(0, 0), breaks = NULL) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(x = NULL, y = NULL) +
    ptheme +
    ggplot2::theme(
      panel.grid.major   = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor   = ggplot2::element_blank(),
      axis.text.y        = ggplot2::element_blank(),
      axis.ticks         = ggplot2::element_blank(),
      axis.ticks.length  = wjp_bp(0),
      legend.position    = "none"
    )

  if (show_axis) {
    plt <- plt + ggplot2::theme(
      axis.text.x = ggplot2::element_text(size = 6.5, family = wjp_font_family(),
                                          face = "plain", colour = "#4a4a4a")
    )
  } else {
    plt <- plt + ggplot2::theme(axis.text.x = ggplot2::element_blank())
  }

  m <- lay$margins
  if (national_is_line) {
    # room above the panel for the two-line label of the national line
    m[1] <- m[1] + 2.6 * label_size_pt
  }
  if (use_layout) {
    plt <- plt + ggplot2::theme(
      panel.widths  = wjp_bp(lay$track_width * diff(x_limits) / 100),
      panel.heights = wjp_bp(total),
      plot.margin   = wjp_margin_bp(m[1], m[2], m[3], m[4] + lay$label_width + lay$label_gap)
    )
  } else {
    plt <- plt + ggplot2::theme(
      plot.margin = wjp_margin_bp(m[1], m[2], m[3], m[4] + lay$label_width + lay$label_gap)
    )
  }

  plt <- wjp_apply_ptheme(plt, ptheme)
  plt
}
