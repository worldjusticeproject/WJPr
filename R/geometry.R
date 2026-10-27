# Internal geometry helpers shared by the card, network, sankey, and funnel
# charts. All of them return data frames ready for geom_polygon(aes(group = id)).

#' Rounded rectangles as polygons
#'
#' @param x0,y0 Corner with the smallest x and y of each rectangle.
#' @param w,h Width and height of each rectangle.
#' @param r Corner radius (same units).
#' @param n Points per corner arc.
#' @return Data frame with `x`, `y`, and `id` (index of the rectangle).
#' @noRd
wjp_round_rect_df <- function(x0, y0, w, h, r, n = 8) {
  w <- rep_len(w, length(x0))
  h <- rep_len(h, length(x0))
  out <- lapply(seq_along(x0), function(i) {
    ri <- min(r, w[i] / 2, h[i] / 2)
    arc <- function(cx, cy, a0) {
      a <- seq(a0, a0 + pi / 2, length.out = n)
      data.frame(x = cx + ri * cos(a), y = cy + ri * sin(a))
    }
    d <- rbind(
      arc(x0[i] + w[i] - ri, y0[i] + h[i] - ri, 0),
      arc(x0[i] + ri,        y0[i] + h[i] - ri, pi / 2),
      arc(x0[i] + ri,        y0[i] + ri,        pi),
      arc(x0[i] + w[i] - ri, y0[i] + ri,        3 * pi / 2)
    )
    d$id <- i
    d
  })
  do.call(rbind, out)
}

#' Circles as polygons
#'
#' @param x,y Centers.
#' @param r Radius (one value or one per circle).
#' @param n Number of vertices.
#' @return Data frame with `x`, `y`, and `id`.
#' @noRd
wjp_circle_df <- function(x, y, r, n = 72) {
  r <- rep_len(r, length(x))
  a <- seq(0, 2 * pi, length.out = n + 1)[-(n + 1)]
  out <- lapply(seq_along(x), function(i) {
    data.frame(x = x[i] + r[i] * cos(a), y = y[i] + r[i] * sin(a), id = i)
  })
  do.call(rbind, out)
}

#' Band between two vertical segments with cubic Bezier edges
#'
#' The band joins `[ya0, ya1]` at `xa` to `[yb0, yb1]` at `xb`; both edges are
#' cubic curves with horizontal tangents (control points at the middle x), as
#' the flows of a sankey diagram.
#'
#' @return Data frame with `x` and `y` (one closed polygon).
#' @noRd
wjp_bezier_band <- function(xa, ya0, ya1, xb, yb0, yb1, n = 40) {
  t <- seq(0, 1, length.out = n)
  xm <- (xa + xb) / 2
  bez <- function(p0, p1, p2, p3) {
    (1 - t)^3 * p0 + 3 * (1 - t)^2 * t * p1 + 3 * (1 - t) * t^2 * p2 + t^3 * p3
  }
  data.frame(
    x = c(bez(xa, xm, xm, xb), bez(xb, xm, xm, xa)),
    y = c(bez(ya0, ya0, yb0, yb0), bez(yb1, yb1, ya1, ya1))
  )
}

#' Text color that contrasts with a fill
#'
#' @param fill Fill colors.
#' @param dark,light Text colors for light and dark fills.
#' @param threshold Relative luminance below which a fill is dark.
#' @return Character vector of colors.
#' @noRd
wjp_contrast_text <- function(fill, dark = "#1A1A1A", light = "#FFFFFF", threshold = 0.45) {
  out <- rep(dark, length(fill))
  ok <- !is.na(fill)
  if (any(ok)) {
    rgb <- grDevices::col2rgb(fill[ok]) / 255
    lum <- 0.2126 * rgb[1, ] + 0.7152 * rgb[2, ] + 0.0722 * rgb[3, ]
    out[ok] <- ifelse(lum < threshold, light, dark)
  }
  out
}

#' Wrap labels to a number of characters, keeping existing line breaks
#'
#' @param x Character vector.
#' @param width Maximum characters per line, or `NULL` for no wrapping.
#' @return Character vector.
#' @noRd
wjp_wrap <- function(x, width = NULL) {
  x <- as.character(x)
  if (is.null(width) || !is.finite(width)) {
    return(x)
  }
  vapply(x, function(s) {
    if (is.na(s)) return(NA_character_)
    paste(vapply(strsplit(s, "\n", fixed = TRUE)[[1]], function(z) {
      paste(strwrap(z, width = width), collapse = "\n")
    }, character(1)), collapse = "\n")
  }, character(1), USE.NAMES = FALSE)
}
