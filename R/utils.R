#' WJP Color Palettes
#'
#' @description
#' `wjp_palette()` returns the color palettes used across World Justice
#' Project visualizations, and `wjp_colors()` returns them as named vectors.
#' All WJPr chart functions fall back to the categorical palette when no color
#' vector (`cvec`) is supplied, so charts stay on-brand by default.
#'
#' @details
#' The \strong{categorical} palette contains nine colors, ordered so that the
#' first three (violet, teal-blue, orange) provide maximum contrast for small
#' categorical sets, followed by the Rule of Law Index factor colors:
#'
#' | Order | Hex code | Name |
#' |-------|-----------|-------|
#' | 1 | `#482d8b` | `violet` (primary) |
#' | 2 | `#2894aa` | `teal` (secondary) |
#' | 3 | `#f26b21` | `orange` (contrast) |
#' | 4 | `#137b3f` | `green` |
#' | 5 | `#869d3b` | `olive` |
#' | 6 | `#0f9581` | `teal_green` |
#' | 7 | `#1a74b6` | `blue` |
#' | 8 | `#8f2e8c` | `magenta` |
#' | 9 | `#555659` | `gray` (neutral) |
#'
#' The \strong{report} palette holds the colors of the WJP country reports
#' (e.g., *Paths to Justice*), named by role:
#'
#' | Name | Hex code | Usage |
#' |------|-----------|-------|
#' | `main` | `#575796` | Country series, headers, averages |
#' | `eu` | `#A8A8C8` | Comparison series (EU Average) |
#' | `eu_text` | `#7D7DA8` | Text of the comparison series |
#' | `track` | `#E5E8E8` | 100% background track |
#' | `text` | `#1A1A1A` | Body text |
#' | `highlight` | `#B200AA` | Second series of perception/experience charts |
#' | `grid` | `#D0D1D3` | Grid lines |
#' | `node` | `#8E9393` | Neutral nodes (sankey) |
#' | `excluded` | `#C4C8C8` | Excluded flows (sankey) |
#' | `box` | `#F2F3F3` | Note boxes |
#' | `note` | `#7D7DA8` | Notes |
#' | `delta` | `#4B4B7A` | Differences between cards |
#' | `card_low` | `#ECECF4` | Low end of the sequential scale |
#'
#' When more categorical colors are requested than the palette holds, the
#' palette is interpolated with [grDevices::colorRampPalette()].
#'
#' @param n Integer. Number of colors to return. If `NULL` (default), the full
#'   palette is returned. For convenience, a palette name can be passed as the
#'   first argument, e.g. `wjp_palette("report")`.
#' @param palette String. `"categorical"` (default) or `"report"`.
#'
#' @return A character vector of hex color codes. `wjp_colors()` and the
#'   report palette return named vectors.
#'
#' @seealso [scale_fill_wjp_seq()] for the sequential report scale.
#' @export
#'
#' @examples
#' # Full palette
#' wjp_palette()
#'
#' # First three colors for a small categorical set
#' wjp_palette(3)
#'
#' # Report colors, by role
#' wjp_palette("report")
#' wjp_colors()[["main"]]
#'
wjp_palette <- function(n = NULL, palette = c("categorical", "report")) {
  if (is.character(n) && length(n) == 1) {
    palette <- n
    n <- NULL
  }
  palette <- match.arg(palette)
  pal <- if (palette == "categorical") {
    unname(wjp_colors("categorical"))
  } else {
    wjp_colors("report")
  }
  if (is.null(n)) {
    return(pal)
  }
  if (length(n) != 1 || !is.numeric(n) || !is.finite(n) || n < 1) {
    stop("`n` must be a single positive integer.", call. = FALSE)
  }
  n <- as.integer(n)
  if (n <= length(pal)) {
    pal[seq_len(n)]
  } else if (palette == "report") {
    stop("The report palette has ", length(pal), " colors.", call. = FALSE)
  } else {
    grDevices::colorRampPalette(pal)(n)
  }
}

