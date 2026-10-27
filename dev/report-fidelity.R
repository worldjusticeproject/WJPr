# dev/report-fidelity.R -- draw the figures of a WJP country report with WJPr
# arguments only (no post-hoc ggplot edits) and measure how close they are to
# the published figures.
#
# The reference data and the published PNGs live in the report pipeline
# (src_reports), outside this package:
#   <root>/reference/<country>/Figure_NN_<slug>.csv      values, texts and bar fractions
#   <root>/reference/<country>/published/Figure_NN_*.png  published figures (96 dpi)
#   <root>/manifest/figures.csv                           type and size of each figure
#
# Usage (from the repository root):
#   SRC_REPORTS_ROOT=<path to src_reports> Rscript dev/report-fidelity.R [--figs 1,9,13] [--out <dir>]
#
# Output: one PNG per figure (300 dpi, manifest size), a side-by-side comparison
# (published | WJPr) and fidelity.csv with the ink f1 against the published PNG
# (1 = same drawing; see fid_similarity()). tests/testthat/test-report-fidelity.R
# runs the same builders when SRC_REPORTS_ROOT is set.

if (!"WJPr" %in% loadedNamespaces()) suppressMessages(pkgload::load_all(".", quiet = TRUE))

FID_ST <- list(
  size_label = 10, size_value = 9, size_legend = 9.5, size_axis = 9,
  col = c(wjp_colors(), exp = "#B200AA")
)

# ---------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------

fid_manifest <- function(root) {
  m <- utils::read.csv(file.path(root, "manifest", "figures.csv"), stringsAsFactors = FALSE)
  m[, c("fig", "slug", "tipo", "w_in", "h_in", "base_pt")]
}

fid_country <- function(root, country = "hungary") {
  f <- file.path(root, "config", paste0(country, ".yml"))
  if (!file.exists(f)) return("Country")
  x <- grep("^country:", readLines(f, warn = FALSE), value = TRUE)
  if (!length(x)) return("Country")
  x <- sub("\\s+#.*$", "", x[1])
  gsub("^country:\\s*[\"']?|[\"']?\\s*$", "", x)
}

fid_reference <- function(root, spec, country = "hungary") {
  f <- file.path(root, "reference", country, sprintf("Figure_%02d_%s.csv", spec$fig, spec$slug))
  d <- utils::read.csv(f, stringsAsFactors = FALSE, na.strings = "NA")
  for (nm in c("text", "text2", "grouping", "label")) {
    if (nm %in% names(d)) d[[nm]][is.na(d[[nm]])] <- ""
  }
  d[order(d$order), , drop = FALSE]
}

# ---------------------------------------------------------------------------
# Builders: one per figure type, WJPr arguments only
# ---------------------------------------------------------------------------

fid_grouped <- function(d, spec, country) {
  col <- FID_ST$col
  scale <- if (!any(grepl("%", d$text, fixed = TRUE))) 10 else 100
  rows <- d[d$kind == "row", ]
  avg <- d[d$kind == "avg", ]
  x <- data.frame(grp = rows$grouping, lvl = rows$label, v = rows$frac * scale,
                  lab = rows$text, stringsAsFactors = FALSE)
  groups <- unique(x$grp)
  lev <- stats::setNames(lapply(groups, function(g) x$lvl[x$grp == g]), groups)
  wide <- identical(as.integer(spec$fig), 27L)        # track fills the 6.5 in width
  W <- spec$w_in * 72
  lay <- wjp_layout(
    label_width = 149, label_gap = 6, value_gap = 5, value_width = 27,
    track_width = if (wide) W - 149 - 6 - 5 - 27 else 250,
    row_height = if (wide) 22 else 15.5, bar_height = if (wide) 18 else 13.5,
    header_height = if (wide) 26 else 22, header_baseline = if (wide) 20 else 17,
    margins = c(2, 0, 4, 0)
  )
  wjp_groupbars(
    x, "v", "grp", "lvl", labels = "lab",
    colors = c(col[["main"]], col[["track"]]), show_complement = scale == 100,
    scale_max = scale, group_order = groups, level_order = lev,
    show_national = nrow(avg) > 0, national_style = "bar",
    national_value = if (nrow(avg)) stats::setNames(avg$frac * scale, avg$label) else NULL,
    national_value_label = if (nrow(avg)) avg$text else NULL,
    label_position = if (scale == 100) "column" else "end",
    value_size = FID_ST$size_value, value_fontface = "semibold.italic",
    highlight_fontface = "semibold.italic", header_fontface = "semibold.italic",
    label_colour = col[["text"]], label_size = FID_ST$size_label,
    layout = lay
  )
}

