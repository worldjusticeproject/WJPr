# Every option of wjp_funnel(), one chart per argument.
#
# Run from the repository root:
#   Rscript examples/funnel.R
#
# Each example is saved as examples/funnel_<name>.png with wjp_save(); the
# charts have a definite size (`width` or `panel_width`), so no size is given.
# All values are fictional, not survey results.

pkgload::load_all(".", quiet = TRUE)
wjp_fonts(engine = "systemfonts") # static Lato files, measured exactly by wjp_save()

out_dir <- "examples"
save_funnel <- function(plot, name, ...) {
  file <- file.path(out_dir, paste0("funnel_", name, ".png"))
  wjp_save(plot, file, png_dpi = 200, ...)
  message("Saved: ", file)
  invisible(plot)
}

# Stages of the justice journey: one row per stage, value in percent
journey <- data.frame(
  stage = c("Experienced a legal problem",
            "Had access to information and advice",
            "Obtained appropriate assistance\nwhen they needed it",
            "Turned to a dispute resolution\nmechanism when they needed it"),
  value = c(78.3, 61.4, 31.9, 28.5),
  rank  = c(1, 2, 3, 4),
  stringsAsFactors = FALSE
)
journey$text <- paste0(round(journey$value), "%")

# Shortcut: the journey data with the required columns and a 6.5 in figure
funnel <- function(data = journey, ...) {
  wjp_funnel(data, target = "value", grouping = "stage", width = 468, ...)
}


# -----------------------------------------------------------------------------
# Data: target, grouping, labels, order
# -----------------------------------------------------------------------------

# 1. Required arguments only. Without `labels`, values print as rounded
#    percentages of `target`; stages are drawn in data order.
save_funnel(funnel(), "basic")

# 2. `labels`: a column printed as given (no reformatting).
labelled <- journey
labelled$text <- paste0(formatC(labelled$value, format = "f", digits = 1), "%")
save_funnel(funnel(labelled, labels = "text"), "labels")

# 3. `order`: a column with the display order (top to bottom). Here `rank`
#    puts the smallest stage at the top, so the funnel widens downwards.
ascending <- journey
ascending$rank <- rank(ascending$value)
save_funnel(funnel(ascending, labels = "text", order = "rank"), "order")

# 4. Missing values: an NA stage draws no bar and no value, and the
#    connectors meet at the center.
missing <- journey
missing$value[3] <- NA
save_funnel(funnel(missing), "missing")

# 5. Any number of stages (six here). The widest bar always spans the bar area.
six <- data.frame(
  stage = c("Experienced a legal problem", "Recognized it as a legal problem",
            "Looked for information", "Obtained advice",
            "Took action", "Problem resolved"),
  value = c(100, 74, 58, 41, 27, 15)
)
save_funnel(funnel(six, bar_height = 30), "many_stages")

# 6. A single stage: no connectors are drawn.
save_funnel(funnel(journey[1, ]), "single_stage")


# -----------------------------------------------------------------------------
# Geometry: bar_height, width, panel_width, margins
# (bars are always 18 pt apart)
# -----------------------------------------------------------------------------

# 7. `bar_height` (points): short bars...
save_funnel(funnel(labels = "text", bar_height = 24), "bar_height_short")

# 8. ...or tall bars.
save_funnel(funnel(labels = "text", bar_height = 56), "bar_height_tall")

# 9. `width` (points): the whole figure is 4.5 in wide; the bar area takes
#    what the label column and the margins leave.
save_funnel(wjp_funnel(journey, "value", "stage", labels = "text", width = 324),
            "width_narrow")

# 10. `panel_width` (points): the bar area is exactly 200 pt wide and the
#     figure width follows from the label column.
save_funnel(wjp_funnel(journey, "value", "stage", labels = "text", panel_width = 200),
            "panel_width")

# 11. Neither `width` nor `panel_width`: the bar area fills the device, so
#     the size must be given when saving. The height stays fixed by the bars:
#     4 bars x 40 pt + 3 gaps x 18 pt + 8 pt of margins = 222 pt.
save_funnel(wjp_funnel(journey, "value", "stage", labels = "text"),
            "fill_device", width = 576, height = 222, units = "pt")