#' @rdname wjp_palette
#' @export
wjp_colors <- function(palette = c("report", "categorical")) {
  palette <- match.arg(palette)
  if (palette == "categorical") {
    return(c(violet = "#482d8b", teal = "#2894aa", orange = "#f26b21",
             green = "#137b3f", olive = "#869d3b", teal_green = "#0f9581",
             blue = "#1a74b6", magenta = "#8f2e8c", gray = "#555659"))
  }
  c(main = "#575796", eu = "#A8A8C8", eu_text = "#7D7DA8", track = "#E5E8E8",
    text = "#1A1A1A", highlight = "#B200AA", grid = "#D0D1D3", node = "#8E9393",
    excluded = "#C4C8C8", box = "#F2F3F3", note = "#7D7DA8", delta = "#4B4B7A",
    card_low = "#ECECF4")
}


#' Mix two colors in RGB space
#'
#' Linear interpolation between `low` and `high` for each `t` in 0-1, the
#' mixing used by the sequential scales of WJP reports.
#'
#' @noRd
wjp_mix_rgb <- function(low, high, t) {
  a <- grDevices::col2rgb(low)[, 1]
  b <- grDevices::col2rgb(high)[, 1]
  out <- rep(NA_character_, length(t))
  ok <- !is.na(t)
  tt <- pmin(pmax(t[ok], 0), 1)
  out[ok] <- grDevices::rgb(
    round(a[1] + (b[1] - a[1]) * tt),
    round(a[2] + (b[2] - a[2]) * tt),
    round(a[3] + (b[3] - a[3]) * tt),
    maxColorValue = 255
  )
  out
}


#' Sequential WJP Color Scales
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `scale_fill_wjp_seq()` and `scale_colour_wjp_seq()` map a continuous
#' variable to a sequential scale between two WJP colors. The colors are mixed
#' linearly in RGB space, as in the cards and networks of WJP country reports.
#'
#' @param low,high Colors of the low and high ends of the scale. Defaults to
#'   the report colors `card_low` and `main` (see [wjp_colors()]).
#' @param ... Other arguments passed to [ggplot2::continuous_scale()], such as
#'   `name`, `limits`, `breaks`, and `labels`.
#' @param na.value Color for missing values.
#' @param guide Guide for the scale. Default is `"colourbar"`.
#' @param aesthetics Aesthetics the scale applies to.
#'
#' @return A ggplot2 scale.
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' grid <- expand.grid(x = 1:5, y = 1:3)
#' grid$value <- seq(0, 100, length.out = nrow(grid))
#'
#' ggplot(grid, aes(x, y, fill = value)) +
#'   geom_tile() +
#'   scale_fill_wjp_seq()
#'
scale_fill_wjp_seq <- function(low = wjp_colors()[["card_low"]],
                               high = wjp_colors()[["main"]], ...,
                               na.value = "#ffffff", guide = "colourbar",
                               aesthetics = "fill") {
  ggplot2::continuous_scale(
    aesthetics = aesthetics,
    palette    = function(x) wjp_mix_rgb(low, high, x),
    na.value   = na.value,
    guide      = guide,
    ...
  )
}

#' @rdname scale_fill_wjp_seq
#' @export
scale_colour_wjp_seq <- function(low = wjp_colors()[["card_low"]],
                                 high = wjp_colors()[["main"]], ...,
                                 na.value = "#ffffff", guide = "colourbar",
                                 aesthetics = "colour") {
  scale_fill_wjp_seq(low = low, high = high, ..., na.value = na.value,
                     guide = guide, aesthetics = aesthetics)
}

#' @rdname scale_fill_wjp_seq
#' @export
scale_color_wjp_seq <- scale_colour_wjp_seq


