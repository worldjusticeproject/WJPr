#' Chart Geometry in Points
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_layout()` describes the geometry of a chart in points (1/72 inch), the
#' unit of print layouts. Pass it to the `layout` argument of
#' [wjp_groupbars()], [wjp_bars()], or [wjp_dumbbells()] to fix the label
#' column, the 100% track, the row and header heights, and the margins, so the
#' chart keeps the same measurements whatever the size of the device.
#'
#' @details
#' With a layout, the chart is drawn with fixed panel sizes (see the
#' `panel.widths` and `panel.heights` theme elements of ggplot2 >= 3.5.0) and
#' its category labels are drawn as text layers in the label column, so no
#' measurement of the text is needed. The resulting plot has a definite size,
#' stored in `attr(plot, "wjp_size")` (inches), which [wjp_save()] uses when no
#' `width` or `height` is given. Saving a plot with a layout at another size
#' centers it on the canvas without changing its measurements.
#'
#' Every argument is optional: the chart functions use their own defaults
#' (those of WJP country reports) for the values left as `NULL`.
#'
#' A horizontal chart with a layout is organized as follows, from left to
#' right: `margins[4]`, the label column (`label_width`), `label_gap`, the
#' track (`track_width`, 0 to 100%), `value_gap`, the value column
#' (`value_width`), and `margins[2]`.
#'
#' @param label_width Width of the label column.
#' @param label_gap Gap between the label column and the start of the bars.
#' @param track_width Width of a full (100%) bar.
#' @param value_gap Gap between the end of the track (or of the bar) and the
#'   value labels.
#' @param value_width Width reserved for the value labels.
#' @param row_height Height of a data row (the pitch from one bar to the next).
#' @param bar_height Height of a bar within its row.
#' @param header_height Height of a group header row.
#' @param header_baseline Baseline of the header text, measured from the top
#'   of its row.
#' @param inset Space between the edges of the panel and the first and last
#'   rows: one value, or two values (top, bottom). Used by [wjp_dumbbells()]
#'   and [wjp_groupbars()] (row mode).
#' @param margins Outer margins: one value, or four values in the order top,
#'   right, bottom, left.
#'
#' @return An object of class `wjp_layout` (a named list of numbers in points).
#' @seealso [wjp_save()] to export a chart at its exact size.
#' @export
#'
#' @examples
#' # Geometry of the grouped bars of WJP country reports
#' report <- wjp_layout(
#'   label_width = 149, label_gap = 6, track_width = 250,
#'   value_gap = 5, value_width = 27,
#'   row_height = 15.5, bar_height = 13.5,
#'   header_height = 22, header_baseline = 17,
#'   margins = c(2, 0, 4, 0)
#' )
#' report
#'
wjp_layout <- function(label_width     = NULL,
                       label_gap       = NULL,
                       track_width     = NULL,
                       value_gap       = NULL,
                       value_width     = NULL,
                       row_height      = NULL,
                       bar_height      = NULL,
                       header_height   = NULL,
                       header_baseline = NULL,
                       inset           = NULL,
                       margins         = NULL) {
  out <- list(
    label_width     = label_width,
    label_gap       = label_gap,
    track_width     = track_width,
    value_gap       = value_gap,
    value_width     = value_width,
    row_height      = row_height,
    bar_height      = bar_height,
    header_height   = header_height,
    header_baseline = header_baseline
  )
  for (nm in names(out)) {
    x <- out[[nm]]
    if (!is.null(x) && (length(x) != 1 || !is.numeric(x) || !is.finite(x) || x < 0)) {
      stop("`", nm, "` must be a single non-negative number (points).", call. = FALSE)
    }
  }
  positive <- c("track_width", "row_height", "bar_height", "header_height")
  for (nm in positive) {
    if (!is.null(out[[nm]]) && out[[nm]] <= 0) {
      stop("`", nm, "` must be greater than zero.", call. = FALSE)
    }
  }
  if (!is.null(margins)) {
    if (!is.numeric(margins) || !length(margins) %in% c(1, 4) ||
        any(!is.finite(margins)) || any(margins < 0)) {
      stop("`margins` must be one or four non-negative numbers (points).", call. = FALSE)
    }
    margins <- rep_len(margins, 4)
  }
  if (!is.null(inset)) {
    if (!is.numeric(inset) || !length(inset) %in% c(1, 2) ||
        any(!is.finite(inset)) || any(inset < 0)) {
      stop("`inset` must be one or two non-negative numbers (points).", call. = FALSE)
    }
    inset <- rep_len(inset, 2)
  }
  out$inset <- inset
  out$margins <- margins
  structure(out[!vapply(out, is.null, logical(1))], class = "wjp_layout")
}

#' @export
print.wjp_layout <- function(x, ...) {
  cat("<wjp_layout> (points)\n")
  for (nm in names(x)) {
    cat(sprintf("  %-15s %s\n", nm, paste(format(x[[nm]]), collapse = " ")))
  }
  invisible(x)
}

#' Fill a layout with chart defaults
#'
#' @param layout `NULL`, a `wjp_layout`, or a named list.
#' @param defaults Named list of default values (points).
#' @return A complete named list.
#' @noRd
wjp_layout_resolve <- function(layout, defaults) {
  if (!is.null(layout) && !inherits(layout, "wjp_layout") && !is.list(layout)) {
    stop("`layout` must be created with wjp_layout().", call. = FALSE)
  }
  out <- if (is.null(layout)) defaults else utils::modifyList(defaults, unclass(layout))
  if (is.null(out$margins)) {
    out$margins <- c(0, 0, 0, 0)
  }
  out$margins <- rep_len(out$margins, 4)
  out$inset <- if (is.null(out$inset)) c(0, 0) else rep_len(out$inset, 2)
  out
}


# ---------------------------------------------------------------------------
# Units: points (1/72 inch) to ggplot2 units
# ---------------------------------------------------------------------------

#' Convert points to ggplot2 units
#'
#' `wjp_pt_text()` converts a font size in points to the `size` of
#' `geom_text()` (millimeters); `wjp_pt_line()` converts a stroke width in
#' points to `linewidth`; `wjp_pt_point()` converts the radius of a filled
#' circle (shape 16/19, no stroke) in points to the `size` of `geom_point()`.
#' `wjp_bp()` and `wjp_margin_bp()` build grid units and margins in points of
#' 1/72 inch ("bigpts"), the unit of SVG and PDF files (the "pt" unit of grid
#' is 1/72.27 inch).
#'
#' @noRd
wjp_pt_text <- function(pt) pt / ggplot2::.pt

#' @noRd
wjp_pt_line <- function(pt) pt / (ggplot2::.pt * 0.75)

#' @noRd
wjp_pt_point <- function(r) r / (0.375 * ggplot2::.pt)

#' @noRd
wjp_bp <- function(x) grid::unit(x, "bigpts")

#' @noRd
wjp_margin_bp <- function(t = 0, r = 0, b = 0, l = 0) {
  ggplot2::margin(t, r, b, l, unit = "bigpts")
}

# Height of a single text line drawn by ggplot2 (ascender of "M" + descender),
# in em, and cap height of Lato / Inter Tight (centered text sits at 0.36 em
# above its baseline).
WJP_TEXT_BOX_EM <- 0.944
WJP_CAP_HALF_EM <- 0.36


# ---------------------------------------------------------------------------
# Theme composition: `ptheme` applied after the chart's own styling
# ---------------------------------------------------------------------------

#' Theme elements of `ptheme` that differ from the default `WJP_theme()`
#'
#' Complete themes are bases, not overrides, so they return `NULL`.
#'
#' @noRd
wjp_theme_overrides <- function(ptheme) {
  if (is.null(ptheme) || !ggplot2::is_theme(ptheme) || isTRUE(attr(ptheme, "complete"))) {
    return(NULL)
  }
  ref <- WJP_theme()
  nms <- names(ptheme)
  keep <- nms[!vapply(nms, function(nm) identical(ptheme[[nm]], ref[[nm]]), logical(1))]
  if (length(keep) == 0) {
    return(NULL)
  }
  stats::setNames(lapply(keep, function(nm) ptheme[[nm]]), keep)
}

#' Merge a theme element into an existing ggtext::element_markdown()
#'
#' ggplot2 >= 4.0 cannot merge its S7 elements into the S3 elements of ggtext.
#'
#' @noRd
wjp_merge_markdown <- function(new, old) {
  props <- c("family", "face", "colour", "size", "hjust", "vjust", "angle",
             "lineheight", "margin")
  args <- list()
  for (p in props) {
    nv <- tryCatch(new[[p]], error = function(e) NULL)
    args[[p]] <- if (!is.null(nv)) nv else old[[p]]
  }
  args <- args[!vapply(args, is.null, logical(1))]
  do.call(ggtext::element_markdown, args)
}

#' Apply the user's theme overrides after the chart's own styling
#'
#' The default `WJP_theme()` leaves the chart unchanged. Other partial themes
#' passed as `ptheme` are re-applied last, so their explicit elements win.
#' Elements that the chart hides (`element_blank()`) stay hidden unless the
#' override also hides them.
#'
#' @param plt A ggplot.
#' @param ptheme The `ptheme` argument of the chart function.
#' @return The ggplot with the overrides applied.
#' @noRd
wjp_apply_ptheme <- function(plt, ptheme) {
  ov <- wjp_theme_overrides(ptheme)
  if (is.null(ov)) {
    return(plt)
  }
  current <- plt$theme
  for (nm in names(ov)) {
    new <- ov[[nm]]
    old <- current[[nm]]
    if (inherits(old, "element_blank") && !inherits(new, "element_blank") &&
        inherits(new, "element")) {
      next
    }
    if (inherits(old, "element_markdown") && !inherits(new, c("element_markdown", "element_blank"))) {
      new <- wjp_merge_markdown(new, old)
      plt <- wjp_replace_theme(plt, stats::setNames(list(new), nm))
      next
    }
    th <- do.call(ggplot2::theme, stats::setNames(list(new), nm))
    plt <- tryCatch(plt + th, error = function(e) {
      wjp_replace_theme(plt, stats::setNames(list(new), nm))
    })
  }
  plt
}

#' Replace theme elements of a plot (no merging)
#' @noRd
wjp_replace_theme <- function(plt, elements) {
  th <- do.call(ggplot2::theme, elements)
  plt$theme <- ggplot2::`%+replace%`(plt$theme, th)
  plt
}


#' Width of the widest string, in points
#'
#' Uses the metrics of systemfonts when it knows the active family, and an
#' approximation (0.5 em per character) otherwise.
#'
#' @param x Character vector.
#' @param size_pt Font size in points.
#' @param family Font family.
#' @noRd
wjp_text_width_pt <- function(x, size_pt = 10, family = wjp_font_family(),
                              weight = 400, italic = FALSE) {
  x <- x[!is.na(x) & nzchar(x)]
  if (length(x) == 0) {
    return(0)
  }
  w <- NULL
  if (wjp_systemfonts_has(family) && requireNamespace("textshaping", quietly = TRUE)) {
    w <- tryCatch({
      font <- wjp_font_file(family, weight, italic)
      vapply(x, function(s) wjp_shape(s, font)$width * size_pt / .WJP_REF_SIZE, numeric(1))
    }, error = function(e) NULL)
  }
  if (is.null(w)) {
    w <- nchar(x) * size_pt * 0.5
  }
  max(w)
}