fid_hbars <- function(d, spec, country) {
  col <- FID_ST$col
  rows <- d[d$kind == "row", ]
  x <- data.frame(label = rows$label, value = rows$frac * 100, text = rows$text,
                  ord = seq_len(nrow(rows)), stringsAsFactors = FALSE)
  pitch <- 22
  # label column from x = 2 to L + 12 = 184; rows from 20 pt; grid from 18 pt
  wjp_bars(
    x, "value", "label", labels = "text", order = "ord",
    cvec = stats::setNames(rep(col[["main"]], nrow(x)), x$label),
    direction = "horizontal", value_position = "outside",
    value_offset = 5, value_size = FID_ST$size_value,
    value_fontface = "semibold.italic", value_colors = col[["text"]],
    label_align = "left", label_colour = col[["text"]], label_size = FID_ST$size_label,
    expand_discrete = c(0.5 + 2 / pitch, (spec$h_in * 72 - (20 + nrow(x) * pitch)) / pitch + 0.5),
    layout = wjp_layout(label_width = 172 + 12 - 2 - 12, label_gap = 12, track_width = 300,
                        value_gap = 5, value_width = spec$w_in * 72 - 184 - 300 - 5,
                        row_height = pitch, bar_height = 18,
                        # axis labels with their baseline at 12 pt, grid from 18 pt
                        margins = c(12 - WJP_TEXT_BOX_EM * FID_ST$size_label, 0, 0, 2)),
    ptheme = WJP_theme(text_colour = col[["text"]]) +
      ggplot2::theme(axis.text.x.top = ggplot2::element_text(size = FID_ST$size_label, vjust = 0,
                                                             margin = wjp_margin_bp(b = 6)))
  )
}

fid_paired <- function(d, spec, country) {
  col <- FID_ST$col
  rows <- d[d$kind == "row", ]
  n <- nrow(rows)
  x <- data.frame(
    label = rep(rows$label, 2), ord = rep(seq_len(n), 2),
    series = factor(rep(c(country, "EU Average"), each = n), levels = c(country, "EU Average")),
    value = c(rows$frac, rows$frac2) * 100, text = c(rows$text, rows$text2),
    stringsAsFactors = FALSE
  )
  W <- spec$w_in * 72
  L <- ceiling(wjp_text_width_pt(rows$label, FID_ST$size_label)) + 2
  track <- W - L - 6 - 5 - 27
  pitch <- 21
  wjp_bars(
    x, "value", "label", labels = "text", colors = "series", order = "ord",
    cvec = stats::setNames(c(col[["main"]], col[["eu"]]), c(country, "EU Average")),
    direction = "horizontal", position = "dodge", dodge_width = 2 * (8 + 2) / pitch,
    track = TRUE, track_color = col[["track"]],
    value_position = "column", value_offset = 5, value_size = FID_ST$size_value,
    value_fontface = "semibold.italic",
    value_colors = stats::setNames(c(col[["main"]], col[["eu_text"]]), c(country, "EU Average")),
    value_axis = FALSE, grid = FALSE, label_align = "right",
    label_colour = col[["text"]], label_size = FID_ST$size_label,
    show_legend = TRUE, legend_position = c(0, 1), legend_text_size = FID_ST$size_legend,
    legend_key_size = 9,
    expand_discrete = c(0.5 + 20 / pitch, 0.5 + 4 / pitch),
    layout = wjp_layout(label_width = L, label_gap = 6, track_width = track, value_gap = 5,
                        value_width = 27, row_height = pitch, bar_height = 8),
    ptheme = WJP_theme() + ggplot2::theme(
      legend.text = ggplot2::element_text(face = "plain", colour = col[["text"]],
                                          margin = wjp_margin_bp(l = 4)),
      legend.key.spacing.x = wjp_bp(14),
      legend.margin = wjp_margin_bp(2, 0, 0, 0)
    )
  )
}