#' Build a default named color vector for a grouping variable
#'
#' Maps the WJP palette onto the unique values (or factor levels) of `x`,
#' so charts remain on-brand when the user does not supply `cvec`.
#'
#' @noRd
wjp_default_cvec <- function(x) {
  vals <- if (is.factor(x)) levels(droplevels(x)) else unique(as.character(x))
  vals <- vals[!is.na(vals)]
  stats::setNames(wjp_palette(length(vals)), vals)
}


#' Determine the display order for a categorical legend
#'
#' Factor levels take precedence; otherwise categories retain their first
#' appearance in the data.
#'
#' @param x A categorical vector.
#'
#' @return A character vector of visible legend breaks.
#' @noRd
wjp_legend_breaks <- function(x) {
  vals <- if (is.factor(x)) levels(droplevels(x)) else unique(as.character(x))
  vals[!is.na(vals)]
}


#' Get the Active WJP Font Family
#'
#' @description
#' `wjp_font_family()` returns the font family used by all WJPr chart
#' functions and themes. It defaults to `"Lato Full"` and can be changed
#' globally for the session through the `wjpr.family` option, so a single
#' line switches every chart to another family loaded by [wjp_fonts()]
#' (e.g., Inter Tight).
#'
#' @details
#' Families registered by [wjp_fonts()]: `"Lato Full"` (default),
#' `"Lato Light"`, `"Lato Black"`, and `"Inter Tight"` (plus one family per
#' weight of Inter Tight with the systemfonts engine). Any other family
#' already registered in your session (via [sysfonts::font_add_google()],
#' [systemfonts::register_font()] or similar) can also be used.
#'
#' There are three ways to control the font of a WJPr chart:
#' \enumerate{
#'   \item \strong{Whole session}: `options(wjpr.family = "Inter Tight")`.
#'     Every chart created afterwards (axis text, value labels, and legends)
#'     uses the new family. Reset with `options(wjpr.family = NULL)`.
#'   \item \strong{A single chart}: wrap the call with
#'     `withr::with_options(list(wjpr.family = "Inter Tight"), ...)` so the
#'     rest of the session keeps the default.
#'   \item \strong{Theme elements only}: pass
#'     `ptheme = WJP_theme(family = "Inter Tight")` to a chart function.
#'     Note this changes axis text and titles only; value labels drawn
#'     inside the chart read the session option at call time, so use
#'     approaches 1 or 2 to switch the complete chart.
#' }
#'
#' @return A single string with the active font family.
#'
#' @export
#'
#' @examples
#' # Default family
#' wjp_font_family()
#'
#' # Switch every WJPr chart to Inter Tight for this session
#' options(wjpr.family = "Inter Tight")
#' wjp_font_family()
#'
#' # Back to the default
#' options(wjpr.family = NULL)
#'
wjp_font_family <- function() {
  family <- getOption("wjpr.family", default = "Lato Full")
  if (length(family) != 1 || !is.character(family) || is.na(family)) {
    stop("`options(wjpr.family = )` must be a single string.", call. = FALSE)
  }
  family
}


