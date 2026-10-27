#' Plot a Lollipop Chart following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_lollipops()` takes a data frame with long-format data and returns a
#' ggplot object with a lollipop chart following WJP style guidelines.
#' Lollipop charts are a minimalist alternative to horizontal bar charts.
#' Values are expected on a 0-100 percentage scale.
#'
#' @details
#' The function expects one row per category: the category name in `grouping`
#' and its value in `target`. Value labels are generated automatically as
#' rounded percentages unless a `labels` column is supplied. Use `order` to
#' control the top-to-bottom order of the rows, and `line_color`/`point_color`
#' to adjust the accent colors.
#'
#' @param data Data frame containing the data to plot.
#' @param target String. Column name of the variable that supplies the values to plot.
#' @param grouping String. Column name of the variable that supplies the categories
#'   (Y-axis labels).
#' @param labels String. Column name of the variable containing the value labels to
#'   display. Default is `NULL` (labels are generated automatically as rounded
#'   percentages).
#' @param order String. Column name of the variable that contains the display order of
#'   categories. Default is `NULL` (data order).
#' @param line_size Numeric. Thickness of the lines. Default is `3`.
#' @param point_size Numeric. Size of the points. Default is `4`.
#' @param line_color String. Hex code for the lines. Default is `"#d9dde3"`.
#' @param point_color String. Hex code for the points. Default is `"#482d8b"`.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#' @param label_gap Numeric. Distance, in points, between the edge of the point
#'   (or the end of the line) and the value label, which is then anchored by
#'   `label_hjust`. Default is `NULL` (labels centered 7 percentage points
#'   after the value, as in earlier versions).
#' @param label_hjust Numeric. Horizontal justification of the value labels
#'   when `label_gap` is `NULL`. Default is `0.5`.
#' @param points Logical. Draw the points. Default is `TRUE`.
#' @param label_size Numeric. Size of the value labels, in points. Default is `10`.
#' @param label_fontface String. Font face of the value labels. Default is `"bold"`.
#' @param label_color String. Color of the value labels. Default is `"#4a4a49"`.
#'
#' @return A ggplot object representing the lollipop chart.
#' @export
#'
#' @examples
#' library(dplyr)
#' library(tidyr)
#'
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Percentage of people that trust their institutions in Atlantis
#' data4lollipops <- WJPr::gpp %>%
#'   filter(year == 2022, country == "Atlantis") %>%
#'   select(q1a, q1b, q1c, q1d) %>%
#'   mutate(
#'     across(everything(), \(x) as.double(unclass(x))),
#'     across(everything(), \(x) case_when(x <= 2 ~ 1, x <= 4 ~ 0))
#'   ) %>%
#'   summarise(across(everything(), \(x) mean(x, na.rm = TRUE) * 100)) %>%
#'   pivot_longer(everything(), names_to = "variable", values_to = "percentage") %>%
#'   mutate(
#'     institution = case_when(
#'       variable == "q1a" ~ "Institution A",
#'       variable == "q1b" ~ "Institution B",
#'       variable == "q1c" ~ "Institution C",
#'       variable == "q1d" ~ "Institution D"
#'     )
#'   )
#'
#' wjp_lollipops(
#'   data4lollipops,
#'   target   = "percentage",
#'   grouping = "institution"
#' )
#'
#' # Custom order (highest first) and accent color
#' data4lollipops_ordered <- data4lollipops %>%
#'   arrange(desc(percentage)) %>%
#'   mutate(rank = row_number())
#'
#' wjp_lollipops(
#'   data4lollipops_ordered,
#'   target      = "percentage",
#'   grouping    = "institution",
#'   order       = "rank",
#'   point_color = "#2894aa"
#' )
#'
wjp_lollipops <- function(
    data,
    target,
    grouping,
    labels        = NULL,
    order         = NULL,
    line_size     = 3,
    point_size    = 4,
    line_color    = "#d9dde3",
    point_color   = "#482d8b",
    ptheme        = WJP_theme(),
    label_gap     = NULL,
    label_hjust   = 0.5,
    points        = TRUE,
    label_size    = 10,
    label_fontface = "bold",
    label_color   = "#4a4a49"
) {
  if (length(points) != 1 || !is.logical(points) || is.na(points)) {
    stop("`points` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.null(label_gap)) wjp_check_number(label_gap, "label_gap", 0)
  wjp_check_number(label_hjust, "label_hjust", 0, 1)
  wjp_check_number(label_size, "label_size", 0, lower_open = TRUE)

  # Renaming variables in the data frame to match the function naming
  data <- data %>%
    dplyr::rename(target_var   = all_of(target),
                  grouping_var = all_of(grouping))

  if (is.null(order)) {
    data <- data %>%
      dplyr::mutate(order_var = row_number())
  } else {
    data <- data %>%
      dplyr::rename(order_var = all_of(order))
  }

  # Value labels: use the supplied column or fall back to rounded percentages
  if (is.null(labels)) {
    data <- data %>%
      dplyr::mutate(labels_var = paste0(round(target_var, 0), "%"))
  } else {
    data <- data %>%
      dplyr::rename(labels_var = all_of(labels))
  }

  # Creating plot
  plt <- ggplot(data) +
    geom_linerange(
      aes(x    = reorder(grouping_var, -order_var),
          ymin = 0,
          ymax = target_var),
      linewidth = line_size,
      color     = line_color
    )
  if (points) {
    plt <- plt +
      geom_point(
        aes(y = target_var,
            x = reorder(grouping_var, -order_var)),
        size  = point_size,
        shape = 16,
        color = point_color
      )
  }
  lface <- wjp_face(label_fontface)
  if (is.null(label_gap)) {
    plt <- plt +
      geom_text(
        aes(y     = target_var + 7,
            x     = reorder(grouping_var, -order_var),
            label = labels_var),
        size     = wjp_pt_text(label_size),
        color    = label_color,
        family   = lface$family,
        fontface = lface$fontface,
        hjust    = label_hjust
      )
  } else {
    # Anchored after the point (radius of shape 16) or after the line end
    edge <- if (points) 0.375 * point_size * ggplot2::.pt else 0
    plt <- plt +
      wjp_offset_text(
        data = data,
        mapping = aes(y = target_var, x = reorder(grouping_var, -order_var),
                      label = labels_var),
        offset = edge + label_gap, side = "right",
        family = lface$family, fontface = lface$fontface,
        size = wjp_pt_text(label_size), colour = label_color
      )
  }
  plt <- plt +
    scale_y_continuous(breaks   = seq(0, 100, by = 20),
                       limits   = c(0, 105),
                       labels   = paste0(seq(0, 100, by = 20), "%"),
                       position = "right") +
    coord_flip() +
    ptheme +
    theme(
      axis.title.x       = element_blank(),
      axis.title.y       = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_line(color = "#d1cfd1"),
      axis.text.y        = element_text(color = "#524F4C",
                                        hjust = 0)
    )
  plt <- wjp_apply_ptheme(plt, ptheme)

  return(plt)
}
