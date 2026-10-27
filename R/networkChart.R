#' Plot a Network Chart following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_network()` takes a data frame of nodes (with their coordinates) and a
#' data frame of weighted edges, and returns a ggplot object with a network
#' chart following WJP style guidelines: round nodes shaded by their
#' centrality (or by a value), edges whose width and opacity grow with their
#' weight, and the name and value of each node printed inside it.
#'
#' @details
#' The node layout is taken as given (`x`, `y`): compute it beforehand with
#' any graph layout algorithm. The chart keeps the aspect ratio of the layout
#' (one unit of `x` equals one unit of `y`) and spans the box of the nodes
#' plus `padding`, so a figure saved with the same aspect ratio has no empty
#' margins.
#'
#' \strong{Node fill.} With `fill = "centrality"`, each node is shaded by the
#' sum of the weights of its edges (its strength), rescaled to 0-1 and mixed
#' between the two `colors` in RGB space. With `fill = "value"`, the column
#' `node_value` is used instead. The text of each node is white on dark fills
#' and dark on light fills (`label_colour = "auto"`).
#'
#' \strong{Edges.} The weight of each edge is rescaled to 0-1 (`t`). Its width
#' is `edge_width[1] + (edge_width[2] - edge_width[1]) * t^edge_gamma` points
#' and its opacity `edge_alpha[1] + (edge_alpha[2] - edge_alpha[1]) * t`. Both
#' `edge_width` and `edge_alpha` also accept a single value or a function of
#' the raw weights. Edges are drawn from the thinnest to the thickest, below
#' the nodes.
#'
#' Node names can contain line breaks (`"\n"`); use `ids` when the names drawn
#' differ from the identifiers used in `edges`.
#'
#' @param nodes Data frame with one row per node.
#' @param edges Data frame with one row per edge.
#' @param x,y Strings. Columns of `nodes` with the coordinates of the nodes.
#'   Default is `"x"` and `"y"`.
#' @param labels String. Column of `nodes` with the names drawn in the nodes.
#'   Default is `"label"`.
#' @param value_labels String. Column of `nodes` with a second line of text
#'   (e.g., `"(40%)"`). Default is `NULL`.
#' @param weight String. Column of `edges` with the weight of each edge.
#'   Default is `"weight"`.
#' @param node_radius Numeric. Radius of the nodes, in units of the layout.
#'   Default is `NULL` (6.5% of the largest side of the layout).
#' @param fill String. `"centrality"` (default) or `"value"`. See Details.
#' @param colors Character vector of length 2 with the fill of the least and
#'   the most central (or valued) nodes. Default is `c("#A8A8C8", "#39396B")`.
#' @param edge_color String. Color of the edges. Default is `"#5D6D7E"`.
#' @param edge_width Width of the edges, in points: a range `c(min, max)`, a
#'   single value, or a function of the weights. Default is `c(0.6, 3.2)`.
#' @param edge_alpha Opacity of the edges: a range `c(min, max)`, a single
#'   value, or a function of the weights. Default is `c(0.2, 0.85)`.
#' @param ids String. Column of `nodes` with the node identifiers used in
#'   `edges`. Default is `NULL` (`labels`).
#' @param from,to Strings. Columns of `edges` with the identifiers of the two
#'   nodes of each edge. Default is `"from"` and `"to"`.
#' @param node_value String. Column of `nodes` used by `fill = "value"`.
#'   Default is `NULL`.
#' @param edge_gamma Numeric. Exponent applied to the rescaled weights for
#'   the edge widths. Default is `0.8`.
#' @param border_color String. Color of the node outlines. Default is
#'   `"#2C3E50"`; `NA` removes them.
#' @param border_width Numeric. Width of the node outlines, in points.
#'   Default is `0.9`.
#' @param label_size Numeric. Size of the node text, in points. Default is `8`.
#' @param label_fontface String. Font face of the node text. Default is
#'   `"bold"`. Weight faces such as `"semibold"` are accepted (see [wjp_fonts()]).
#' @param label_colour String. Color of the node text, or `"auto"` (default)
#'   for white text on dark nodes and dark text on light nodes.
#' @param label_lineheight Numeric. Distance between the lines of the node
#'   text, in ems. Default is `1.15`.
#' @param label_wrap Numeric. Maximum number of characters per line of the
#'   node names. Default is `NULL` (no wrapping).
#' @param padding Numeric. Space around the nodes, in units of the layout.
#'   Default is `NULL` (1.17 times `node_radius`).
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Co-occurrence of problems (fictional data)
#' nodes <- data.frame(
#'   problem = c("Consumer", "Housing", "Family", "Money & Debt", "Employment"),
#'   share   = c("(40%)", "(10%)", "(18%)", "(22%)", "(19%)"),
#'   x       = c(1.0, 0.3, 0.9, 0.3, 0.1),
#'   y       = c(0.2, 0.6, 0.5, 0.9, 0.3)
#' )
#' nodes$name <- c("Consumer", "Housing", "Family", "Money &\nDebt", "Employment")
#' edges <- data.frame(
#'   from = c("Consumer", "Consumer", "Housing", "Family", "Money & Debt", "Housing"),
#'   to   = c("Family", "Money & Debt", "Money & Debt", "Employment", "Employment", "Family"),
#'   lift = c(1.7, 2.1, 2.8, 1.9, 2.4, 2.2)
#' )
#'
#' wjp_network(
#'   nodes, edges,
#'   labels       = "name",
#'   ids          = "problem",
#'   value_labels = "share",
#'   weight       = "lift"
#' )
#'
wjp_network <- function(
    nodes,
    edges,
    x                = "x",
    y                = "y",
    labels           = "label",
    value_labels     = NULL,
    weight           = "weight",
    node_radius      = NULL,
    fill             = c("centrality", "value"),
    colors           = c("#A8A8C8", "#39396B"),
    edge_color       = "#5D6D7E",
    edge_width       = c(0.6, 3.2),
    edge_alpha       = c(0.2, 0.85),
    ids              = NULL,
    from             = "from",
    to               = "to",
    node_value       = NULL,
    edge_gamma       = 0.8,
    border_color     = "#2C3E50",
    border_width     = 0.9,
    label_size       = 8,
    label_fontface   = "bold",
    label_colour     = "auto",
    label_lineheight = 1.15,
    label_wrap       = NULL,
    padding          = NULL,
    ptheme           = WJP_theme()
) {
  fill <- match.arg(fill)
  if (!is.data.frame(nodes) || nrow(nodes) == 0) {
    stop("`nodes` must be a non-empty data frame.", call. = FALSE)
  }
  if (!is.data.frame(edges)) {
    stop("`edges` must be a data frame.", call. = FALSE)
  }
  column <- function(df, name, arg, what) {
    if (!is.character(name) || length(name) != 1 || is.na(name) || !name %in% names(df)) {
      stop("`", arg, "` must name an existing column in `", what, "`.", call. = FALSE)
    }
    df[[name]]
  }
  nx <- column(nodes, x, "x", "nodes")
  ny <- column(nodes, y, "y", "nodes")
  if (!is.numeric(nx) || !is.numeric(ny) || any(!is.finite(nx)) || any(!is.finite(ny))) {
    stop("Node coordinates (`x`, `y`) must be finite numbers.", call. = FALSE)
  }
  nlab <- as.character(column(nodes, labels, "labels", "nodes"))
  nid <- if (is.null(ids)) nlab else as.character(column(nodes, ids, "ids", "nodes"))
  if (anyNA(nid) || anyDuplicated(nid)) {
    stop("Node identifiers must be unique and not missing.", call. = FALSE)
  }
  nval <- if (is.null(value_labels)) NULL else as.character(column(nodes, value_labels, "value_labels", "nodes"))

  e_from <- as.character(column(edges, from, "from", "edges"))
  e_to <- as.character(column(edges, to, "to", "edges"))
  e_w <- column(edges, weight, "weight", "edges")
  if (!is.numeric(e_w) || any(!is.finite(e_w))) {
    stop("Edge weights must be finite numbers.", call. = FALSE)
  }
  i <- match(e_from, nid)
  j <- match(e_to, nid)
  if (anyNA(i) || anyNA(j)) {
    bad <- unique(c(e_from[is.na(i)], e_to[is.na(j)]))
    stop("Edges refer to nodes that are not in `nodes`: ", paste(bad, collapse = ", "), ".",
         call. = FALSE)
  }
  if (length(colors) != 2) {
    stop("`colors` must contain two colors (low, high).", call. = FALSE)
  }
  wjp_check_number(edge_gamma, "edge_gamma", 0, lower_open = TRUE)
  wjp_check_number(border_width, "border_width", 0)
  wjp_check_number(label_size, "label_size", 0, lower_open = TRUE)
  wjp_check_number(label_lineheight, "label_lineheight", 0, lower_open = TRUE)
  span <- max(diff(range(nx)), diff(range(ny)))
  if (span == 0) span <- 1
  if (is.null(node_radius)) node_radius <- 0.065 * span
  wjp_check_number(node_radius, "node_radius", 0, lower_open = TRUE)
  if (is.null(padding)) padding <- node_radius * 41 / 35
  wjp_check_number(padding, "padding", 0)

  rescale01 <- function(v) {
    r <- range(v)
    if (diff(r) == 0) rep(0.5, length(v)) else (v - r[1]) / diff(r)
  }
  aesthetic <- function(spec, w, t, name, gamma = 1) {
    if (is.function(spec)) {
      out <- spec(w)
    } else if (is.numeric(spec) && length(spec) == 1) {
      out <- rep(spec, length(w))
    } else if (is.numeric(spec) && length(spec) == 2) {
      out <- spec[1] + (spec[2] - spec[1]) * t^gamma
    } else {
      stop("`", name, "` must be one number, a range of two numbers, or a function.",
           call. = FALSE)
    }
    if (!is.numeric(out) || length(out) != length(w) || any(!is.finite(out))) {
      stop("`", name, "` must give one finite number per edge.", call. = FALSE)
    }
    out
  }

  # Edges: width (pt) and opacity from the weights, thinnest first
  e <- data.frame(x = nx[i], y = ny[i], xend = nx[j], yend = ny[j], w = e_w)
  if (nrow(e) > 0) {
    t <- rescale01(e$w)
    e$width <- aesthetic(edge_width, e$w, t, "edge_width", edge_gamma)
    e$alpha <- pmin(pmax(aesthetic(edge_alpha, e$w, t, "edge_alpha"), 0), 1)
    e$lw <- wjp_pt_line(e$width)
    e <- e[order(e$width), , drop = FALSE]
  }

  # Nodes: fill by strength (sum of incident weights) or by a value
  score <- if (fill == "centrality") {
    vapply(seq_along(nid), function(k) sum(e_w[i == k | j == k]), numeric(1))
  } else {
    if (is.null(node_value)) {
      stop('`fill = "value"` requires `node_value`.', call. = FALSE)
    }
    v <- column(nodes, node_value, "node_value", "nodes")
    if (!is.numeric(v) || any(!is.finite(v))) {
      stop("`node_value` must name a column of finite numbers.", call. = FALSE)
    }
    v
  }
  node_fill <- wjp_mix_rgb(colors[1], colors[2], rescale01(score))
  circles <- wjp_circle_df(nx, ny, node_radius)
  circles$fill <- node_fill[circles$id]

  # Node text: name lines and value line, centered on the node
  name <- wjp_wrap(nlab, label_wrap)
  text <- if (is.null(nval)) name else ifelse(is.na(nval) | !nzchar(nval), name,
                                               paste(name, nval, sep = "\n"))
  ink <- if (identical(label_colour, "auto")) {
    wjp_contrast_text(node_fill, dark = "#1A1A1A", threshold = 0.45)
  } else {
    rep(label_colour, length(nid))
  }
  lab <- data.frame(x = nx, y = ny, text = text, ink = ink, stringsAsFactors = FALSE)
  lface <- wjp_face(label_fontface)

  plt <- ggplot2::ggplot()
  if (nrow(e) > 0) {
    plt <- plt + ggplot2::geom_segment(
      data = e,
      ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend,
                   linewidth = I(.data$lw), alpha = I(.data$alpha)),
      colour = edge_color, lineend = "round"
    )
  }
  plt <- plt +
    ggplot2::geom_polygon(
      data = circles,
      ggplot2::aes(x = .data$x, y = .data$y, group = .data$id, fill = I(.data$fill)),
      colour = if (is.na(border_color)) NA else border_color,
      linewidth = wjp_pt_line(border_width)
    ) +
    ggplot2::geom_text(
      data = lab,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$text, colour = I(.data$ink)),
      family = lface$family, fontface = lface$fontface,
      size = wjp_pt_text(label_size), lineheight = label_lineheight / 1.2
    ) +
    ggplot2::scale_x_continuous(breaks = NULL) +
    ggplot2::scale_y_continuous(breaks = NULL) +
    ggplot2::coord_fixed(
      xlim = range(nx) + c(-padding, padding),
      ylim = range(ny) + c(-padding, padding),
      expand = FALSE
    ) +
    ggplot2::labs(x = NULL, y = NULL) +
    ptheme +
    ggplot2::theme(
      panel.grid.major   = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor   = ggplot2::element_blank(),
      axis.text.x        = ggplot2::element_blank(),
      axis.text.y        = ggplot2::element_blank(),
      axis.ticks         = ggplot2::element_blank(),
      axis.ticks.length  = wjp_bp(0),
      legend.position    = "none"
    )

  wjp_apply_ptheme(plt, ptheme)
}