fid_columns <- function(d, spec, country) {
  col <- FID_ST$col
  rows <- d[d$kind == "row", ]
  n <- nrow(rows)
  x <- data.frame(
    label = rep(rows$label, 2), ord = rep(seq_len(n), 2),
    series = factor(rep(c(country, "EU Average"), each = n), levels = c(country, "EU Average")),
    value = c(rows$value, rows$value2), text = c(rows$text, rows$text2),
    stringsAsFactors = FALSE
  )
  W <- spec$w_in * 72
  gw <- (W - 12) / n
  vmax <- max(x$value, na.rm = TRUE)
  col_h <- 180
  yb <- 24 + FID_ST$size_value + 6 + col_h
  wjp_bars(
    x, "value", "label", labels = "text", colors = "series", order = "ord",
    cvec = stats::setNames(c(col[["main"]], col[["eu"]]), c(country, "EU Average")),
    position = "dodge", width = 2 * 46 / gw, dodge_width = 2 * (46 + 4) / gw,
    value_position = "outside", value_offset = 4, value_size = FID_ST$size_value,
    value_fontface = "semibold.italic",
    value_colors = stats::setNames(c(col[["main"]], col[["eu_text"]]), c(country, "EU Average")),
    limits = c(0, vmax * yb / col_h), expand_mult = 0, expand_discrete = 0.5,
    value_axis = FALSE, grid = FALSE, ylab = NULL, baseline = TRUE,
    baseline_color = col[["text"]],
    label_wrap = max(25, floor((gw - 10) / (0.5 * FID_ST$size_label))), label_size = FID_ST$size_label, label_colour = col[["text"]],
    label_lineheight = 1.22 / 1.2,
    show_legend = TRUE, legend_position = c(0, 1), legend_text_size = FID_ST$size_legend,
    legend_key_size = 9,
    ptheme = WJP_theme() + ggplot2::theme(
      legend.text = ggplot2::element_text(face = "plain", colour = col[["text"]],
                                          margin = wjp_margin_bp(l = 4)),
      legend.key.spacing.x = wjp_bp(14),
      legend.margin = wjp_margin_bp(3, 0, 0, 0),
      plot.margin = wjp_margin_bp(0, 6, 4, 6),
      axis.text.x = ggplot2::element_text(margin = wjp_margin_bp(t = 6))
    )
  )
}

