#' Plot a Sankey Diagram following WJP style guidelines
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `wjp_sankey()` draws a three-column flow diagram (a sankey) such as the
#' justice pathways of WJP country reports: a first column of nodes (e.g.,
#' contacted an adviser or not), a second column of nodes that each come from
#' one first-column node (their `parent`), and a third column of outcome nodes
#' that each second-column node flows into (its `outcome`). Every node carries
#' a boxed label with its printed value.
#'
#' @details
#' The function expects one row per node with its `column` (1, 2, or 3), its
#' key (`node`), its value (`target`, e.g. percentages that add up to 100 in
#' each of the first two columns), and its printed value (`value_labels`).
#' Second-column rows also name their `parent` (a first-column node) and their
#' `outcome` (a third-column node). Nodes are stacked from top to bottom in the
#' order of the data within each column.
#'
#' Heights: first- and second-column nodes are as tall as their `target`;
#' third-column nodes are as tall as the sum of the second-column nodes that
#' flow into them (their own `target` is not used for the geometry, so their
#' printed value can follow another definition). The tallest column fills
#' `flow_height` points including the gaps between its nodes.
#'
#' Colors: flows, second-column bars, and third-column bars take the color of
#' their outcome (`colors`, named by the third-column node keys); first-column
#' bars use `node_color`. Flows from the first to the second column use
#' `alpha[1]` and flows into the third column `alpha[2]`.
#'
#' Labels: `labels` gives the text of each box (use `"\n"` for line breaks);
#' the printed value goes below it and the optional `notes` below the value.
#' Column titles are given by `headers`. The chart is drawn on a canvas of
#' `width` by `flow_top + flow_height + flow_bottom` points, so [wjp_save()]
#' writes it at that exact size.
#'
#' @param data Data frame with one row per node.
#' @param column String. Column name with the column of each node (1, 2, or 3).
#' @param node String. Column name with the key of each node (unique within its
#'   column).
#' @param target String. Column name with the value of each node.
#' @param value_labels String. Column name with the printed value of each node.
#'   Default is `NULL` (no values).
#' @param parent String. Column name with the first-column node of each
#'   second-column node.
#' @param outcome String. Column name with the third-column node of each
#'   second-column node.
#' @param labels String. Column name with the box label of each node. Default
#'   is `NULL` (the node keys).
#' @param headers Character vector of length 3 with the column titles (use
#'   `"\n"` for line breaks). Default is `NULL` (no titles).
#' @param notes String. Column name with an optional note printed below the
#'   value of a node. Default is `NULL`.
#' @param colors Named vector of colors, one per third-column node. Default is
#'   `NULL` (the WJP palette).
#' @param alpha Numeric vector of length 2 with the opacity of the flows into
#'   the second and the third column. Default is `c(0.30, 0.45)`.
#' @param bar_width Numeric. Width of the node bars, in points. Default is `11`.
#' @param gap Numeric. Vertical gap between the nodes of a column, in points.
#'   Default is `9`.
#' @param width Numeric. Width of the chart, in points. Default is `604.8`
#'   (8.4 inches).
#' @param flow_height Numeric. Height of the flow area, in points. Default is `300`.
#' @param flow_top Numeric. Space above the flow area for the column titles,
#'   in points. Default is `62`.
#' @param flow_bottom Numeric. Space below the flow area, in points. Default is `10`.
#' @param side_margin Numeric. Distance from the left and right edges of the
#'   chart to the outer bars, in points. Default is `92`.
#' @param node_color String. Color of the first-column bars. Default is `"#8E9393"`.
#' @param header_size Numeric. Size of the column titles, in points. Default is `10.8`.
#' @param header_fontface String. Font face of the column titles. Default is
#'   `"bold.italic"`.
#' @param header_colour String. Color of the column titles. Default is the report
#'   color `"#575796"`.
#' @param header_lineheight Numeric. Line height of the column titles, as a
#'   multiple of their size. Default is `1.25`.
#' @param header_baseline Numeric. Baseline of the first title line, in points
#'   from the top of the chart. Default is `14`.
#' @param label_size Numeric. Size of the box labels and values, in points.
#'   Default is `10`.
#' @param label_colour String. Color of the box labels. Default is `"#1A1A1A"`.
#' @param value_fontface String. Font face of the values. Default is
#'   `"semibold.italic"` (bold italic when that weight is not available; see
#'   [wjp_fonts()]).
#' @param value_colors Color of the values: one color, or a vector named by
#'   node keys for the nodes whose value has another color. Default is
#'   `"#575796"`.
#' @param note_size Numeric. Size of the notes, in points. Default is `8.75`.
#' @param note_colour String. Color of the notes. Default is `"#7D7DA8"`.
#' @param box_fill String. Fill of the label boxes. Default is `"#F2F3F3"`.
#' @param box_border String. Border color of the label boxes. Default is `"#1A1A1A"`.
#' @param box_border_width Numeric. Border width of the boxes, in points.
#'   Default is `0.6`.
#' @param box_radius Numeric. Corner radius of the boxes, in points. Default is `2.5`.
#' @param box_padding Numeric vector of length 2 with the vertical and
#'   horizontal padding of the boxes, in points. Default is `c(3, 7)`.
#' @param line_height Numeric. Line height inside the boxes, as a multiple of
#'   `label_size`. Default is `1.22`.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' # Always load the WJP fonts
#' wjp_fonts()
#'
#' # Pathways to accessing an adviser (fictional data)
#' pathways <- data.frame(
#'   column  = c(1, 1, 2, 2, 2, 2, 3, 3, 3),
#'   node    = c("contacted", "not_contacted", "appropriate", "non_appropriate",
#'               "needed_no", "no_need", "access", "no_access", "excluded"),
#'   value   = c(30, 70, 22, 8, 40, 30, 31, 69, 30),
#'   parent  = c(NA, NA, "contacted", "contacted", "not_contacted", "not_contacted",
#'               NA, NA, NA),
#'   outcome = c(NA, NA, "access", "no_access", "no_access", "excluded", NA, NA, NA),
#'   label   = c("Contacted an adviser:", "Did not contact an adviser:",
#'               "Appropriate adviser:", "Non-appropriate adviser:",
#'               "Needed but did not have\naccess to an adviser:",
#'               "Did not need an adviser:", "Had access:", "Had no access:",
#'               "Did not need an adviser:"),
#'   note    = c(rep(NA, 8), "of all respondents")
#' )
#' pathways$text <- paste0(pathways$value, "%")
#'
#' wjp_sankey(
#'   pathways,
#'   column       = "column",
#'   node         = "node",
#'   target       = "value",
#'   value_labels = "text",
#'   parent       = "parent",
#'   outcome      = "outcome",
#'   labels       = "label",
#'   notes        = "note",
#'   headers      = c("Contacted\nan adviser", "Type of adviser or\nreason for no contact",
#'                    "Access among those\nwho needed assistance"),
#'   colors       = c(access = "#575796", no_access = "#A8A8C8", excluded = "#C4C8C8"),
#'   value_colors = c(excluded = "#7D7DA8")
#' )
#'
wjp_sankey <- function(data,
                       column,
                       node,
                       target,
                       value_labels      = NULL,
                       parent,
                       outcome,
                       labels            = NULL,
                       headers           = NULL,
                       notes             = NULL,
                       colors            = NULL,
                       alpha             = c(0.30, 0.45),
                       bar_width         = 11,
                       gap               = 9,
                       width             = 604.8,
                       flow_height       = 300,
                       flow_top          = 62,
                       flow_bottom       = 10,
                       side_margin       = 92,
                       node_color        = "#8E9393",
                       header_size       = 10.8,
                       header_fontface   = "bold.italic",
                       header_colour     = "#575796",
                       header_lineheight = 1.25,
                       header_baseline   = 14,
                       label_size        = 10,
                       label_colour      = "#1A1A1A",
                       value_fontface    = "semibold.italic",
                       value_colors      = "#575796",
                       note_size         = 8.75,
                       note_colour       = "#7D7DA8",
                       box_fill          = "#F2F3F3",
                       box_border        = "#1A1A1A",
                       box_border_width  = 0.6,
                       box_radius        = 2.5,
                       box_padding       = c(3, 7),
                       line_height       = 1.22,
                       ptheme            = WJP_theme()) {

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  if (!is.data.frame(data) || nrow(data) == 0) {
    stop("`data` must be a non-empty data frame.", call. = FALSE)
  }
  col_of <- function(name, arg, required = TRUE) {
    if (is.null(name)) {
      if (required) stop("`", arg, "` must be supplied.", call. = FALSE)
      return(NULL)
    }
    if (!is.character(name) || length(name) != 1 || !name %in% names(data)) {
      stop("`", arg, "` must name a column of `data`.", call. = FALSE)
    }
    data[[name]]
  }
  for (nm in c("bar_width", "flow_height", "width")) {
    wjp_check_number(get(nm), nm, 0, lower_open = TRUE)
  }
  for (nm in c("gap", "flow_top", "flow_bottom", "side_margin", "header_baseline",
               "box_border_width", "box_radius")) {
    wjp_check_number(get(nm), nm, 0)
  }
  for (nm in c("header_size", "label_size", "note_size", "line_height", "header_lineheight")) {
    wjp_check_number(get(nm), nm, 0, lower_open = TRUE)
  }
  if (!is.numeric(alpha) || length(alpha) != 2 || any(!is.finite(alpha)) ||
      any(alpha < 0 | alpha > 1)) {
    stop("`alpha` must contain two opacities between 0 and 1.", call. = FALSE)
  }
  if (!is.numeric(box_padding) || length(box_padding) != 2 || any(!is.finite(box_padding)) ||
      any(box_padding < 0)) {
    stop("`box_padding` must contain two non-negative numbers (points).", call. = FALSE)
  }
  if (!is.null(headers) && (!is.character(headers) || length(headers) != 3)) {
    stop("`headers` must be a character vector of length 3.", call. = FALSE)
  }

  d <- data.frame(
    column = suppressWarnings(as.integer(as.character(col_of(column, "column")))),
    node   = as.character(col_of(node, "node")),
    value  = col_of(target, "target"),
    stringsAsFactors = FALSE
  )
  if (anyNA(d$column) || any(!d$column %in% 1:3)) {
    stop("`column` must contain the values 1, 2, or 3.", call. = FALSE)
  }
  if (!is.numeric(d$value)) {
    stop("`target` must be a numeric column.", call. = FALSE)
  }
  if (anyNA(d$node) || anyDuplicated(paste(d$column, d$node))) {
    stop("`node` must identify each node of a column once.", call. = FALSE)
  }
  for (k in 1:3) {
    if (!any(d$column == k)) {
      stop("Every column (1, 2, and 3) needs at least one node.", call. = FALSE)
    }
  }
  d$parent  <- as.character(col_of(parent, "parent"))
  d$outcome <- as.character(col_of(outcome, "outcome"))
  lab <- col_of(labels, "labels", required = FALSE)
  d$label <- if (is.null(lab)) d$node else as.character(lab)
  d$label[is.na(d$label)] <- ""
  val <- col_of(value_labels, "value_labels", required = FALSE)
  d$text <- if (is.null(val)) "" else as.character(val)
  d$text[is.na(d$text)] <- ""
  nts <- col_of(notes, "notes", required = FALSE)
  d$note <- if (is.null(nts)) "" else as.character(nts)
  d$note[is.na(d$note)] <- ""

  n1 <- d[d$column == 1, , drop = FALSE]
  n2 <- d[d$column == 2, , drop = FALSE]
  n3 <- d[d$column == 3, , drop = FALSE]
  if (anyNA(n1$value) || anyNA(n2$value) || any(c(n1$value, n2$value) < 0)) {
    stop("Nodes of the first two columns need non-negative values.", call. = FALSE)
  }
  if (any(is.na(n2$parent) | !n2$parent %in% n1$node)) {
    stop("Each second-column node needs a `parent` among the first-column nodes.", call. = FALSE)
  }
  if (any(is.na(n2$outcome) | !n2$outcome %in% n3$node)) {
    stop("Each second-column node needs an `outcome` among the third-column nodes.", call. = FALSE)
  }
  out_of <- vapply(n1$node, function(p) sum(n2$value[n2$parent == p]), numeric(1))
  over <- n1$node[out_of > n1$value * (1 + 1e-6) + 1e-9]
  if (length(over) > 0) {
    warning("The second-column nodes of ", paste0("\"", over, "\"", collapse = ", "),
            " add up to more than their parent; their flows extend beyond it.", call. = FALSE)
  }

  if (is.null(colors)) {
    colors <- stats::setNames(wjp_palette(nrow(n3)), n3$node)
  }
  if (is.null(names(colors)) || !all(n3$node %in% names(colors))) {
    stop("`colors` must be named by the third-column nodes.", call. = FALSE)
  }
  value_colour_of <- function(keys) {
    if (length(value_colors) == 1 && is.null(names(value_colors))) {
      return(rep(value_colors, length(keys)))
    }
    base <- if (!is.null(names(value_colors)) && "" %in% names(value_colors)) {
      value_colors[[which(names(value_colors) == "")[1]]]
    } else {
      "#575796"
    }
    out <- unname(value_colors[keys])
    out[is.na(out)] <- base
    out
  }

  # ---------------------------------------------------------------------------
  # Geometry (points, y downwards)
  # ---------------------------------------------------------------------------
  n3$value_flow <- vapply(n3$node, function(o) sum(n2$value[n2$outcome == o]), numeric(1))
  totals <- c(sum(n1$value), sum(n2$value), sum(n3$value_flow))
  n_max <- max(nrow(n1), nrow(n2), nrow(n3))
  total <- max(totals)
  if (total <= 0) {
    stop("The flows must have a positive total.", call. = FALSE)
  }
  sc <- (flow_height - gap * (n_max - 1)) / total
  if (sc <= 0) {
    stop("`flow_height` is too small for the gaps between nodes.", call. = FALSE)
  }
  height <- flow_top + flow_height + flow_bottom
  x1 <- side_margin
  x3 <- width - side_margin - bar_width
  x2 <- (x1 + x3) / 2
  stack <- function(values) {
    used <- sum(values) * sc + gap * (length(values) - 1)
    y <- flow_top + (flow_height - used) / 2
    y0 <- numeric(length(values))
    for (i in seq_along(values)) {
      y0[i] <- y
      y <- y + values[i] * sc + gap
    }
    data.frame(y0 = y0, y1 = y0 + values * sc)
  }
  n1 <- cbind(n1, stack(n1$value))
  n2 <- cbind(n2, stack(n2$value))
  n3 <- cbind(n3, stack(n3$value_flow))

  # Flows: first to second column, then second to third
  bands <- list()
  cur1 <- stats::setNames(n1$y0, n1$node)
  for (i in seq_len(nrow(n2))) {
    h <- n2$value[i] * sc
    p <- n2$parent[i]
    b <- wjp_bezier_band(x1 + bar_width, cur1[[p]], cur1[[p]] + h, x2, n2$y0[i], n2$y1[i])
    b$id <- length(bands) + 1
    b$fill <- unname(colors[n2$outcome[i]])
    b$alpha <- alpha[1]
    bands[[length(bands) + 1]] <- b
    cur1[[p]] <- cur1[[p]] + h
  }
  cur3 <- stats::setNames(n3$y0, n3$node)
  for (i in seq_len(nrow(n2))) {
    h <- n2$value[i] * sc
    o <- n2$outcome[i]
    b <- wjp_bezier_band(x2 + bar_width, n2$y0[i], n2$y1[i], x3, cur3[[o]], cur3[[o]] + h)
    b$id <- length(bands) + 1
    b$fill <- unname(colors[o])
    b$alpha <- alpha[2]
    bands[[length(bands) + 1]] <- b
    cur3[[o]] <- cur3[[o]] + h
  }
  bands <- do.call(rbind, bands)
  bands <- bands[order(bands$id), , drop = FALSE]

  bars <- rbind(
    data.frame(x = x1, y0 = n1$y0, y1 = n1$y1, fill = node_color),
    data.frame(x = x2, y0 = n2$y0, y1 = n2$y1, fill = unname(colors[n2$outcome])),
    data.frame(x = x3, y0 = n3$y0, y1 = n3$y1, fill = unname(colors[n3$node]))
  )
  bars <- bars[bars$y1 > bars$y0, , drop = FALSE]

  # Boxes: label lines, value, and note, centered on each bar
  vface <- wjp_face(value_fontface)
  v_weight <- if (grepl("semibold", value_fontface)) 600 else if (grepl("bold", value_fontface)) 700 else 400
  v_italic <- grepl("italic", value_fontface)
  lh <- label_size * line_height
  nodes <- rbind(
    transform(n1[, c("node", "label", "text", "note", "y0", "y1")], xc = x1 + bar_width / 2),
    transform(n2[, c("node", "label", "text", "note", "y0", "y1")], xc = x2 + bar_width / 2),
    transform(n3[, c("node", "label", "text", "note", "y0", "y1")], xc = x3 + bar_width / 2)
  )
  nodes$value_colour <- value_colour_of(nodes$node)
  boxes <- list()
  rows <- list()
  for (i in seq_len(nrow(nodes))) {
    lines <- if (nzchar(nodes$label[i])) strsplit(nodes$label[i], "\n", fixed = TRUE)[[1]] else character()
    val <- if (nzchar(nodes$text[i])) nodes$text[i] else character()
    note <- if (nzchar(nodes$note[i])) strsplit(nodes$note[i], "\n", fixed = TRUE)[[1]] else character()
    txt <- c(lines, val, note)
    if (length(txt) == 0) next
    kind <- c(rep("label", length(lines)), rep("value", length(val)), rep("note", length(note)))
    wd <- vapply(seq_along(txt), function(j) {
      switch(kind[j],
             label = wjp_text_width_pt(txt[j], label_size),
             value = wjp_text_width_pt(txt[j], label_size, vface$family, v_weight, v_italic),
             note  = wjp_text_width_pt(txt[j], note_size, wjp_font_family(), 400, TRUE))
    }, numeric(1))
    w <- max(wd) + 2 * box_padding[2]
    h <- lh * length(txt) + 2 * box_padding[1]
    yc <- (nodes$y0[i] + nodes$y1[i]) / 2
    x0 <- nodes$xc[i] - w / 2
    y0 <- yc - h / 2
    boxes[[length(boxes) + 1]] <- data.frame(x0 = x0, y0 = y0, w = w, h = h)
    rows[[length(rows) + 1]] <- data.frame(
      x = nodes$xc[i],
      y = y0 + box_padding[1] + lh * 0.8 + lh * (seq_along(txt) - 1),
      label = txt, kind = kind,
      colour = ifelse(kind == "value", nodes$value_colour[i],
                      ifelse(kind == "note", note_colour, label_colour)),
      stringsAsFactors = FALSE
    )
  }
  boxes <- do.call(rbind, boxes)
  rows <- do.call(rbind, rows)

  # ---------------------------------------------------------------------------
  # Plot
  # ---------------------------------------------------------------------------
  plt <- ggplot2::ggplot() +
    ggplot2::geom_polygon(
      data = bands,
      ggplot2::aes(x = x, y = y, group = id, fill = I(fill), alpha = I(alpha)),
      colour = NA
    ) +
    ggplot2::geom_rect(
      data = bars,
      ggplot2::aes(xmin = x, xmax = x + bar_width, ymin = y0, ymax = y1, fill = I(fill)),
      colour = NA
    )
  if (!is.null(boxes) && nrow(boxes) > 0) {
    rr <- wjp_round_rect_df(boxes$x0, boxes$y0, boxes$w, boxes$h, box_radius)
    plt <- plt + ggplot2::geom_polygon(
      data = rr, ggplot2::aes(x = x, y = y, group = id),
      fill = box_fill, colour = box_border, linewidth = wjp_pt_line(box_border_width)
    )
  }
  if (!is.null(rows) && nrow(rows) > 0) {
    lab_rows <- rows[rows$kind == "label", , drop = FALSE]
    val_rows <- rows[rows$kind == "value", , drop = FALSE]
    note_rows <- rows[rows$kind == "note", , drop = FALSE]
    if (nrow(lab_rows) > 0) {
      plt <- plt + ggplot2::geom_text(
        data = lab_rows, ggplot2::aes(x = x, y = y, label = label, colour = I(colour)),
        family = wjp_font_family(), size = wjp_pt_text(label_size), vjust = 0
      )
    }
    if (nrow(val_rows) > 0) {
      plt <- plt + ggplot2::geom_text(
        data = val_rows, ggplot2::aes(x = x, y = y, label = label, colour = I(colour)),
        family = vface$family, fontface = vface$fontface,
        size = wjp_pt_text(label_size), vjust = 0
      )
    }
    if (nrow(note_rows) > 0) {
      plt <- plt + ggplot2::geom_text(
        data = note_rows, ggplot2::aes(x = x, y = y, label = label, colour = I(colour)),
        family = wjp_font_family(), fontface = "italic",
        size = wjp_pt_text(note_size), vjust = 0
      )
    }
  }
  if (!is.null(headers)) {
    hface <- wjp_face(header_fontface)
    head_rows <- do.call(rbind, lapply(seq_len(3), function(j) {
      ls <- strsplit(headers[j], "\n", fixed = TRUE)[[1]]
      if (length(ls) == 0) return(NULL)
      data.frame(x = c(x1, x2, x3)[j] + bar_width / 2,
                 y = header_baseline + header_size * header_lineheight * (seq_along(ls) - 1),
                 label = ls, stringsAsFactors = FALSE)
    }))
    if (!is.null(head_rows)) {
      plt <- plt + ggplot2::geom_text(
        data = head_rows, ggplot2::aes(x = x, y = y, label = label),
        family = hface$family, fontface = hface$fontface,
        size = wjp_pt_text(header_size), colour = header_colour, vjust = 0
      )
    }
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
