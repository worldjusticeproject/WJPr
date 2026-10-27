#' Plot a Dumbbell Chart following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_dumbbells()` takes a data frame with long-format data and returns a
#' ggplot object with a dumbbell chart following WJP style guidelines.
#' Dumbbell charts show the change between two points (e.g., two years) for
#' each category, connected by a line. Values are expected on a 0-100
#' percentage scale.
#'
#' @details
#' The function expects long-format data with one row per `grouping` (category)
#' and `colors` (endpoint) combination; `cgroups` names the two endpoint values
#' in order (start, end). A category may have a single value (the other row
#' missing or `NA`): its point and label are still drawn. When `labels` is
#' supplied without `labpos`, labels are placed automatically just outside each
#' endpoint and use the endpoint color. By default, a horizontal legend is
#' built from the two `cgroups` values (or `legend_labels`) and displayed above
#' the chart. Use `order` (a named vector such as `c("A" = 1, "B" = 2)`) to
#' control the top-to-bottom order of the rows.
#'
#' \strong{Group headers.} `headers` names a column with the group of each
#' category (e.g., "Gender", "Age Group"). A header row with the group name is
#' drawn above the first category of each group, styled with `header_fontface`,
#' `header_colour`, and `header_size`. Categories with an empty or missing
#' group (such as a national average at the top) get no header.
#'
#' \strong{Value labels.} `value_position = "offset"` (default) centers each
#' label `label_offset` percentage points from its endpoint, as in earlier
#' versions. `"outside"` anchors each label `value_gap` points from the edge of
#' its point, on the outer side of the pair.
#'
#' \strong{Geometry in points.} With a [wjp_layout()], the label column
#' (`label_width`, `label_gap`), the 0-100% track (`track_width`), the value
#' column (`value_gap`, `value_width`), the row and header heights
#' (`row_height`, `header_height`, `header_baseline`), and the `margins` are
#' fixed in points, and the category labels are drawn as a text layer.
#'
#' @param data Data frame containing the data to plot.
#' @param target String. Column name of the variable that supplies the values to plot.
#' @param grouping String. Column name of the variable that supplies the categories
#'   (Y-axis labels).
#' @param cgroups Character vector of length 2 with the two groups to compare (the
#'   start and end points of each dumbbell).
#' @param colors String. Column name of the variable that indicates the start and end
#'   groups (the one containing the `cgroups` values).
#' @param labels String. Column name of the variable containing the value labels to
#'   display. Default is `NULL` (no labels).
#' @param labpos String. Column name of the variable that contains the positions for
#'   the value labels. Default is `NULL` (positions are computed automatically just
#'   outside each endpoint).
#' @param label_offset Numeric. Distance in percentage points between an endpoint
#'   and its automatically positioned label (`value_position = "offset"`).
#'   Ignored when `labpos` is supplied. Default is `4`.
#' @param cvec Vector of two colors for the start and end points. If named, names
#'   should match the `cgroups` values. Default is `NULL`
#'   (`c("#2894aa", "#482d8b")` is applied).
#' @param order Named vector mapping category values to their display order (top to
#'   bottom). Default is `NULL` (data order).
#' @param bgcolor String. Hex code of the background color for the alternating row
#'   strips. Default is `"#ffffff"`.
#' @param show_legend Logical. If `TRUE`, displays a horizontal point legend above
#'   the chart using the `cgroups` values as labels. Default is `TRUE`.
#' @param color `r lifecycle::badge("deprecated")` Use `colors` instead.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#' @param legend_labels Character vector of length 2 with the legend text of the
#'   start and end points. Default is `NULL` (the `cgroups` values).
#' @param legend_position Legend position: `"top"` (default), `"bottom"`,
#'   `"left"`, `"right"`, or `c(x, y)` inside the panel.
#' @param legend_direction String. `"horizontal"` (default) or `"vertical"`.
#' @param legend_text_size Numeric. Size of the legend text, in points. Default is `11`.
#' @param legend_key_size Numeric. Size of the legend keys, in points.
#'   Default is `NULL`.
#' @param legend_fontface String. Font face of the legend text. Default is `"bold"`.
#' @param legend_justification String. Horizontal justification of a legend
#'   above or below the chart: `"left"` (default), `"center"`, or `"right"`.
#' @param headers String. Column name with the group of each category; a header
#'   row is drawn above each group. Default is `NULL` (no headers).
#' @param header_fontface String. Font face of the headers. Default is `"bold"`.
#'   Weight faces such as `"semibold.italic"` are accepted (see [wjp_fonts()]).
#' @param header_colour String. Color of the headers. Default is `NULL` (the
#'   color of the end points).
#' @param header_size Numeric. Size of the headers, in points. Default is
#'   `NULL` (the size of the category labels).
#' @param highlight_levels Character vector of categories whose labels are
#'   highlighted (e.g., a national average). Default is `NULL`.
#' @param highlight_fontface String. Font face of highlighted labels. Default
#'   is `"bold"`.
#' @param highlight_colour String. Color of highlighted labels. Default is
#'   `NULL` (the color of the headers).
#' @param label_align String. Alignment of the category labels: `"left"`
#'   (default) or `"right"`.
#' @param label_size Numeric. Size of the category labels, in points. Default
#'   is `NULL` (the size of `ptheme`).
#' @param label_colour String. Color of the category labels. Default is `NULL`
#'   (`"#524F4C"`).
#' @param breaks Numeric vector with the breaks of the value axis. Default is
#'   every 20 points from 0 to 100.
#' @param expand_mult Numeric vector of length 1 or 2. Multiplicative expansion
#'   of the value axis. Default is `NULL` (ggplot2's default; none with a
#'   `layout`).
#' @param axis_line Logical. Draw a line under the value-axis labels.
#'   Default is `FALSE`.
#' @param axis_line_color String. Color of the axis line. Default is `"#1A1A1A"`.
#' @param value_axis Logical. Show the labels of the value axis. Default is `TRUE`.
#' @param strips Logical. Draw alternating row strips. Default is `TRUE`.
#' @param strip_color String. Color of the shaded strips. Default is `"#EBEBEB"`.
#' @param grid Logical. Draw grid lines across the value axis. Default is `TRUE`.
#' @param grid_ontop Logical. Draw the grid above the points. Default is `TRUE`.
#' @param value_position String. `"offset"` (default) or `"outside"`. See Details.
#' @param value_gap Numeric. Distance, in points, between the edge of a point and
#'   its label when `value_position = "outside"`. Default is `3`.
#' @param value_size Numeric. Size of the value labels, in points. Default is `10`.
#' @param value_fontface String. Font face of the value labels. Default is `"bold"`.
#' @param point_size Numeric. Size of the points (ggplot2 units). Default is `4.5`.
#' @param point_stroke Numeric. Stroke of the points (ggplot2 units). Default is `0.5`.
#' @param segment_color String. Color of the connecting segment. Default is `"#BFBFBF"`.
#' @param segment_width Numeric. Width of the segment (ggplot2 `linewidth`).
#'   Default is `2.5`.
#' @param clip String. `"on"` (default) or `"off"` (labels next to 0% or 100%
#'   stay visible).
#' @param layout A [wjp_layout()] with the geometry of the chart in points.
#'   Default is `NULL`.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' library(dplyr)
#' library(tidyr)
#'
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Percentage of people that trust their institutions, 2017 vs 2022
#' data4dumbbells <- WJPr::gpp %>%
#'   filter(country == "Atlantis", year %in% c(2017, 2022)) %>%
#'   select(year, q1a, q1b, q1c) %>%
#'   mutate(
#'     across(!year, \(x) as.double(unclass(x))),
#'     across(!year, ~ case_when(.x <= 2 ~ 1, .x <= 4 ~ 0)),
#'     year = as.character(year)
#'   ) %>%
#'   group_by(year) %>%
#'   summarise(across(everything(), \(x) mean(x, na.rm = TRUE) * 100)) %>%
#'   pivot_longer(!year, names_to = "variable", values_to = "percentage") %>%
#'   mutate(
#'     institution = case_when(
#'       variable == "q1a" ~ "Institution A",
#'       variable == "q1b" ~ "Institution B",
#'       variable == "q1c" ~ "Institution C"
#'     ),
#'     value_label = paste0(round(percentage, 0), "%")
#'   )
#'
#' wjp_dumbbells(
#'   data4dumbbells,
#'   target   = "percentage",
#'   grouping = "institution",
#'   colors   = "year",
#'   cgroups  = c("2017", "2022"),
#'   labels   = "value_label",
#'   cvec     = c("2017" = "#2894aa", "2022" = "#482d8b"),
#'   show_legend = TRUE,
#'   label_offset = 4
#' )
#'
#' # Report style: group headers, a single-value row, values outside the pair,
#' # no strips or grid, and an axis every 25% (fictional data)
#' perception <- data.frame(
#'   category = rep(c("National Average", "Male", "Female", "18-24", "25-34"), 2),
#'   group    = rep(c("", "Gender", "Gender", "Age Group", "Age Group"), 2),
#'   series   = rep(c("Perception", "Experience"), each = 5),
#'   value    = c(27, 29, 25, NA, 26, 61, 60, 62, 68, 59)
#' )
#' perception$text <- ifelse(is.na(perception$value), "", paste0(perception$value, "%"))
#'
#' wjp_dumbbells(
#'   perception,
#'   target          = "value",
#'   grouping        = "category",
#'   colors          = "series",
#'   cgroups         = c("Perception", "Experience"),
#'   labels          = "text",
#'   cvec            = c("#575796", "#B200AA"),
#'   legend_labels   = c("General population: perception",
#'                       "People with a problem: experience"),
#'   legend_direction = "vertical",
#'   headers         = "group",
#'   header_fontface = "bold.italic",
#'   header_colour   = "#575796",
#'   label_align     = "right",
#'   breaks          = seq(0, 100, 25),
#'   axis_line       = TRUE,
#'   strips          = FALSE,
#'   grid            = FALSE,
#'   value_position  = "outside",
#'   point_size      = 3,
#'   point_stroke    = 0,
#'   segment_color   = "#E5E8E8",
#'   segment_width   = 3,
#'   clip            = "off"
#' )
#'
wjp_dumbbells <- function(
    data,
    target,
    grouping,
    cgroups,
    colors           = NULL,
    labels           = NULL,
    labpos           = NULL,
    cvec             = NULL,
    order            = NULL,
    bgcolor          = "#ffffff",
    color            = deprecated(),
    ptheme           = WJP_theme(),
    label_offset     = 4,
    show_legend      = TRUE,
    legend_labels    = NULL,
    legend_position  = "top",
    legend_direction = "horizontal",
    legend_text_size = 11,
    legend_key_size  = NULL,
    legend_fontface  = "bold",
    legend_justification = "left",
    headers          = NULL,
    header_fontface  = "bold",
    header_colour    = NULL,
    header_size      = NULL,
    highlight_levels   = NULL,
    highlight_fontface = "bold",
    highlight_colour   = NULL,
    label_align      = c("left", "right"),
    label_size       = NULL,
    label_colour     = NULL,
    breaks           = seq(0, 100, 20),
    expand_mult      = NULL,
    axis_line        = FALSE,
    axis_line_color  = "#1A1A1A",
    value_axis       = TRUE,
    strips           = TRUE,
    strip_color      = "#EBEBEB",
    grid             = TRUE,
    grid_ontop       = TRUE,
    value_position   = c("offset", "outside"),
    value_gap        = 3,
    value_size       = 10,
    value_fontface   = "bold",
    point_size       = 4.5,
    point_stroke     = 0.5,
    segment_color    = "#BFBFBF",
    segment_width    = 2.5,
    clip             = "on",
    layout           = NULL
){

  # Backwards compatibility: `color` was renamed to `colors`
  if (lifecycle::is_present(color)) {
    lifecycle::deprecate_soft("1.1.0", "wjp_dumbbells(color)", "wjp_dumbbells(colors)")
    if (is.null(colors)) {
      colors <- color
    }
  }
  if (is.null(colors)) {
    stop("`colors` must be provided.", call. = FALSE)
  }
  if (length(cgroups) != 2) {
    stop("`cgroups` must be a vector of exactly two values.", call. = FALSE)
  }
  cgroups <- as.character(cgroups)
  if (length(unique(cgroups)) != 2) {
    stop("`cgroups` must contain two different values.", call. = FALSE)
  }
  if (length(label_offset) != 1 || !is.numeric(label_offset) ||
      !is.finite(label_offset) || label_offset < 0) {
    stop("`label_offset` must be a single non-negative number.", call. = FALSE)
  }
  label_align    <- match.arg(label_align)
  value_position <- match.arg(value_position)
  for (nm in c("axis_line", "value_axis", "strips", "grid", "grid_ontop")) {
    v <- get(nm)
    if (length(v) != 1 || !is.logical(v) || is.na(v)) {
      stop("`", nm, "` must be TRUE or FALSE.", call. = FALSE)
    }
  }
  wjp_check_number(value_gap, "value_gap", 0)
  wjp_check_number(value_size, "value_size", 0, lower_open = TRUE)
  wjp_check_number(point_size, "point_size", 0)
  wjp_check_number(point_stroke, "point_stroke", 0)
  wjp_check_number(segment_width, "segment_width", 0)
  if (!clip %in% c("on", "off")) {
    stop('`clip` must be "on" or "off".', call. = FALSE)
  }
  if (!is.null(legend_labels) && length(legend_labels) != 2) {
    stop("`legend_labels` must contain two labels.", call. = FALSE)
  }
  legend_theme <- wjp_legend_theme(show_legend, position = legend_position,
                                   text_size = legend_text_size,
                                   key_size = legend_key_size,
                                   text_face = legend_fontface,
                                   justification = legend_justification,
                                   direction = legend_direction)

  # Default colors: map named vectors onto cgroups, otherwise use positions
  if (is.null(cvec)) {
    cvec <- c("#2894aa", "#482d8b")
  } else if (!is.null(names(cvec)) && all(cgroups %in% names(cvec))) {
    cvec <- unname(cvec[cgroups])
  } else {
    cvec <- unname(cvec)
  }
  if (length(cvec) != 2) {
    stop("`cvec` must contain exactly two colors.", call. = FALSE)
  }
  endpoint_palette <- stats::setNames(cvec, cgroups)
  if (is.null(header_colour)) {
    header_colour <- cvec[2]
  }
  if (is.null(highlight_colour)) {
    highlight_colour <- header_colour
  }

  # Categories in data order, with their header group
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  cats <- unique(as.character(data[[grouping]]))
  head_of <- if (is.null(headers)) {
    stats::setNames(rep(NA_character_, length(cats)), cats)
  } else {
    h <- as.character(data[[headers]])[match(cats, as.character(data[[grouping]]))]
    h[!is.na(h) & !nzchar(trimws(h))] <- NA_character_
    stats::setNames(h, cats)
  }

  # Reshaping data into a wide format with start/end columns
  wide_of <- function(col) {
    vals <- lapply(cgroups, function(g) {
      rows <- as.character(data[[colors]]) == g
      stats::setNames(data[[col]][rows], as.character(data[[grouping]][rows]))[cats]
    })
    stats::setNames(vals, c("a", "b"))
  }
  v <- wide_of(target)
  data_wider <- data.frame(group = cats, start = unname(as.numeric(v$a)),
                           end = unname(as.numeric(v$b)), stringsAsFactors = FALSE)

  if (!is.null(labels)) {
    l <- wide_of(labels)
    data_wider$lab0 <- unname(as.character(l$a))
    data_wider$lab1 <- unname(as.character(l$b))

    if (!is.null(labpos)) {
      lp <- wide_of(labpos)
      data_wider$labp0 <- unname(as.numeric(lp$a))
      data_wider$labp1 <- unname(as.numeric(lp$b))
    } else {
      # Place labels just outside each endpoint, kept inside the 0-100 panel;
      # a single value gets its label on the right
      both <- !is.na(data_wider$start) & !is.na(data_wider$end)
      lo <- both & data_wider$start <= data_wider$end
      off <- label_offset
      side0 <- ifelse(both, ifelse(lo, -off, off), off)
      side1 <- ifelse(both, ifelse(lo, off, -off), off)
      data_wider$labp0 <- pmax(off, pmin(100 - off, data_wider$start + side0))
      data_wider$labp1 <- pmax(off, pmin(100 - off, data_wider$end + side1))
    }
  }

  data_wider$start_group <- cgroups[1]
  data_wider$end_group   <- cgroups[2]

  # Ordering rows: first item of the order appears at the top
  if (is.null(order)) {
    data_wider$order_var <- seq_len(nrow(data_wider))
  } else {
    data_wider$order_var <- unname(order[data_wider$group])
    if (anyNA(data_wider$order_var)) {
      stop("`order` must include every category.", call. = FALSE)
    }
  }
  data_wider <- data_wider[order(data_wider$order_var), , drop = FALSE]

  # ---------------------------------------------------------------------------
  # Vertical positions (bottom = 1 unit, or points with a layout)
  # ---------------------------------------------------------------------------
  use_layout <- !is.null(layout)
  if (use_layout) {
    lay <- wjp_layout_resolve(layout, list(
      label_width = 84, label_gap = 6, track_width = 300, value_gap = 5,
      value_width = 27, row_height = 18, header_height = 22,
      header_baseline = 17, margins = c(0, 0, 0, 0)
    ))
  }
  label_size_pt  <- if (is.null(label_size)) 10 else label_size
  header_size_pt <- if (is.null(header_size)) label_size_pt else header_size

  # One line per header and per category, from the top
  lines <- list()
  prev <- NA_character_
  for (i in seq_len(nrow(data_wider))) {
    h <- head_of[[data_wider$group[i]]]
    if (!is.na(h) && !identical(h, prev)) {
      lines[[length(lines) + 1]] <- data.frame(kind = "header", label = h, group = NA_character_,
                                               stringsAsFactors = FALSE)
    }
    prev <- h
    lines[[length(lines) + 1]] <- data.frame(kind = "row", label = data_wider$group[i],
                                             group = data_wider$group[i],
                                             stringsAsFactors = FALSE)
  }
  lines <- do.call(rbind, lines)
  has_headers <- any(lines$kind == "header")
  n_lines <- nrow(lines)

  if (use_layout) {
    h <- ifelse(lines$kind == "header", lay$header_height, lay$row_height)
    top <- lay$inset[1] + c(0, cumsum(h)[-n_lines])
    total <- sum(h) + sum(lay$inset)
    ctr <- ifelse(lines$kind == "header",
                  top + lay$header_baseline - WJP_CAP_HALF_EM * header_size_pt,
                  top + lay$row_height / 2)
    lines$pos <- total - ctr
    lines$half <- h / 2
    pos_limits <- c(0, total)
  } else {
    lines$pos <- rev(seq_len(n_lines))
    lines$half <- 0.5
    pos_limits <- c(1, n_lines)
  }
  data_wider$pos <- lines$pos[match(data_wider$group, lines$group)]

  # Alternating strips behind the data rows, starting with grey at the top
  row_lines <- lines[lines$kind == "row", , drop = FALSE]
  strips_data <- data.frame(
    xposition = row_lines$pos,
    ymin = 0, ymax = 100,
    fill = rep(c("grey", "white"), length.out = nrow(row_lines)),
    stringsAsFactors = FALSE
  )
  strips_data <- rbind(
    transform(strips_data, x = xposition - row_lines$half),
    transform(strips_data, x = xposition + row_lines$half)
  )

  # ---------------------------------------------------------------------------
  # Value labels
  # ---------------------------------------------------------------------------
  vface <- wjp_face(value_fontface)
  if (!is.null(labels)) {
    lab_long <- rbind(
      data.frame(pos = data_wider$pos, v = data_wider$start, other = data_wider$end,
                 labp = data_wider$labp0, label = data_wider$lab0,
                 series = cgroups[1], stringsAsFactors = FALSE),
      data.frame(pos = data_wider$pos, v = data_wider$end, other = data_wider$start,
                 labp = data_wider$labp1, label = data_wider$lab1,
                 series = cgroups[2], stringsAsFactors = FALSE)
    )
    lab_long$colour <- unname(endpoint_palette[lab_long$series])
    lab_long <- lab_long[!is.na(lab_long$v) & !is.na(lab_long$label) &
                           nzchar(lab_long$label), , drop = FALSE]
    lab_long$left <- !is.na(lab_long$other) &
      (lab_long$v < lab_long$other |
         (lab_long$v == lab_long$other & lab_long$series == cgroups[1]))
  }

  # Point radius in points (filled circle) for the outside label gap
  radius_pt <- 0.375 * (point_size * ggplot2::.pt + point_stroke * ggplot2::.stroke / 2)

  # ---------------------------------------------------------------------------
  # Plot
  # ---------------------------------------------------------------------------
  plt <- ggplot() +
    geom_blank(
      data = data_wider,
      aes(x = pos,
          y = start)
    )
  if (strips) {
    plt <- plt +
      geom_ribbon(
        data = strips_data,
        aes(x     = x,
            ymin  = ymin,
            ymax  = ymax,
            group = xposition,
            fill  = fill),
        show.legend = FALSE
      )
  }
  plt <- plt +
    scale_fill_manual(values   = c("grey"  = strip_color,
                                   "white" = bgcolor),
                      na.value = NA,
                      guide    = "none") +
    geom_segment(
      data = data_wider[!is.na(data_wider$start) & !is.na(data_wider$end), , drop = FALSE],
      aes(
        x    = pos,
        xend = pos,
        y    = start,
        yend = end
      ),
      color     = segment_color,
      linewidth = segment_width
    ) +
    geom_point(
      data = data_wider[!is.na(data_wider$start), , drop = FALSE],
      aes(
        x = pos,
        y = start,
        color = start_group
      ),
      size        = point_size,
      stroke      = point_stroke,
      show.legend = show_legend
    ) +
    geom_point(
      data = data_wider[!is.na(data_wider$end), , drop = FALSE],
      aes(
        x = pos,
        y = end,
        color = end_group
      ),
      size        = point_size,
      stroke      = point_stroke,
      show.legend = show_legend
    ) +
    scale_color_manual(
      values = endpoint_palette,
      breaks = cgroups,
      labels = if (is.null(legend_labels)) ggplot2::waiver() else legend_labels,
      name   = NULL,
      guide  = ggplot2::guide_legend(
        direction = legend_direction,
        nrow = if (legend_direction == "horizontal") 1 else 2,
        byrow = TRUE,
        override.aes = list(size = point_size)
      )
    )

  if (!is.null(labels) && nrow(lab_long) > 0) {
    if (value_position == "offset") {
      plt <- plt +
        geom_text(
          data = lab_long,
          aes(x = pos, y = labp, label = label, colour = I(colour)),
          family   = vface$family,
          fontface = vface$fontface,
          size     = wjp_pt_text(value_size),
          show.legend = FALSE
        )
    } else if (use_layout) {
      ppu <- lay$track_width / 100
      gap_units <- (radius_pt + value_gap) / ppu
      lab_long$y_out <- ifelse(lab_long$left, lab_long$v - gap_units, lab_long$v + gap_units)
      lab_long$hj <- ifelse(lab_long$left, 1, 0)
      plt <- plt +
        geom_text(
          data = lab_long,
          aes(x = pos, y = y_out, label = label, colour = I(colour), hjust = hj),
          family   = vface$family,
          fontface = vface$fontface,
          size     = wjp_pt_text(value_size),
          show.legend = FALSE
        )
    } else {
      for (side in c("left", "right")) {
        sub <- lab_long[lab_long$left == (side == "left"), , drop = FALSE]
        if (nrow(sub) == 0) next
        plt <- plt + wjp_offset_text(
          data = sub, mapping = aes(x = pos, y = v, label = label, colour = I(colour)),
          offset = radius_pt + value_gap, side = side,
          family = vface$family, fontface = vface$fontface,
          size = wjp_pt_text(value_size)
        )
      }
    }
  }

  # ---------------------------------------------------------------------------
  # Scales, coordinates and theme
  # ---------------------------------------------------------------------------
  y_expand <- if (!is.null(expand_mult)) {
    ggplot2::expansion(mult = rep_len(expand_mult, 2))
  } else if (use_layout) {
    c(0, 0)
  } else {
    ggplot2::waiver()
  }
  label_layer <- use_layout
  asc <- order(lines$pos)
  axis_breaks_vec <- lines$pos[asc]
  axis_labels_vec <- lines$label[asc]
  plt <- plt +
    scale_y_continuous(limits = c(0, 100),
                       breaks = breaks,
                       labels = paste0(breaks, "%"),
                       expand = y_expand,
                       oob    = scales::oob_keep,
                       position = "right") +
    ggplot2::scale_x_continuous(
      breaks = if (label_layer) NULL else axis_breaks_vec,
      labels = if (label_layer) NULL else axis_labels_vec,
      limits = pos_limits,
      oob    = scales::oob_keep,
      expand = if (use_layout) c(0, 0) else ggplot2::expansion(add = 0.6)
    ) +
    coord_flip(clip = if (label_layer) "off" else clip) +
    ptheme +
    theme(axis.title.x       = element_blank(),
          axis.title.y       = element_blank(),
          panel.grid.major.y = element_blank(),
          panel.grid.minor   = element_blank(),
          panel.background   = element_blank(),
          panel.ontop        = grid_ontop,
          axis.text.y        = element_text(color = "#524F4C",
                                            hjust = if (label_align == "left") 0 else 1))
  plt <- plt + labs(x = NULL, y = NULL)

  if (!grid) {
    plt <- plt + theme(panel.grid.major = element_blank(),
                       panel.grid.major.x = element_blank())
  }
  if (!value_axis) {
    plt <- plt + theme(axis.text.x = element_blank())
  }
  if (axis_line) {
    plt <- plt + theme(axis.line.x = element_line(colour = axis_line_color,
                                                  linewidth = wjp_pt_line(0.75)))
  }

  # Category label, highlight and header styles
  hface <- wjp_face(header_fontface)
  lface <- wjp_face(highlight_fontface)
  is_head <- lines$kind == "header"
  is_high <- !is_head & lines$label %in% highlight_levels
  base_colour <- if (is.null(label_colour)) "#524F4C" else label_colour
  lines$colour <- ifelse(is_head, header_colour, ifelse(is_high, highlight_colour, base_colour))
  lines$face <- ifelse(is_head, hface$fontface, ifelse(is_high, lface$fontface, "plain"))
  lines$family <- ifelse(is_head, hface$family, ifelse(is_high, lface$family, wjp_font_family()))
  lines$size_pt <- ifelse(is_head, header_size_pt, label_size_pt)
  if (!label_layer) {
    if (has_headers || any(is_high) || !is.null(label_size) || !is.null(label_colour)) {
      # ggplot2 draws axis labels from the bottom break upwards
      ord <- order(lines$pos)
      one_or_all <- function(v) if (length(unique(v)) == 1) v[1] else v
      el <- suppressWarnings(element_text(
        colour = one_or_all(lines$colour[ord]),
        face   = one_or_all(lines$face[ord]),
        size   = one_or_all(lines$size_pt[ord]),
        family = one_or_all(lines$family[ord]),
        hjust  = if (label_align == "left") 0 else 1
      ))
      plt <- plt + theme(axis.text.y = el)
    }
  } else {
    lab_x <- if (label_align == "left") {
      -(lay$label_gap + lay$label_width) / (lay$track_width / 100)
    } else {
      -lay$label_gap / (lay$track_width / 100)
    }
    lines$size <- wjp_pt_text(lines$size_pt)
    for (fam in unique(lines$family)) {
      sub <- lines[lines$family == fam, , drop = FALSE]
      plt <- plt + geom_text(
        data = sub,
        aes(x = pos, y = lab_x, label = label, colour = I(colour), size = I(size),
            fontface = face),
        family = fam, hjust = if (label_align == "left") 0 else 1,
        inherit.aes = FALSE, show.legend = FALSE
      )
    }
    m <- lay$margins
    plt <- plt + theme(
      axis.text.y       = element_blank(),
      axis.ticks.length = wjp_bp(0),
      panel.widths      = wjp_bp(lay$track_width),
      panel.heights     = wjp_bp(pos_limits[2]),
      plot.margin       = wjp_margin_bp(m[1], m[2] + lay$value_gap + lay$value_width, m[3],
                                        m[4] + lay$label_width + lay$label_gap)
    )
  }

  plt <- plt + legend_theme
  plt <- wjp_apply_ptheme(plt, ptheme)

  return(plt)
}