# 12. `margins` (points: top, right, bottom, left). The border (a `ptheme`
#     plot background) shows the 24 pt margins around the chart.
framed <- WJP_theme() +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = NA, colour = "#A8A8C8"))
save_funnel(funnel(labels = "text", margins = c(24, 24, 24, 24), ptheme = framed),
            "margins")


# -----------------------------------------------------------------------------
# Connectors: connectors, connector_color
# (connectors are always drawn at an opacity of 0.45)
# -----------------------------------------------------------------------------

# 13. `connectors = FALSE`: bars only.
save_funnel(funnel(labels = "text", connectors = FALSE), "no_connectors")

# 14. `connector_color`.
save_funnel(funnel(labels = "text", connector_color = "#f26b21"), "connector_color")


# -----------------------------------------------------------------------------
# Bars and values: color, value_face, value_size, value_color
# -----------------------------------------------------------------------------

# 15. `color`: one color for every bar, with connectors in the same hue.
save_funnel(funnel(labels = "text", color = "#2894aa", connector_color = "#2894aa"),
            "color")

# 16. `value_face`: "plain", "bold" (default), "italic", "bold.italic",
#     "medium", "medium.italic", "semibold", or "semibold.italic".
save_funnel(funnel(labels = "text", value_face = "semibold.italic"), "value_face")

# 17. `value_size` (points) and `value_color`, on a light bar.
save_funnel(funnel(labels = "text", color = wjp_colors()[["eu"]],
                   value_size = 14, value_color = wjp_colors()[["text"]]),
            "value_style")


# -----------------------------------------------------------------------------
# Stage labels: label_size, label_colour, label_width, label_gap,
# label_lineheight
# -----------------------------------------------------------------------------

# 18. `label_size` (points) and `label_colour`.
save_funnel(funnel(labels = "text", label_size = 12, label_colour = "#1A1A1A"),
            "label_style")

# 19. `label_width` (points): labels without line breaks wrap to 120 pt.
#     Labels with "\n" keep their own breaks.
one_line <- journey
one_line$stage <- gsub("\n", " ", one_line$stage, fixed = TRUE)
save_funnel(funnel(one_line, labels = "text", label_width = 120), "label_width")

# 20. Without `label_width`, labels without breaks stay on one line and the
#     label column grows to fit them.
save_funnel(funnel(one_line, labels = "text"), "label_one_line")

# 21. `label_gap` (points): distance between the label column and the bars.
save_funnel(funnel(labels = "text", label_gap = 48), "label_gap")

# 22. `label_lineheight`: distance between label baselines, in multiples of
#     the label size.
save_funnel(funnel(labels = "text", label_lineheight = 1.8), "label_lineheight")


# -----------------------------------------------------------------------------
# Theme: ptheme
# -----------------------------------------------------------------------------

# 23. `ptheme`: elements that differ from WJP_theme() are applied last, here a
#     tinted plot background. (The stage labels sit in the left plot margin,
#     so a ggplot title would start at the bars, not at the labels.)
tinted <- WJP_theme() +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = "#F2F2F7", colour = NA))
save_funnel(funnel(labels = "text", ptheme = tinted, margins = c(12, 12, 12, 12)),
            "ptheme")


# -----------------------------------------------------------------------------
# Everything together
# -----------------------------------------------------------------------------

# 24. Every argument at once: shuffled rows put back in journey order with
#     `order`, one-decimal labels, wrapped stage labels, custom colors and
#     geometry.
report <- one_line[c(3, 1, 4, 2), ]
report$text <- paste0(formatC(report$value, format = "f", digits = 1), "%")
save_funnel(wjp_funnel(
  report,
  target           = "value",
  grouping         = "stage",
  labels           = "text",
  order            = "rank",
  bar_height       = 34,
  color            = "#482d8b",
  connector_color  = "#A8A8C8",
  value_face       = "bold",
  value_size       = 12,
  value_color      = "#FFFFFF",
  label_size       = 10,
  label_colour     = "#524F4C",
  label_width      = 150,
  label_gap        = 20,
  label_lineheight = 1.3,
  width            = 468,
  margins          = c(8, 8, 8, 8)
), "combined")
