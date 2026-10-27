#' Plot Score Cards following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_cards()` draws a grid of rounded cards, one per row and column
#' combination, colored on a sequential scale by their value, with the value
#' printed in each card and, optionally, its difference from a reference card
#' printed below it. Rows are labeled at the left and columns at the top.
#'
#' @details
#' The function expects one row per card: the row label in `rows`, the column
#' label in `cols`, and the value in `target`. Rows and columns are drawn in
#' order of first appearance, or in the order given by `row_order` and
#' `col_order`.
#'
#' \strong{Reference and differences.} With `ref = "row"`, the cards of the
#' first row are the references of their columns; with `ref = "col"`, the cards
#' of the first column are the references of their rows. Reference cards show
#' their value centered; the other cards show the value and, below it, the
#' difference from their reference: the `deltas` column as given or, when
#' `deltas` is `NULL`, the difference between the rounded values in
#' percentage points (e.g., `"+16 points"`). `ref = "none"` draws values only.
#' A card with an empty or missing delta also shows its value centered.
#'
#' \strong{Colors.} The fill of each card mixes `colors[1]` and `colors[2]` in
#' RGB space (see [scale_fill_wjp_seq()]) at
#' `min_shade + (1 - min_shade) * (value - limits[1]) / diff(limits)`. With
#' `label_color = "auto"`, texts on cards past `dark_threshold` are white.
#'
#' \strong{Geometry in points.} Cards are `card_height` points high,
#' `card_width` points wide (or as wide as a figure of `width` points allows),
#' and `card_gap` points apart, with corners of `radius` points. Row labels are
#' wrapped to `label_width - 4` points and right-aligned `label_gap` points
#' before the cards; column headers are wrapped to the card width minus 8
#' points and their last line sits `header_gap` points above the cards. The
#' chart has a definite size, so [wjp_save()] needs no `width` or `height`.
#' Text widths are measured with \pkg{systemfonts} when it knows the font
#' family (see [wjp_fonts()]), and estimated otherwise.
#'
#' @param data Data frame containing the data to plot.
#' @param rows String. Column name of the variable with the row labels.
#' @param cols String. Column name of the variable with the column labels.
#' @param target String. Column name of the variable with the values (they set
#'   the colors and the default differences).
#' @param labels String. Column name of the variable with the printed values.
#'   Default is `NULL` (rounded percentages of `target`).
#' @param deltas String. Column name of the variable with the printed
#'   differences. Default is `NULL` (computed from `target` and `ref`).
#' @param ref String. Reference cards: `"row"` (first row, default), `"col"`
#'   (first column), or `"none"`.
#' @param limits Numeric vector of length 2 with the range of the color scale.
#'   Default is `NULL` (range of the rounded values).
#' @param colors Character vector of length 2 with the colors of the low and
#'   high ends of the scale. Default is `c("#ECECF4", "#575796")`.
#' @param label_color Color of the values and differences: `"auto"` (default:
#'   white on dark cards, `value_color` and `delta_color` otherwise) or one color.
#' @param card_height Numeric. Height of a card, in points. Default is `48`.
#' @param card_gap Numeric. Gap between cards, in points. Default is `6`.
#' @param radius Numeric. Corner radius of the cards, in points. Default is `3`.
#' @param label_width Numeric. Width of the row label column, in points.
#'   Default is `170`.
#' @param value_size Numeric. Size of the values, in points. Default is `16`.
#' @param delta_size Numeric. Size of the differences, in points. Default is `9`.
#' @param card_width Numeric. Width of a card, in points. Default is `NULL`
#'   (120, or the width that fills `width`).
#' @param width Numeric. Total width of the figure, in points; cards take the
#'   space left by the label column. Default is `NULL`.
#' @param label_gap Numeric. Gap between the row labels and the cards, in
#'   points. Default is `12`.
#' @param label_size Numeric. Size of the row labels, in points. Default is `11`.
#' @param label_colour String. Color of the row labels. Default is `"#1A1A1A"`.
#' @param label_lineheight Numeric. Distance between the baselines of label
#'   lines, in multiples of the label size. Default is `1.22`.
#' @param header_size Numeric. Size of the column headers, in points. Default is `11`.
#' @param header_fontface String. Font face of the column headers. Default is
#'   `"bold.italic"`. Weight faces such as `"semibold.italic"` are accepted
#'   (see [wjp_fonts()]).
#' @param header_colour String. Color of the column headers. Default is `NULL`
#'   (`colors[2]`).
#' @param header_gap Numeric. Distance from the baseline of the last header
#'   line to the cards, in points. Default is `7`.
#' @param header_lineheight Numeric. Distance between the baselines of header
#'   lines, in multiples of the header size. Default is `1.2`.
#' @param value_fontface String. Font face of the values. Default is `"bold"`.
#' @param value_color String. Color of the values on light cards. Default is
#'   `"#1A1A1A"`.
#' @param delta_fontface String. Font face of the differences. Default is `"italic"`.
#' @param delta_color String. Color of the differences on light cards.
#'   Default is `"#4B4B7A"`.
#' @param min_shade Numeric between 0 and 1. Shade of the lowest value.
#'   Default is `0.12`.
#' @param dark_threshold Numeric between 0 and 1. Shade from which texts turn
#'   white with `label_color = "auto"`. Default is `0.55`.
#' @param row_order,col_order Character vectors with the order of the rows (top
#'   to bottom) and columns (left to right). Default is `NULL` (order of first
#'   appearance).
#' @param margins Numeric vector of four margins (top, right, bottom, left), in
#'   points. Default is `NULL` (room for the headers on top, 4 points below).
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Hardships by outcome of the problem (fictional data)
#' cards <- data.frame(
#'   hardship = rep(c("At least one hardship", "Health issues", "Economic issues"), each = 2),
#'   outcome  = rep(c("Fully resolved", "Not resolved"), 3),
#'   value    = c(46, 62, 30, 40, 26, 36)
#' )
#'
#' wjp_cards(
#'   cards,
#'   rows   = "hardship",
#'   cols   = "outcome",
#'   target = "value",
#'   ref    = "col",
#'   width  = 468
#' )
#'
wjp_cards <- function(data,
                      rows,
                      cols,
                      target,
                      labels            = NULL,
                      deltas            = NULL,
                      ref               = c("row", "col", "none"),
                      limits            = NULL,
                      colors            = c("#ECECF4", "#575796"),
                      label_color       = "auto",
                      card_height       = 48,
                      card_gap          = 6,
                      radius            = 3,
                      label_width       = 170,
                      value_size        = 16,
                      delta_size        = 9,
                      card_width        = NULL,
                      width             = NULL,
                      label_gap         = 12,
                      label_size        = 11,
                      label_colour      = "#1A1A1A",
                      label_lineheight  = 1.22,
                      header_size       = 11,
                      header_fontface   = "bold.italic",
                      header_colour     = NULL,
                      header_gap        = 7,
                      header_lineheight = 1.2,
                      value_fontface    = "bold",
                      value_color       = "#1A1A1A",
                      delta_fontface    = "italic",
                      delta_color       = "#4B4B7A",
                      min_shade         = 0.12,
                      dark_threshold    = 0.55,
                      row_order         = NULL,
                      col_order         = NULL,
                      margins           = NULL,
                      ptheme            = WJP_theme()) {

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  ref <- match.arg(ref)
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
  if (!is.numeric(value) || any(is.infinite(value))) {
    stop("The `target` column must contain finite numbers.", call. = FALSE)
  }
  for (nm in c("card_height", "value_size", "delta_size", "label_size", "header_size",
               "label_lineheight", "header_lineheight")) {
    wjp_check_number(get(nm), nm, 0, lower_open = TRUE)
  }
  for (nm in c("card_gap", "radius", "label_width", "label_gap", "header_gap")) {
    wjp_check_number(get(nm), nm, 0)
  }
  wjp_check_number(min_shade, "min_shade", 0, 1)
  wjp_check_number(dark_threshold, "dark_threshold", 0, 1)
  if (!is.null(card_width)) wjp_check_number(card_width, "card_width", 0, lower_open = TRUE)
  if (!is.null(width)) wjp_check_number(width, "width", 0, lower_open = TRUE)
  if (!is.null(card_width) && !is.null(width)) {
    stop("Supply only one of `card_width` and `width`.", call. = FALSE)
  }
  if (!is.character(colors) || length(colors) != 2) {
    stop("`colors` must contain two colors (low and high).", call. = FALSE)
  }
  if (!is.null(limits) && (!is.numeric(limits) || length(limits) != 2 || anyNA(limits))) {
    stop("`limits` must be a numeric vector of length 2.", call. = FALSE)
  }
  if (length(label_color) != 1 || !is.character(label_color)) {
    stop("`label_color` must be \"auto\" or one color.", call. = FALSE)
  }
  if (is.null(header_colour)) header_colour <- colors[2]

  # ---------------------------------------------------------------------------
  # Cards
  # ---------------------------------------------------------------------------
  d <- data.frame(
    row   = as.character(column(rows, "rows")),
    col   = as.character(column(cols, "cols")),
    value = value,
    stringsAsFactors = FALSE
  )
  if (anyDuplicated(d[c("row", "col")])) {
    stop("Supply one row of `data` per card (row and column combination).", call. = FALSE)
  }
  row_levels <- if (is.null(row_order)) unique(d$row) else row_order
  col_levels <- if (is.null(col_order)) unique(d$col) else col_order
  if (!all(d$row %in% row_levels)) stop("`row_order` must include every row.", call. = FALSE)
  if (!all(d$col %in% col_levels)) stop("`col_order` must include every column.", call. = FALSE)
  d$i <- match(d$row, row_levels)
  d$j <- match(d$col, col_levels)
  nr <- length(row_levels)
  nc <- length(col_levels)

  d$text <- if (is.null(labels)) {
    ifelse(is.na(d$value), "", paste0(round(d$value), "%"))
  } else {
    txt <- as.character(column(labels, "labels"))
    ifelse(is.na(txt), "", txt)
  }

  d$is_ref <- switch(ref, row = d$i == 1, col = d$j == 1, none = rep(TRUE, nrow(d)))
  if (!is.null(deltas)) {
    dl <- as.character(column(deltas, "deltas"))
    d$delta <- ifelse(is.na(dl), "", dl)
  } else if (ref == "none") {
    d$delta <- ""
  } else {
    base_key <- if (ref == "row") paste(row_levels[1], d$col) else paste(d$row, col_levels[1])
    base <- d$value[match(base_key, paste(d$row, d$col))]
    diff <- round(d$value) - round(base)
    sign <- ifelse(diff > 0, "+", ifelse(diff < 0, "\u2212", "\u00b1"))
    d$delta <- ifelse(is.na(diff), "", paste0(sign, abs(diff), " points"))
  }
  d$delta[d$is_ref] <- ""
  d$centered <- !nzchar(d$delta)

  # Colors
  rv <- round(d$value)
  if (is.null(limits)) limits <- range(rv, na.rm = TRUE)
  span <- if (limits[2] > limits[1]) limits[2] - limits[1] else 1
  d$shade <- min_shade + (1 - min_shade) * (d$value - limits[1]) / span
  d$fill <- wjp_mix_rgb(colors[1], colors[2], d$shade)
  d$fill[is.na(d$fill)] <- colors[1]
  dark <- !is.na(d$shade) & d$shade > dark_threshold
  if (identical(label_color, "auto")) {
    d$value_col <- ifelse(dark, "#FFFFFF", value_color)
    d$delta_col <- ifelse(dark, "#FFFFFF", delta_color)
  } else {
    d$value_col <- label_color
    d$delta_col <- label_color
  }

  # ---------------------------------------------------------------------------
  # Geometry in points (y increases downwards from the top of the cards)
  # ---------------------------------------------------------------------------
  family <- wjp_font_family()
  face_weight <- function(face) {
    list(weight = switch(face, bold = 700, bold.italic = 700, semibold = 600,
                         semibold.italic = 600, medium = 500, medium.italic = 500, 400),
         italic = grepl("italic", face, fixed = TRUE))
  }
  if (is.null(margins)) {
    margins <- c(NA, 0, 4, 0)
  } else {
    if (!is.numeric(margins) || !length(margins) %in% c(1, 4) || any(margins[!is.na(margins)] < 0)) {
      stop("`margins` must be one or four non-negative numbers (points).", call. = FALSE)
    }
    margins <- rep_len(margins, 4)
  }
  cw <- if (!is.null(card_width)) {
    card_width
  } else if (!is.null(width)) {
    (width - margins[2] - margins[4] - label_width - label_gap - card_gap * (nc - 1)) / nc
  } else {
    120
  }
  if (cw <= 0) {
    stop("`width` leaves no room for the cards after the label column.", call. = FALSE)
  }

  wrap_pt <- function(s, size, max_w, weight = 400, italic = FALSE) {
    words <- strsplit(s, " ", fixed = TRUE)[[1]]
    lines <- character()
    cur <- ""
    for (w in words) {
      cand <- if (cur == "") w else paste(cur, w)
      if (cur != "" && wjp_text_width_pt(cand, size, family, weight, italic) > max_w) {
        lines <- c(lines, cur)
        cur <- w
      } else {
        cur <- cand
      }
    }
    c(lines, cur)
  }

  d$x0 <- (d$j - 1) * (cw + card_gap)
  d$y0 <- (d$i - 1) * (card_height + card_gap)
  d$xc <- d$x0 + cw / 2
  d$yc <- d$y0 + card_height / 2
  grid_w <- nc * cw + (nc - 1) * card_gap
  grid_h <- nr * card_height + (nr - 1) * card_gap

  # Headers: lines wrapped to the card width, last line header_gap above
  hfw <- face_weight(header_fontface)
  heads <- lapply(col_levels, wrap_pt, size = header_size, max_w = cw - 8,
                  weight = hfw$weight, italic = hfw$italic)
  hstep <- header_size * header_lineheight
  head_rows <- do.call(rbind, lapply(seq_len(nc), function(j) {
    hl <- heads[[j]]
    base <- -header_gap - hstep * (length(hl) - seq_along(hl))
    data.frame(x = (j - 1) * (cw + card_gap) + cw / 2, y = base - WJP_CAP_HALF_EM * header_size,
               text = hl, stringsAsFactors = FALSE)
  }))
  if (is.na(margins[1])) {
    margins[1] <- 12 + max(lengths(heads)) * hstep
  }

  # Row labels: lines wrapped to label_width - 4, centered on the row
  lstep <- label_size * label_lineheight
  lab_rows <- do.call(rbind, lapply(seq_len(nr), function(i) {
    ll <- wrap_pt(row_levels[i], label_size, label_width - 4)
    yc <- (i - 1) * (card_height + card_gap) + card_height / 2
    base <- yc - lstep * (length(ll) - 1) / 2 + WJP_CAP_HALF_EM * label_size
    data.frame(x = -label_gap, y = base + (seq_along(ll) - 1) * lstep - WJP_CAP_HALF_EM * label_size,
               text = ll, stringsAsFactors = FALSE)
  }))

  # Value and difference positions (cap height centered)
  d$y_value <- ifelse(d$centered, d$yc, d$yc + 2 - WJP_CAP_HALF_EM * value_size)
  d$y_delta <- d$yc + 2 + delta_size + 4 - WJP_CAP_HALF_EM * delta_size

  # ---------------------------------------------------------------------------
  # Plot
  # ---------------------------------------------------------------------------
  shapes <- wjp_round_rect_df(d$x0, d$y0, cw, card_height, radius)
  shapes$fill <- d$fill[shapes$id]

  vface <- wjp_face(value_fontface)
  dface <- wjp_face(delta_fontface)
  hface <- wjp_face(header_fontface)
  deltas_shown <- d[!d$centered, , drop = FALSE]

  plt <- ggplot2::ggplot() +
    ggplot2::geom_polygon(
      data = shapes,
      ggplot2::aes(x = x, y = y, group = id, fill = I(fill)),
      colour = NA
    ) +
    ggplot2::geom_text(
      data = d,
      ggplot2::aes(x = xc, y = y_value, label = text, colour = I(value_col)),
      family = vface$family, fontface = vface$fontface, size = wjp_pt_text(value_size)
    )
  if (nrow(deltas_shown) > 0) {
    plt <- plt + ggplot2::geom_text(
      data = deltas_shown,
      ggplot2::aes(x = xc, y = y_delta, label = delta, colour = I(delta_col)),
      family = dface$family, fontface = dface$fontface, size = wjp_pt_text(delta_size)
    )
  }
  plt <- plt +
    ggplot2::geom_text(
      data = head_rows,
      ggplot2::aes(x = x, y = y, label = text),
      family = hface$family, fontface = hface$fontface, size = wjp_pt_text(header_size),
      colour = header_colour
    ) +
    ggplot2::geom_text(
      data = lab_rows,
      ggplot2::aes(x = x, y = y, label = text),
      family = family, fontface = "plain", size = wjp_pt_text(label_size),
      colour = label_colour, hjust = 1
    ) +
    ggplot2::scale_x_continuous(limits = c(0, grid_w), expand = c(0, 0), breaks = NULL,
                                oob = scales::oob_keep) +
    ggplot2::scale_y_reverse(limits = c(grid_h, 0), expand = c(0, 0), breaks = NULL,
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
      legend.position   = "none",
      panel.widths      = wjp_bp(grid_w),
      panel.heights     = wjp_bp(grid_h),
      plot.margin       = wjp_margin_bp(margins[1], margins[2], margins[3],
                                        margins[4] + label_width + label_gap)
    )

  wjp_apply_ptheme(plt, ptheme)
}
