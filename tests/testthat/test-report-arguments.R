# Arguments added in WJPr 1.2.0 to the existing chart functions

layer_geoms <- function(p) vapply(p$layers, function(l) class(l$geom)[1], character(1))

test_that("wjp_bars draws side-by-side series with tracks and value columns", {
  d <- data.frame(
    cat    = rep(c("Consumer", "Housing"), 2),
    series = rep(c("Country", "EU Average"), each = 2),
    val    = c(40, 10, 21, 7)
  )
  d$lab <- paste0(d$val, "%")
  p <- wjp_bars(d, "val", "cat", labels = "lab", colors = "series",
                direction = "horizontal", position = "dodge", track = TRUE,
                value_position = "column",
                value_colors = c(Country = "#575796", "EU Average" = "#7D7DA8"))
  b <- ggplot2::ggplot_build(p)
  cols <- b$data[[2]]
  # two bars per category at different positions
  expect_equal(length(unique(round(cols$x, 4))), 4)
  # the track spans 100% behind every bar
  expect_true(all(b$data[[1]]$ymax == 100))
  txt <- wjp_drawn(p)
  expect_setequal(txt$label[txt$source == "layer"], d$lab)
  expect_true("GeomLabel" %in% layer_geoms(p))
  expect_true(all(c("#575796", "#7D7DA8") %in% txt$colour[txt$source == "layer"]))
})

test_that("wjp_bars value positions, limits, reference lines and baseline", {
  d <- data.frame(cat = c("A", "B", "C"), val = c(20, 50, 80), ord = 1:3)
  d$lab <- paste0(d$val, "%")

  centered <- wjp_bars(d, "val", "cat", labels = "lab", value_position = "center", order = "ord")
  tx <- wjp_drawn(centered)
  expect_equal(sort(tx$y[tx$source == "layer"]), c(10, 25, 40))

  funnel <- wjp_bars(d, "val", "cat", labels = "lab", align = "center", direction = "horizontal")
  expect_true("GeomTile" %in% layer_geoms(funnel))
  tiles <- wjp_drawn(funnel, "marks")
  expect_equal(unique(round((tiles$ymin + tiles$ymax) / 2, 6)), 50)

  scaled <- wjp_bars(d, "val", "cat", limits = c(0, NA), ref_lines = 1.5, baseline = TRUE,
                     value_axis = FALSE, grid = FALSE, ylab = NULL)
  b <- ggplot2::ggplot_build(scaled)
  expect_equal(b$layout$panel_params[[1]]$y$limits, c(0, 80))
  expect_true(all(c("GeomVline", "GeomHline") %in% layer_geoms(scaled)))
  expect_s3_class(scaled$theme$axis.text.y, "element_blank")
  expect_null(scaled$labels$y)

  wrapped <- wjp_bars(data.frame(cat = "A very long category name", val = 10), "val", "cat",
                      label_wrap = 10)
  expect_match(wjp_drawn(wrapped)$label[1], "\n")

  expect_error(wjp_bars(d, "val", "cat", clip = "maybe"), "`clip`")
  expect_error(wjp_bars(d, "val", "cat", expand_discrete = -1), "`expand_discrete`")
  expect_error(wjp_bars(d, "val", "cat", label_align = "top"), "`label_align`")
})

test_that("wjp_bars with a layout has a fixed label column and panel", {
  d <- data.frame(cat = c("A", "B"), val = c(40, 60), lab = c("40%", "60%"), ord = 1:2)
  p <- wjp_bars(d, "val", "cat", labels = "lab", order = "ord", direction = "horizontal",
                value_position = "outside", label_align = "right",
                layout = wjp_layout(label_width = 80, label_gap = 6, track_width = 200,
                                    value_gap = 5, value_width = 30, row_height = 20,
                                    bar_height = 14))
  expect_equal(as.numeric(p$theme$panel.widths), 235)
  expect_equal(as.numeric(p$theme$panel.heights), 40)
  txt <- wjp_drawn(p)
  labels <- txt[txt$source == "layer" & txt$label %in% c("A", "B"), ]
  # labels end label_gap points before the bars (6 pt at 2 pt per percent)
  expect_equal(unique(labels$y), -3)
  values <- txt[txt$source == "layer" & txt$label %in% c("40%", "60%"), ]
  expect_equal(sort(values$y), c(42.5, 62.5))
})

test_that("wjp_dumbbells supports headers, single values and report styling", {
  d <- data.frame(
    category = rep(c("National Average", "Male", "Female", "18-24"), 2),
    group    = rep(c("", "Gender", "Gender", "Age Group"), 2),
    series   = rep(c("Perception", "Experience"), each = 4),
    value    = c(27, 29, 25, NA, 61, 60, 62, 68)
  )
  d$text <- ifelse(is.na(d$value), "", paste0(d$value, "%"))
  p <- wjp_dumbbells(
    d, "value", "category", colors = "series", cgroups = c("Perception", "Experience"),
    labels = "text", headers = "group", highlight_levels = "National Average",
    legend_labels = c("Perception of the public", "Experience of users"),
    strips = FALSE, grid = FALSE, value_position = "outside", breaks = seq(0, 100, 25),
    axis_line = TRUE
  )
  txt <- wjp_drawn(p)
  axis <- txt$label[txt$source == "axis-y"]
  expect_true(all(c("Gender", "Age Group", "Male", "18-24") %in% axis))
  # the single value of 18-24 keeps its label
  expect_true("68%" %in% txt$label)
  expect_false("GeomRibbon" %in% layer_geoms(p))
  expect_s3_class(p$theme$panel.grid.major, "element_blank")
  expect_equal(p$scales$get_scales("colour")$labels,
               c("Perception of the public", "Experience of users"))
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$layout$panel_params[[1]]$x$breaks, seq(0, 100, 25))

  lay <- wjp_dumbbells(
    d, "value", "category", colors = "series", cgroups = c("Perception", "Experience"),
    labels = "text", headers = "group", value_position = "outside",
    layout = wjp_layout(label_width = 80, track_width = 300, row_height = 18,
                        header_height = 22, header_baseline = 17, inset = c(3, 0))
  )
  expect_equal(as.numeric(lay$theme$panel.heights), 3 + 4 * 18 + 2 * 22)
  expect_error(wjp_dumbbells(d, "value", "category", colors = "series",
                             cgroups = c("Perception", "Experience"),
                             legend_labels = "only one"), "`legend_labels`")
})

