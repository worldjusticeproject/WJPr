# dev/report-fidelity-new.R -- builders of dev/report-fidelity.R for the chart
# types added in WJPr 1.2.0: wjp_funnel(), wjp_cards(), wjp_heatmap(),
# wjp_scatter(), wjp_network(), wjp_upset(), and wjp_sankey(). Sourced by
# dev/report-fidelity.R; every figure is drawn with function arguments only.

fid_funnel <- function(d, spec, country) {
  col <- FID_ST$col
  d <- d[d$kind == "stage", ]
  wjp_funnel(d, target = "value", grouping = "label", labels = "text", order = "order",
             color = col[["main"]], connector_color = col[["eu"]], connector_alpha = 0.45,
             value_face = "semibold.italic", value_size = 11, label_size = 10,
             label_colour = col[["text"]], label_width = 190, width = spec$w_in * 72)
}

fid_cards <- function(d, spec, country) {
  col <- FID_ST$col
  d <- d[d$kind == "card", ]
  # the reference card of each comparison is the one without a difference
  ref_dir <- if (identical(as.integer(spec$fig), 32L)) "col" else "row"
  wjp_cards(d, rows = "grouping", cols = "label", target = "value", labels = "text",
            deltas = "text2", ref = ref_dir, limits = c(d$lo[1], d$hi[1]),
            colors = c(col[["card_low"]], col[["main"]]), width = spec$w_in * 72,
            label_colour = col[["text"]], header_colour = col[["main"]],
            delta_color = col[["delta"]])
}

fid_matrix <- function(d, spec, country) {
  col <- FID_ST$col
  k <- (if (is.na(spec$base_pt)) 10 else spec$base_pt) / 10
  d <- d[d$kind == "cell", ]
  bands <- unique(d$text2[nzchar(d$text2)])
  bands <- bands[order(vapply(bands, function(b) min(d$value[d$text2 == b], na.rm = TRUE), 0))]
  d$band <- factor(ifelse(nzchar(d$text2), d$text2, NA), levels = bands)
  wjp_heatmap(d, x = "label", y = "grouping", fill = "band", labels = "text",
              cvec = stats::setNames(c(col[["track"]], col[["eu"]], col[["main"]])[seq_along(bands)], bands),
              x_title = "Among people who experienced problems with:",
              y_title = "People who also experienced:",
              border_width = 0.8 / k * ggplot2::.pt * 0.75, label_size = 3.6 / k * ggplot2::.pt,
              axis_text_size = 11 / k, title_size = 12 / k, title_colour = col[["main"]],
              legend_text_size = 11 / k, legend_key_size = 17.28 / k,
              legend_justification = "center",
              margins = c(10, 45, 10, 10) / k * 72 / 72.27,
              ptheme = WJP_theme(base_theme = ggplot2::theme_minimal(base_size = 11 / k),
                                 text_colour = col[["text"]]))
}

fid_scatter <- function(d, spec, country) {
  col <- FID_ST$col
  k <- (if (is.na(spec$base_pt)) 10 else spec$base_pt) / 10
  d$hollow <- if ("n" %in% names(d)) d$n < 30 else FALSE
  wjp_scatter(
    d, x = "value", y = "value2", labels = "label", facet = "grouping",
    highlight = c("Public Services", "Consumer", "Community", "Money & Debt", "Housing", "Family"),
    hollow = "hollow", colors = c(col[["main"]], "#c4c4c4"),
    point_size = 7.35, point_stroke = 1.3, trend = "lm", repel = TRUE, seed = 7,
    label_size = 4 / k * ggplot2::.pt, label_colour = col[["main"]],
    xlim = c(0, 50), ylim = c(4, 8), y_breaks = 4:8, x_labels = function(x) paste0(x, "%"),
    x_title = "Prevalence", y_title = "Mean seriousness (0-10)",
    strip_size = 14 / k, trend_width = 0.5 / k * ggplot2::.pt * 0.75,
    ptheme = WJP_theme(base_size = 12 / k, text_colour = col[["text"]],
                       base_theme = ggplot2::theme_minimal(base_size = 11 / k)) +
      ggplot2::theme(axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 11 / 4 / k)),
                     axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 11 / 4 / k)),
                     plot.margin = ggplot2::margin(11 / 2 / k, 11 / 2 / k, 11 / 2 / k, 11 / 2 / k))
  )
}