fid_severity <- function(d, spec, country) {
  col <- FID_ST$col
  k <- 1 / 1.3
  bars <- d[d$kind == "bar", ]
  x <- data.frame(
    level = bars$label, sev = as.numeric(bars$label),
    series = factor(ifelse(bars$grouping == "EU Average", "EU Average", country),
                    levels = c(country, "EU Average")),
    value = dplyr::coalesce(bars$value, 0), stringsAsFactors = FALSE
  )
  wjp_bars(
    x, "value", "level", colors = "series", order = "sev",
    cvec = stats::setNames(c(col[["main"]], col[["eu"]]), c(country, "EU Average")),
    position = "dodge", width = 0.75, dodge_width = 0.8,
    # continuous axis of the original: half a group plus 5% of the range
    expand_discrete = 0.8 / 4 + 0.75 / 4 + 0.05 * (10 + 2 * (0.8 / 4 + 0.75 / 4)),
    ref_lines = data.frame(axis = "category", position = 3.5 - min(x$sev) + 1,
                           colour = col[["text"]], linewidth = 0.4 * k * ggplot2::.pt * 0.75),
    limits = c(0, NA), expand_mult = c(0, 0.08), breaks = ggplot2::waiver(),
    ylab = NULL, show_legend = TRUE, legend_text_size = 13 * k, legend_key_size = 17.28 * k,
    legend_fontface = "plain", legend_justification = "center",
    # the theme of the original (theme_minimal(11) with 13 pt text) as a
    # partial theme, so its legend and spacing win over the chart defaults
    ptheme = WJP_theme(base_size = 13 * k, text_colour = col[["text"]], grid = "y",
                       grid_colour = "#eeeeee", grid_linetype = "solid") +
      ggplot2::theme(
        panel.grid.major.y = ggplot2::element_line(colour = "#eeeeee", linewidth = 0.5 * k,
                                                   linetype = "solid"),
        axis.text.x = ggplot2::element_text(margin = ggplot2::margin(t = 4.95 * k), vjust = 1),
        axis.text.y = ggplot2::element_text(margin = ggplot2::margin(r = 4.95 * k), hjust = 1),
        legend.text = ggplot2::element_text(size = 13 * k, face = "plain", colour = col[["text"]],
                                            margin = ggplot2::margin(l = 0.5 * 13 * k)),
        legend.key.spacing.x = ggplot2::unit(5.5 * k, "pt"),
        legend.margin = ggplot2::margin(5.5 * k, 5.5 * k, 5.5 * k, 5.5 * k),
        legend.box.margin = ggplot2::margin(0, 0, 0, 0),
        legend.box.spacing = ggplot2::unit(11 * k, "pt"),
        plot.margin = ggplot2::margin(5.5 * k, 5.5 * k, 5.5 * k, 5.5 * k))
  )
}

fid_dumbbell <- function(d, spec, country) {
  col <- FID_ST$col
  rows <- d[d$kind != "header", ]
  grp <- ifelse(rows$kind == "avg", "", rows$grouping)
  long <- rbind(
    data.frame(cat = rows$label, grp = grp, serie = "Perception", v = rows$frac * 100,
               lab = rows$text, stringsAsFactors = FALSE),
    data.frame(cat = rows$label, grp = grp, serie = "Experience", v = rows$frac2 * 100,
               lab = rows$text2, stringsAsFactors = FALSE)
  )
  W <- spec$w_in * 72
  wjp_dumbbells(
    long, "v", "cat", colors = "serie", cgroups = c("Perception", "Experience"), labels = "lab",
    cvec = c(col[["main"]], col[["exp"]]),
    legend_labels = c("General population: perception",
                      "People with a non-trivial problem: experience"),
    legend_direction = "vertical", legend_text_size = FID_ST$size_legend,
    legend_key_size = 2 * 3.8,
    headers = "grp", header_fontface = "semibold.italic", header_colour = col[["main"]],
    highlight_levels = rows$label[rows$kind == "avg"], highlight_fontface = "semibold.italic",
    label_align = "right", label_colour = col[["text"]], label_size = FID_ST$size_label,
    breaks = seq(0, 100, 25), axis_line = TRUE, axis_line_color = col[["text"]],
    strips = FALSE, grid = FALSE, value_position = "outside", value_gap = 3,
    value_fontface = "semibold.italic", value_size = FID_ST$size_value,
    point_size = wjp_pt_point(3.8), point_stroke = 0,
    segment_color = col[["track"]], segment_width = wjp_pt_line(7),
    layout = wjp_layout(label_width = 84, label_gap = 6, track_width = W - 84 - 6 - 5 - 27,
                        value_gap = 5, value_width = 27, row_height = 18, header_height = 22,
                        header_baseline = 17, inset = c(3, 0), margins = c(0, 0, 0, 0)),
    ptheme = WJP_theme() + ggplot2::theme(
      axis.text.x.top = ggplot2::element_text(size = FID_ST$size_axis, colour = col[["text"]],
                                              vjust = 0, margin = wjp_margin_bp(b = 5)),
      legend.text = ggplot2::element_text(face = "plain", colour = col[["text"]],
                                          margin = wjp_margin_bp(l = 5)),
      legend.key.spacing.y = wjp_bp(0),
      legend.key.height = wjp_bp(14),
      legend.margin = wjp_margin_bp(-5.5, 0, 0, -0.5),
      legend.box.margin = wjp_margin_bp(0, 0, 0, 0),
      legend.box.spacing = wjp_bp(8)
    )
  )
}