#' WJP ggplot2 Theme
#'
#' @description
#' `WJP_theme()` returns a ggplot2 theme object that applies the World Justice Project
#' visual style guidelines to charts.
#'
#' @details
#' The theme includes the following style specifications:
#' \itemize{
#'   \item Transparent panel and plot backgrounds
#'   \item Dashed grey grid lines (\code{#5e5c5a})
#'   \item WJP font family for all text elements (Lato Full by default; see
#'     [wjp_font_family()]). The family is also set on the root `text`
#'     element, so titles, legends, and strips inherit it.
#'   \item Axis text and titles of `base_size` points in \code{#524F4C}
#'   \item No axis ticks
#'   \item Zero plot margins
#' }
#'
#' `WJP_theme()` is a partial theme: it is added on top of the active
#' complete theme (ggplot2's [ggplot2::theme_grey()] unless you set another one).
#' Use `base_theme` to start from a different complete theme, such as
#' [ggplot2::theme_minimal()].
#'
#' When passed as the `ptheme` argument of a WJPr chart function, the
#' elements that differ from the default `WJP_theme()` are applied after the
#' chart's own styling, so they take precedence (for example,
#' `WJP_theme(base_size = 9)` resizes the axis labels of every chart). Complete
#' themes (including those built with `base_theme`) are used as the starting
#' point of the chart instead.
#'
#' @param family String. Font family for all text elements. Default is the
#'   active WJP font family (see [wjp_font_family()]), which is `"Lato Full"`
#'   unless changed via `options(wjpr.family = )`.
#' @param base_size Numeric. Size of the axis text and titles, in points.
#'   Default is `10`.
#' @param text_colour String. Color of the axis text and titles. Default is
#'   `"#524F4C"`. WJP country reports use `"#1A1A1A"`.
#' @param grid String. Major grid lines to draw: `"major"` (both directions,
#'   default), `"x"` (lines at the breaks of the x scale), `"y"` (lines at the
#'   breaks of the y scale), or `"none"`.
#' @param grid_colour String. Color of the grid lines. Default is `"#5e5c5a"`.
#' @param grid_linetype Line type of the grid lines. Default is `"dashed"`.
#' @param base_theme A complete ggplot2 theme to start from (e.g.,
#'   `ggplot2::theme_minimal(base_size = 11)`). Default is `NULL` (a partial
#'   theme).
#'
#' @return A ggplot2 theme object that can be added to any ggplot.
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' # Load fonts first
#' wjp_fonts()
#'
#' # Apply WJP theme to a plot
#' ggplot(mtcars, aes(x = mpg, y = wt)) +
#'   geom_point() +
#'   WJP_theme()
#'
#' # Same plot with Inter Tight
#' ggplot(mtcars, aes(x = mpg, y = wt)) +
#'   geom_point() +
#'   WJP_theme(family = "Inter Tight")
#'
#' # Report style: dark text, horizontal grid only, minimal base theme
#' ggplot(mtcars, aes(x = mpg, y = wt)) +
#'   geom_point() +
#'   WJP_theme(text_colour = "#1A1A1A", grid = "y",
#'             base_theme = theme_minimal(base_size = 11))
#'
WJP_theme <- function(family      = wjp_font_family(),
                      base_size   = 10,
                      text_colour = "#524F4C",
                      grid        = c("major", "x", "y", "none"),
                      grid_colour = "#5e5c5a",
                      grid_linetype = "dashed",
                      base_theme  = NULL) {
  grid <- match.arg(grid)
  if (length(base_size) != 1 || !is.numeric(base_size) || !is.finite(base_size) ||
      base_size <= 0) {
    stop("`base_size` must be a single positive number.", call. = FALSE)
  }
  if (!is.null(base_theme) && !ggplot2::is_theme(base_theme)) {
    stop("`base_theme` must be a ggplot2 theme.", call. = FALSE)
  }

  th <- theme(text               = element_text(family = family),
              panel.background   = element_blank(),
              plot.background    = element_blank(),
              panel.grid.major   = element_line(linewidth = 0.25,
                                                colour   = grid_colour,
                                                linetype = grid_linetype),
              panel.grid.minor   = element_blank(),
              axis.title.y       = element_text(family   = family,
                                                face     = "plain",
                                                size     = base_size,
                                                color    = text_colour,
                                                margin   = margin(0, 10, 0, 0)),
              axis.title.x       = element_text(family   = family,
                                                face     = "plain",
                                                size     = base_size,
                                                color    = text_colour,
                                                margin   = margin(10, 0, 0, 0)),
              axis.text.y        = element_text(family   = family,
                                                face     = "plain",
                                                size     = base_size,
                                                color    = text_colour),
              axis.text.x = element_text(family = family,
                                         face   = "plain",
                                         size   = base_size,
                                         color  = text_colour),
              axis.ticks  = element_blank(),
              plot.margin  = unit(c(0, 0, 0, 0), "points")
  )

  th <- th + switch(
    grid,
    major = theme(),
    x     = theme(panel.grid.major.y = element_blank()),
    y     = theme(panel.grid.major.x = element_blank()),
    none  = theme(panel.grid.major   = element_blank(),
                  panel.grid.major.x = element_blank(),
                  panel.grid.major.y = element_blank())
  )

  if (!is.null(base_theme)) {
    th <- base_theme + th
  }
  th
}