fid_network <- function(d, spec, country) {
  nodes <- d[d$kind == "node", c("label", "text", "x", "y")]
  breaks <- c("Public Services" = "Public\nServices", "Citizenship & ID" = "Citizenship\n& ID",
              "Money & Debt" = "Money &\nDebt", "Law Enforcement" = "Law\nEnforcement")
  nodes$name <- ifelse(nodes$label %in% names(breaks), breaks[nodes$label], nodes$label)
  ed <- d[d$kind == "edge", ]
  ab <- strsplit(ed$label, "|", fixed = TRUE)
  edges <- data.frame(from = vapply(ab, `[`, "", 1), to = vapply(ab, `[`, "", 2), lift = ed$value)
  src_scale <- 518.03                                   # source SVG units per layout unit
  ks <- spec$w_in * 72 / (src_scale * diff(range(nodes$x)) + 82)
  wjp_network(
    nodes, edges, labels = "name", ids = "label", value_labels = "text", weight = "lift",
    node_radius = 35 / src_scale, padding = 41 / src_scale,
    colors = c("#A8A8C8", "#39396B"), border_color = "#2C3E50", border_width = 1.2 * ks,
    edge_color = "#5D6D7E", edge_width = c(0.8, 4.2) * ks, edge_gamma = 0.8,
    edge_alpha = function(w) pmin(0.85, (w - 1) * 0.35 + 0.2),
    label_size = 10.5 * ks, label_fontface = "bold", label_lineheight = 1.15
  )
}

fid_upset <- function(d, spec, country) {
  col <- FID_ST$col
  k <- (if (is.na(spec$base_pt)) 10 else spec$base_pt) / 10
  rows <- d[d$kind == "row", ]
  sets <- d[d$kind == "set", ]
  wjp_upset(rows, intersections = "label", target = "value", labels = "text",
            sets = data.frame(set = sets$label, size = sets$value, text = sets$text),
            set_target = "size", set_labels = "text",
            bar_color = col[["main"]], dot_colors = c(col[["text"]], col[["track"]]),
            width = spec$w_in * 72, height = spec$h_in * 72, spacing = 2 * 5.48 / k,
            y_title = "% of people within\nthe justice gap", title_size = 11 / k,
            label_size = 0.8 * 12.8 / k, label_gap = 4.43 / k,
            value_size = 3.6 * ggplot2::.pt / k, value_colour = col[["main"]],
            set_value_size = 3.6 * ggplot2::.pt / k, set_value_colour = col[["text"]],
            dot_radius = 0.375 * (3.5 / k * ggplot2::.pt + 0.5 / k * ggplot2::.stroke / 2),
            segment_width = 0.5 / k * ggplot2::.pt * 0.75,
            grid_width = 0.5 / k * ggplot2::.pt * 0.75)
}

# Labels, headers and notes of the two sankeys come from the design of the
# report pipeline (sankey_def() in src_reports R/05_charts.R), read at run time
fid_sankey_def <- function(which) {
  root <- Sys.getenv("SRC_REPORTS_ROOT")
  env <- new.env()
  suppressMessages({
    sys.source(file.path(root, "R", "04_svg.R"), envir = env)
    sys.source(file.path(root, "R", "05_charts.R"), envir = env)
  })
  env$sankey_def(which)
}

fid_sankey <- function(d, spec, country) {
  col <- FID_ST$col
  which <- if ("turned" %in% d$label[d$grouping == "2"]) "drm" else "assistance"
  s <- fid_sankey_def(which)
  join <- function(x) vapply(x, paste, "", collapse = "\n")
  lab <- c(join(s$LAB1), join(s$LAB2), join(s$LAB3))
  x <- data.frame(
    column = as.integer(d$grouping), node = d$label, value = d$value, text = d$text,
    label = unname(lab[d$label]),
    parent = unname(unlist(s$C2)[d$label]), outcome = unname(unlist(s$M)[d$label]),
    note = unname(unlist(s$NOTE3)[ifelse(d$grouping == "3", d$label, NA)]),
    stringsAsFactors = FALSE
  )
  wjp_sankey(x, column = "column", node = "node", target = "value", value_labels = "text",
             parent = "parent", outcome = "outcome", labels = "label", notes = "note",
             headers = join(s$headers),
             colors = c(access = col[["main"]], no_access = col[["eu"]], excluded = col[["excluded"]]),
             value_colors = c(excluded = col[["eu_text"]]),
             width = spec$w_in * 72)
}

FID_BUILDERS <- c(FID_BUILDERS, list(
  funnel  = fid_funnel,
  cards   = fid_cards,
  matrix  = fid_matrix,
  scatter = fid_scatter,
  network = fid_network,
  upset   = fid_upset,
  sankey  = fid_sankey
))