FID_BUILDERS <- list(
  grouped_bars  = fid_grouped,
  hbars         = fid_hbars,
  paired_bars   = fid_paired,
  columns       = fid_columns,
  severity_bars = fid_severity,
  dumbbell      = fid_dumbbell
)

# Builders of the chart types added in WJPr 1.2.0 (wjp_funnel(), wjp_cards(),
# wjp_heatmap(), wjp_scatter(), wjp_network(), wjp_upset(), wjp_sankey())
if (file.exists("dev/report-fidelity-new.R")) source("dev/report-fidelity-new.R", local = TRUE)

# ---------------------------------------------------------------------------
# Similarity with the published figure
# ---------------------------------------------------------------------------

fid_read_png <- function(path) {
  img <- png::readPNG(path, info = TRUE)
  info <- attr(img, "info")
  if (length(dim(img)) == 2) img <- array(img, c(dim(img), 3))
  if (dim(img)[3] == 2) img <- array(img[, , 1], c(dim(img)[1:2], 3))
  if (dim(img)[3] == 4) {
    a <- as.vector(img[, , 4])
    img <- img[, , 1:3, drop = FALSE] * a + (1 - a)
  }
  dpi <- if (is.null(info$dpi) || !is.finite(info$dpi[[1]])) NA_real_ else round(info$dpi[[1]])
  list(img = img[, , 1:3, drop = FALSE], dpi = dpi)
}

fid_resample <- function(img, dpi_in, dpi_out = 96) {
  f <- dpi_out / dpi_in
  w <- max(1L, round(dim(img)[2] * f)); h <- max(1L, round(dim(img)[1] * f))
  k <- floor(dpi_in / dpi_out)
  if (k >= 2) {
    hh <- (dim(img)[1] %/% k) * k; ww <- (dim(img)[2] %/% k) * k
    out <- array(0, c(hh / k, ww / k, dim(img)[3]))
    for (i in seq_len(k)) for (j in seq_len(k)) {
      out <- out + img[seq(i, hh, by = k), seq(j, ww, by = k), , drop = FALSE]
    }
    img <- out / k^2
  }
  nn <- function(n_out, n_in) pmin(pmax(floor((seq_len(n_out) - 0.5) * n_in / n_out) + 1, 1), n_in)
  img[nn(h, dim(img)[1]), nn(w, dim(img)[2]), , drop = FALSE]
}

# Ink f1 at 96 dpi: "ink" = pixel with gray < 0.75; precision = new ink within
# r px of published ink, recall = published ink within r px of new ink.
fid_similarity <- function(png_new, png_pub, dpi_new = 300, r = 2L) {
  a <- fid_read_png(png_pub)
  b <- fid_resample(fid_read_png(png_new)$img, dpi_new)
  h <- min(dim(a$img)[1], dim(b)[1]); w <- min(dim(a$img)[2], dim(b)[2])
  gray <- function(img) 0.299 * img[seq_len(h), seq_len(w), 1] +
    0.587 * img[seq_len(h), seq_len(w), 2] + 0.114 * img[seq_len(h), seq_len(w), 3]
  ga <- gray(a$img); gb <- gray(b)
  ia <- ga < 0.75; ib <- gb < 0.75
  dilate <- function(m) {
    out <- m
    for (dy in -r:r) for (dx in -r:r) {
      ys <- seq_len(h) + dy; xs <- seq_len(w) + dx
      okY <- ys >= 1 & ys <= h; okX <- xs >= 1 & xs <= w
      out[okY, okX] <- out[okY, okX] | m[ys[okY], xs[okX]]
    }
    out
  }
  prec <- if (sum(ib)) sum(ib & dilate(ia)) / sum(ib) else NA_real_
  rec <- if (sum(ia)) sum(ia & dilate(ib)) / sum(ia) else NA_real_
  list(f1 = if (is.na(prec) || is.na(rec) || prec + rec == 0) NA_real_ else 2 * prec * rec / (prec + rec),
       precision = prec, recall = rec, mad = mean(abs(ga - gb)))
}