test_that("wjp_groupbars draws report rows: averages, headers, N/A and columns", {
  d <- data.frame(
    group    = c("Gender", "Gender", "Age", "Age"),
    category = c("Male", "Female", "Young", "Old"),
    value    = c(65, NA, 61, 72)
  )
  p <- wjp_groupbars(
    d, "value", "group", "category",
    group_order = c("Gender", "Age"),
    level_order = list(Gender = c("Male", "Female"), Age = c("Young", "Old")),
    show_national = TRUE, national_style = "bar",
    national_value = c("National Average" = 68, "EU Average" = 49),
    national_value_label = c("68%", "49%"),
    na_label = "N/A", label_position = "column", group_header = "row"
  )
  txt <- wjp_drawn(p)
  lab <- txt[txt$source == "layer", ]
  is_label <- lab$x <= 0
  top_down <- lab$label[is_label][order(-lab$y[is_label])]
  expect_equal(top_down, c("National Average", "EU Average", "Gender", "Male", "Female",
                           "Age", "Young", "Old"))
  expect_true(all(c("68%", "49%", "N/A", "65%") %in% lab$label))
  # values in a column after the 100% track
  expect_equal(unique(lab$x[lab$label %in% c("68%", "65%", "N/A")]), 101)
})

test_that("wjp_groupbars handles 0-10 means, no complement, and a layout", {
  d <- data.frame(group = c("G", "G"), category = c("A", "B"), value = c(4.9, 6.4),
                  text = c("4.9", "6.4"))
  p <- wjp_groupbars(
    d, "value", "group", "category", labels = "text", scale_max = 10,
    show_complement = FALSE, label_position = "end",
    layout = wjp_layout(label_width = 100, track_width = 250, row_height = 15.5,
                        bar_height = 13.5, header_height = 22, header_baseline = 17)
  )
  marks <- wjp_drawn(p, "marks")
  expect_equal(sort(marks$xmax), c(49, 64))
  expect_equal(nrow(marks), 2)
  expect_true(all(c("4.9", "6.4") %in% wjp_drawn(p)$label))
  expect_equal(as.numeric(p$theme$panel.heights), 22 + 2 * 15.5)
  expect_error(
    wjp_groupbars(d, "value", "group", "category", scale_max = 5),
    "`scale_max`"
  )
  expect_error(
    wjp_groupbars(d, "value", "group", "category", show_national = TRUE,
                  national_style = "line", national_value = c(a = 5, b = 6), scale_max = 10),
    "national_style"
  )
})

test_that("wjp_groupbars keeps facets and gains report options in strip mode", {
  d <- data.frame(group = c("Gender", "Gender"), category = c("Male", "Female"),
                  value = c(0.45, NA))
  p <- wjp_groupbars(d, "value", "group", "category", na_label = "N/A",
                     label_position = "column", value_size = 9, label_size = 10,
                     show_complement = FALSE, xlim = c(0, 120))
  txt <- wjp_drawn(p)
  expect_true(all(c("45%", "N/A") %in% txt$label))
  expect_true(any(txt$source == "strip"))
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$layout$panel_params[[1]]$x$limits, c(0, 120))
  expect_equal(unique(txt$size[txt$label %in% c("45%", "N/A")]), 9, tolerance = 1e-6)
})

test_that("wjp_lollipops can hide points and anchor labels", {
  d <- data.frame(cat = c("A", "B"), val = c(30, 70))
  p <- wjp_lollipops(d, "val", "cat", points = FALSE, label_gap = 4)
  expect_false("GeomPoint" %in% layer_geoms(p))
  expect_true("GeomLabel" %in% layer_geoms(p))
  expect_setequal(wjp_drawn(p)$label[wjp_drawn(p)$source == "layer"], c("30%", "70%"))
  expect_error(wjp_lollipops(d, "val", "cat", points = "no"), "`points`")
})

test_that("wjp_edgebars places labels left, prints given values, and shows an axis", {
  d <- data.frame(cat = c("Police", "Courts"), val = c(72.4, 64.8), txt = c("72", "65"))
  p <- wjp_edgebars(d, "val", "cat", label_position = "left", value_labels = "txt",
                    axis = TRUE, grid = TRUE, margins = c(5, 5, 5, 80))
  txt <- wjp_drawn(p)
  expect_true(all(c("72", "65") %in% txt$label))
  expect_false(any(c("72%", "65%") %in% txt$label))
  expect_true(any(txt$source == "axis-x" & txt$label == "100%"))
  expect_equal(as.numeric(p$theme$plot.margin), c(5, 5, 5, 80))
  expect_s3_class(p$theme$panel.grid.major.x, "element_line")
})
