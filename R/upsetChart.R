#' Plot an UpSet Chart following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_upset()` draws an UpSet chart, the alternative to Venn diagrams for
#' many overlapping sets: one bar per intersection of sets (e.g., the unmet
#' needs that people report together), a matrix of dots below the bars that
#' shows which sets form each intersection, and the size of every set as a
#' horizontal bar on the left. Unlike `ComplexUpset`, which returns a
#' patchwork of several plots, `wjp_upset()` returns a single ggplot, so the
#' WJP theme, fonts, and [wjp_drawn()] apply to the whole chart.
#'
#' @details
#' The function expects one row per intersection: its sets in `intersections`
#' (a string with the set names separated by `sep`, such as
#' `"Access to Assistance + Access to Information"`, or a list column of
#' character vectors), its value in `target`, and optionally its printed value
#' in `labels`. Intersections are drawn from left to right in the order of the
#' data, or of the `order` column.
#'
#' Sets are listed from top to bottom in the order of `sets`: a character
#' vector of set names, or a data frame whose first column holds the set names
#' and whose `set_target` and `set_labels` columns hold their sizes and
#' printed sizes. When the sizes are not given, a set's size is the sum of the
#' values of the intersections that contain it, and no size label is printed.
#'
#' The chart is drawn on a canvas of `width` by `height` points (the panel of
#' intersection bars on the upper `bar_ratio` of the plotting height, the
#' matrix below it, and the set sizes on the left), so [wjp_save()] writes it
#' at that exact size. Each intersection bar is 0.9 of its column, as tall as
#' its value relative to the largest value times `bar_headroom`.
#'
#' @param data Data frame with one row per intersection.
#' @param intersections String. Column name with the sets of each
#'   intersection (string separated by `sep`, or a list column).
#' @param sets Set names from top to bottom: `NULL` (default; order of first
#'   appearance in `intersections`), a character vector, or a data frame whose
#'   first column holds the set names.
#' @param target String. Column name with the value of each intersection.
#' @param labels String. Column name with the printed value of each
#'   intersection. Default is `NULL` (no values).
#' @param set_target String. Column of `sets` (a data frame) with the size of
#'   each set. Default is `NULL` (sum of the intersections).
#' @param set_labels String. Column of `sets` (a data frame) with the printed
#'   size of each set. Default is `NULL` (no size labels).
#' @param order String. Column name with the display order of the
#'   intersections (left to right). Default is `NULL` (data order).
#' @param bar_color String. Color of the intersection and set bars. Default is
#'   the WJP primary color `"#482d8b"`.
#' @param dot_colors Character vector of length 2 with the colors of the
#'   active and inactive dots of the matrix. Default is `c("#1A1A1A", "#E5E8E8")`.
#' @param label_angle Numeric. Angle of the intersection values. Default is
#'   `90` (vertical, reading upwards); `0` prints them horizontally above the
#'   bars.
#' @param sep String. Separator of the set names in `intersections`. Default
#'   is `" + "`.
#' @param width,height Numeric. Size of the chart, in points. Defaults are
#'   `468` and `388.8` (6.5 by 5.4 inches).
#' @param spacing Numeric. Outer margin and gap between the bars, the matrix,
#'   and the set sizes, in points. Default is `10.7`.
#' @param set_width_ratio Numeric. Share of the available width used by the
#'   set-size bars. Default is `0.22`.
#' @param bar_ratio Numeric. Share of the plotting height used by the
#'   intersection bars (the matrix takes the rest). Default is `2/3`.
#' @param bar_headroom Numeric. The tallest bar measures `1 / bar_headroom` of
#'   its panel. Default is `1.25`.
#' @param y_title String. Title of the intersection bars (use `"\n"` for line
#'   breaks). Default is `NULL` (no title).
#' @param title_size Numeric. Size of the title, in points. Default is `10.75`.
#' @param title_colour String. Color of the title. Default is `"#000000"`.
#' @param label_size Numeric. Size of the set names, in points. Default is `10`.
#' @param label_colour String. Color of the set names. Default is `"#4D4D4D"`.
#' @param label_gap Numeric. Gap between the set names and the matrix, in
#'   points. Default is `4.33`.
#' @param value_size Numeric. Size of the intersection values, in points.
#'   Default is `10`.
#' @param value_colour String. Color of the intersection values. Default is
#'   `NULL` (`bar_color`).
#' @param value_fontface String. Font face of the values. Default is `"plain"`.
#' @param set_value_size Numeric. Size of the set-size labels, in points.
#'   Default is `10`.
#' @param set_value_colour String. Color of the set-size labels. Default is `"#1A1A1A"`.
#' @param dot_radius Numeric. Radius of the matrix dots, in points. Default is `4`.
#' @param segment_color String. Color of the segment joining the active dots.
#'   Default is `"#000000"`.
#' @param segment_width Numeric. Width of that segment, in points. Default is `1.04`.
#' @param grid_color String. Color of the matrix grid lines (`NA` for none).
#'   Default is `"#EBEBEB"`.
#' @param grid_width Numeric. Width of the grid lines, in points. Default is `1.04`.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Combinations of unmet needs among people in the justice gap (fictional data)
#' needs <- data.frame(
#'   combination = c("Assistance + Information", "Assistance", "Information",
#'                   "Assistance + Information + Resolution", "Resolution"),
#'   value       = c(18.2, 14.5, 9.1, 7.4, 2.2)
#' )
#' needs$text <- paste0(format(needs$value, nsmall = 1), "%")
#'
#' set_sizes <- data.frame(
#'   set  = c("Resolution", "Information", "Assistance"),
#'   size = c(9.6, 34.7, 40.1)
#' )
#' set_sizes$text <- paste0(format(set_sizes$size, nsmall = 1), "%")
#'
#' wjp_upset(
#'   needs,
#'   intersections = "combination",
#'   sets          = set_sizes,
#'   target        = "value",
#'   labels        = "text",
#'   set_target    = "size",
#'   set_labels    = "text",
#'   bar_color     = "#575796",
#'   y_title       = "% of people within\nthe justice gap"
#' )
#'
wjp_upset <- function(data,
                      intersections,
                      sets             = NULL,
                      target,
                      labels           = NULL,
                      set_target       = NULL,
                      set_labels       = NULL,
                      order            = NULL,
                      bar_color        = "#482d8b",
                      dot_colors       = c("#1A1A1A", "#E5E8E8"),
                      label_angle      = 90,
                      sep              = " + ",
                      width            = 468,
                      height           = 388.8,
                      spacing          = 10.7,
                      set_width_ratio  = 0.22,
                      bar_ratio        = 2 / 3,
                      bar_headroom     = 1.25,
                      y_title          = NULL,
                      title_size       = 10.75,
                      title_colour     = "#000000",
                      label_size       = 10,
                      label_colour     = "#4D4D4D",
                      label_gap        = 4.33,
                      value_size       = 10,
                      value_colour     = NULL,
                      value_fontface   = "plain",
                      set_value_size   = 10,
                      set_value_colour = "#1A1A1A",
                      dot_radius       = 4,
                      segment_color    = "#000000",
                      segment_width    = 1.04,
                      grid_color       = "#EBEBEB",
                      grid_width       = 1.04,
                      ptheme           = WJP_theme()) {

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  if (!is.data.frame(data) || nrow(data) == 0) {
    stop("`data` must be a non-empty data frame.", call. = FALSE)
  }
  col_of <- function(df, name, arg, required = TRUE) {
    if (is.null(name)) {
      if (required) stop("`", arg, "` must be supplied.", call. = FALSE)
      return(NULL)
    }
    if (!is.character(name) || length(name) != 1 || !name %in% names(df)) {
      stop("`", arg, "` must name a column of ",
           if (arg %in% c("set_target", "set_labels")) "`sets`" else "`data`", ".",
           call. = FALSE)
    }
    df[[name]]
  }
  for (nm in c("width", "height", "label_size", "value_size", "set_value_size",
               "title_size", "dot_radius", "bar_headroom")) {
    wjp_check_number(get(nm), nm, 0, lower_open = TRUE)
  }
  for (nm in c("spacing", "label_gap", "segment_width", "grid_width")) {
    wjp_check_number(get(nm), nm, 0)
  }
  wjp_check_number(set_width_ratio, "set_width_ratio", 0, 1)
  wjp_check_number(bar_ratio, "bar_ratio", 0, 1, lower_open = TRUE)
  wjp_check_number(label_angle, "label_angle", -360, 360)
  if (!is.character(dot_colors) || length(dot_colors) != 2) {
    stop("`dot_colors` must contain two colors (active, inactive).", call. = FALSE)
  }
  if (!is.character(sep) || length(sep) != 1 || !nzchar(sep)) {
    stop("`sep` must be a non-empty string.", call. = FALSE)
  }
  if (is.null(value_colour)) value_colour <- bar_color

  raw_sets <- col_of(data, intersections, "intersections")
  members <- if (is.list(raw_sets)) {
    lapply(raw_sets, function(x) trimws(as.character(x)))
  } else {
    lapply(strsplit(as.character(raw_sets), sep, fixed = TRUE), trimws)
  }
  if (any(lengths(members) == 0) || anyNA(unlist(members))) {
    stop("Every intersection needs at least one set.", call. = FALSE)
  }
  value <- col_of(data, target, "target")
  if (!is.numeric(value) || any(!is.finite(value)) || any(value < 0)) {
    stop("`target` must contain non-negative finite numbers.", call. = FALSE)
  }
  text <- col_of(data, labels, "labels", required = FALSE)
  text <- if (is.null(text)) rep("", nrow(data)) else ifelse(is.na(text), "", as.character(text))
  ord <- col_of(data, order, "order", required = FALSE)
  idx <- if (is.null(ord)) seq_len(nrow(data)) else base::order(ord)
  members <- members[idx]
  value <- value[idx]
  text <- text[idx]

  # Sets, from top to bottom, and their sizes
  if (is.null(sets)) {
    set_names <- unique(unlist(members))
  } else if (is.data.frame(sets)) {
    if (nrow(sets) == 0 || ncol(sets) == 0) {
      stop("`sets` must have one row per set.", call. = FALSE)
    }
    set_names <- as.character(sets[[1]])
  } else if (is.character(sets)) {
    set_names <- sets
  } else {
    stop("`sets` must be NULL, a character vector, or a data frame.", call. = FALSE)
  }
  if (anyDuplicated(set_names) || anyNA(set_names)) {
    stop("Set names must be unique.", call. = FALSE)
  }
  unknown <- setdiff(unique(unlist(members)), set_names)
  if (length(unknown) > 0) {
    stop("Intersections refer to sets not listed in `sets`: ",
         paste(unknown, collapse = ", "), ".", call. = FALSE)
  }
  if ((!is.null(set_target) || !is.null(set_labels)) && !is.data.frame(sets)) {
    stop("`set_target` and `set_labels` require `sets` to be a data frame.", call. = FALSE)
  }
  set_size <- if (!is.null(set_target)) {
    s <- col_of(sets, set_target, "set_target")
    if (!is.numeric(s) || any(!is.finite(s)) || any(s < 0)) {
      stop("`set_target` must contain non-negative finite numbers.", call. = FALSE)
    }
    s
  } else {
    vapply(set_names, function(s) sum(value[vapply(members, function(m) s %in% m, logical(1))]),
           numeric(1))
  }
  set_text <- if (!is.null(set_labels)) {
    s <- col_of(sets, set_labels, "set_labels")
    ifelse(is.na(s), "", as.character(s))
  } else {
    rep("", length(set_names))
  }

  # ---------------------------------------------------------------------------
  # Geometry (points; x to the right, y downwards)
  # ---------------------------------------------------------------------------
  n <- length(members)
  ns <- length(set_names)
  m <- spacing
  title_lines <- if (is.null(y_title)) character() else strsplit(y_title, "\n", fixed = TRUE)[[1]]
  # Height of the rotated title block (text box of the first line + 0.9 em per extra line)
  th <- if (length(title_lines)) title_size * (0.9418 + 0.9 * 1.2 * (length(title_lines) - 1)) else 0
  title_gap <- if (length(title_lines)) 3.125 else 0
  max_w <- wjp_text_width_pt(set_names, label_size)
  lab_w <- th + title_gap + max_w + label_gap
  avail <- width - 3 * m - lab_w
  if (avail <= 0) {
    stop("`width` is too small for the set names.", call. = FALSE)
  }
  sw <- set_width_ratio * avail
  mw <- avail - sw
  xs1 <- m + sw                        # right end of the set-size bars
  xp0 <- xs1 + m + lab_w               # left edge of the bars and the matrix
  xp1 <- width - m
  ph <- height - 3 * m
  bh <- ph * bar_ratio
  mh <- ph - bh
  yb0 <- m
  yb1 <- m + bh
  ym0 <- yb1 + m
  ym1 <- height - m

  pitch <- mw / (n + 0.2)
  xc <- xp0 + pitch * (0.6 + seq_len(n) - 1)
  rpitch <- mh / (ns + 0.2)
  yr <- stats::setNames(ym0 + rpitch * (0.6 + seq_len(ns) - 1), set_names)
  vmax <- max(value)
  hb <- if (vmax > 0) value * bh / (vmax * bar_headroom) else rep(0, n)

  bars <- data.frame(xmin = xc - 0.45 * pitch, xmax = xc + 0.45 * pitch,
                     ymin = yb1 - hb, ymax = yb1, x = xc, y = yb1 - hb, text = text)
  dots <- do.call(rbind, lapply(seq_len(n), function(i) {
    data.frame(x = xc[i], y = unname(yr), on = set_names %in% members[[i]])
  }))
  segs <- do.call(rbind, lapply(seq_len(n), function(i) {
    yy <- unname(yr[members[[i]]])
    if (length(yy) < 2) return(NULL)
    data.frame(x = xc[i], y = min(yy), yend = max(yy))
  }))
  smax <- max(set_size)
  wsz <- if (smax > 0) set_size * sw / (smax * 1.7) else rep(0, ns)
  sbar <- data.frame(xmin = xs1 - wsz, xmax = xs1, ymin = unname(yr) - 0.35 * rpitch,
                     ymax = unname(yr) + 0.35 * rpitch, x = xs1 - wsz, y = unname(yr),
                     text = set_text)
  set_lab <- data.frame(x = xp0 - label_gap, y = unname(yr), label = set_names)

  # ---------------------------------------------------------------------------
  # Plot
  # ---------------------------------------------------------------------------
  plt <- ggplot2::ggplot()
  if (!is.na(grid_color) && grid_width > 0) {
    plt <- plt +
      ggplot2::geom_segment(
        data = data.frame(x = xc, y = ym0, yend = ym1),
        ggplot2::aes(x = x, xend = x, y = y, yend = yend),
        colour = grid_color, linewidth = wjp_pt_line(grid_width)
      ) +
      ggplot2::geom_segment(
        data = data.frame(y = unname(yr), x = xp0, xend = xp1),
        ggplot2::aes(x = x, xend = xend, y = y, yend = y),
        colour = grid_color, linewidth = wjp_pt_line(grid_width)
      )
  }
  plt <- plt +
    ggplot2::geom_rect(
      data = bars, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill = bar_color, colour = NA
    )
  if (!is.null(segs) && nrow(segs) > 0) {
    plt <- plt + ggplot2::geom_segment(
      data = segs, ggplot2::aes(x = x, xend = x, y = y, yend = yend),
      colour = segment_color, linewidth = wjp_pt_line(segment_width)
    )
  }
  plt <- plt +
    ggplot2::geom_point(
      data = dots, ggplot2::aes(x = x, y = y, colour = I(ifelse(on, dot_colors[1], dot_colors[2]))),
      shape = 16, size = wjp_pt_point(dot_radius)
    ) +
    ggplot2::geom_rect(
      data = sbar, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill = bar_color, colour = NA
    ) +
    ggplot2::geom_text(
      data = set_lab, ggplot2::aes(x = x, y = y, label = label),
      family = wjp_font_family(), size = wjp_pt_text(label_size),
      colour = label_colour, hjust = 1
    )

  vface <- wjp_face(value_fontface)
  bar_vals <- bars[nzchar(bars$text), , drop = FALSE]
  if (nrow(bar_vals) > 0) {
    horizontal <- abs(label_angle %% 180) < 1e-8
    plt <- plt + ggplot2::geom_text(
      data = bar_vals, ggplot2::aes(x = x, y = y, label = text),
      family = vface$family, fontface = vface$fontface, size = wjp_pt_text(value_size),
      colour = value_colour, angle = label_angle,
      hjust = if (horizontal) 0.5 else -0.15,
      vjust = if (horizontal) -0.4 else 0.5
    )
  }
  set_vals <- sbar[nzchar(sbar$text), , drop = FALSE]
  if (nrow(set_vals) > 0) {
    plt <- plt + ggplot2::geom_text(
      data = set_vals, ggplot2::aes(x = x, y = y, label = text),
      family = wjp_font_family(), size = wjp_pt_text(set_value_size),
      colour = set_value_colour, hjust = 1.15
    )
  }
  if (length(title_lines)) {
    plt <- plt + ggplot2::geom_text(
      data = data.frame(x = xp0 - lab_w + th / 2, y = (yb0 + yb1) / 2,
                        label = paste(title_lines, collapse = "\n")),
      ggplot2::aes(x = x, y = y, label = label),
      family = wjp_font_family(), size = wjp_pt_text(title_size),
      colour = title_colour, angle = 90, lineheight = 0.9
    )
  }

  plt <- plt +
    ggplot2::scale_x_continuous(limits = c(0, width), expand = c(0, 0), breaks = NULL,
                                oob = scales::oob_keep) +
    ggplot2::scale_y_reverse(limits = c(height, 0), expand = c(0, 0), breaks = NULL,
                             oob = scales::oob_keep) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(x = NULL, y = NULL) +
    ptheme +
    ggplot2::theme(
      panel.grid        = ggplot2::element_blank(),
      panel.grid.major  = ggplot2::element_blank(),
      panel.grid.minor  = ggplot2::element_blank(),
      axis.text         = ggplot2::element_blank(),
      axis.text.x       = ggplot2::element_blank(),
      axis.text.y       = ggplot2::element_blank(),
      axis.ticks        = ggplot2::element_blank(),
      axis.ticks.length = wjp_bp(0),
      legend.position   = "none",
      panel.widths      = wjp_bp(width),
      panel.heights     = wjp_bp(height),
      plot.margin       = wjp_margin_bp(0, 0, 0, 0)
    )
  plt <- wjp_apply_ptheme(plt, ptheme)
  plt
}