#' Build the shared WJP legend theme
#'
#' Keeps categorical chart legends visually consistent across plot families.
#'
#' @param show_legend Logical. Whether the legend should be displayed.
#' @param position Legend position: `"top"` (default), `"bottom"`, `"left"`,
#'   `"right"`, or a numeric vector `c(x, y)` with a position inside the panel
#'   (0-1 coordinates).
#' @param text_size Legend text size, in points.
#' @param key_size Optional key width and height, in points.
#' @param text_colour Legend text color.
#' @param text_face Legend text font face.
#'
#' @return A ggplot2 theme object.
#' @noRd
wjp_legend_theme <- function(show_legend = TRUE, position = "top",
                             text_size = 11, key_size = NULL,
                             text_colour = "#524F4C", text_face = "bold",
                             direction = "horizontal", justification = "left") {
  if (length(justification) != 1 || !justification %in% c("left", "center", "right")) {
    stop('`legend_justification` must be "left", "center", or "right".', call. = FALSE)
  }
  if (length(direction) != 1 || !direction %in% c("horizontal", "vertical")) {
    stop('`legend_direction` must be "horizontal" or "vertical".', call. = FALSE)
  }
  if (length(show_legend) != 1 || !is.logical(show_legend) || is.na(show_legend)) {
    stop("`show_legend` must be TRUE or FALSE.", call. = FALSE)
  }
  inside <- is.numeric(position)
  if (inside) {
    if (length(position) != 2 || anyNA(position)) {
      stop("A numeric `legend_position` must have two values (x, y).", call. = FALSE)
    }
  } else if (length(position) != 1 ||
             !position %in% c("top", "bottom", "left", "right")) {
    stop('`legend_position` must be "top", "bottom", "left", "right", or c(x, y).',
         call. = FALSE)
  }
  if (length(text_size) != 1 || !is.numeric(text_size) || !is.finite(text_size) ||
      text_size <= 0) {
    stop("`legend_text_size` must be a single positive number.", call. = FALSE)
  }

  th <- ggplot2::theme(
    legend.position      = if (!show_legend) "none" else if (inside) "inside" else position,
    legend.direction     = direction,
    legend.justification = justification,
    legend.title         = ggplot2::element_blank(),
    legend.key           = ggplot2::element_blank(),
    legend.text          = ggplot2::element_text(
      family = wjp_font_family(),
      face   = text_face,
      size   = text_size,
      color  = text_colour
    ),
    legend.key.width     = grid::unit(1.4, "cm"),
    legend.spacing.x     = grid::unit(18, "pt"),
    legend.box.margin    = ggplot2::margin(t = 4, r = 0, b = 20, l = 0)
  )
  if (show_legend && inside) {
    th <- th + ggplot2::theme(
      legend.position.inside      = position,
      legend.justification.inside = position,
      legend.background           = ggplot2::element_blank(),
      legend.box.margin           = ggplot2::margin(0, 0, 0, 0)
    )
  }
  if (!is.null(key_size)) {
    if (length(key_size) != 1 || !is.numeric(key_size) || !is.finite(key_size) ||
        key_size <= 0) {
      stop("`legend_key_size` must be a single positive number.", call. = FALSE)
    }
    th <- th + ggplot2::theme(
      legend.key.width  = wjp_bp(key_size),
      legend.key.height = wjp_bp(key_size),
      legend.key.size   = wjp_bp(key_size)
    )
  }
  th
}