# Published | WJPr side by side at 96 dpi
fid_compose <- function(png_pub, png_new, out, dpi_new = 300) {
  a <- fid_read_png(png_pub)$img
  b <- fid_resample(fid_read_png(png_new)$img, dpi_new)
  h <- max(dim(a)[1], dim(b)[1])
  wa <- dim(a)[2]; wb <- dim(b)[2]
  img <- array(1, c(h, wa + 8 + wb, 3))
  img[seq_len(dim(a)[1]), seq_len(wa), ] <- a
  img[, wa + 1:8, ] <- 0.6
  img[seq_len(dim(b)[1]), wa + 8 + seq_len(wb), ] <- b
  png::writePNG(img, out)
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

fid_run <- function(root, figs = NULL, out = file.path(tempdir(), "wjpr-fidelity"),
                    country = "hungary", dpi = 300) {
  dir.create(file.path(out, "compare"), recursive = TRUE, showWarnings = FALSE)
  wjp_fonts(engine = "systemfonts")
  old <- options(wjpr.family = "Inter Tight")
  on.exit(options(old), add = TRUE)
  man <- fid_manifest(root)
  if (!is.null(figs)) man <- man[man$fig %in% figs, , drop = FALSE]
  ctry <- fid_country(root, country)
  rows <- lapply(seq_len(nrow(man)), function(i) {
    spec <- man[i, ]
    stem <- sprintf("Figure_%02d_%s", spec$fig, spec$slug)
    builder <- FID_BUILDERS[[spec$tipo]]
    base <- data.frame(fig = spec$fig, type = spec$tipo, stringsAsFactors = FALSE)
    if (is.null(builder)) return(cbind(base, status = "no builder", f1 = NA_real_, size = NA_character_))
    res <- tryCatch({
      d <- fid_reference(root, spec, country)
      p <- builder(d, spec, ctry)
      size <- wjp_plot_size(p)
      png_new <- file.path(out, paste0(stem, ".png"))
      wjp_save(p, png_new, width = spec$w_in, height = spec$h_in, png_dpi = dpi)
      pub <- file.path(root, "reference", country, "published", paste0(stem, ".png"))
      s <- if (file.exists(pub)) fid_similarity(png_new, pub, dpi) else list(f1 = NA_real_)
      if (file.exists(pub)) fid_compose(pub, png_new, file.path(out, "compare", paste0(stem, ".png")), dpi)
      cbind(base, status = "ok", f1 = round(s$f1, 3),
            size = if (is.null(size)) "flexible" else sprintf("%.3f x %.3f", size[1], size[2]))
    }, error = function(e) cbind(base, status = paste("error:", conditionMessage(e)), f1 = NA_real_,
                                 size = NA_character_))
    res
  })
  res <- do.call(rbind, rows)
  utils::write.csv(res, file.path(out, "fidelity.csv"), row.names = FALSE)
  res
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  opt <- function(k) { i <- match(k, args); if (is.na(i) || i == length(args)) NULL else args[i + 1] }
  root <- Sys.getenv("SRC_REPORTS_ROOT")
  if (!nzchar(root)) stop("Set SRC_REPORTS_ROOT to the src_reports folder.", call. = FALSE)
  figs <- if (is.null(opt("--figs"))) NULL else as.integer(strsplit(opt("--figs"), ",")[[1]])
  out <- if (is.null(opt("--out"))) file.path(tempdir(), "wjpr-fidelity") else opt("--out")
  res <- fid_run(root, figs, out)
  print(res, row.names = FALSE)
  cat("\nOutput:", normalizePath(out), "\n")
}
