funnel_data <- function() {
  data.frame(
    stage = c("Had access to information and advice",
              "Obtained appropriate assistance\nwhen they needed it",
              "Turned to a dispute resolution mechanism"),
    value = c(61.4, 31.9, 28.5),
    text  = c("61%", "32%", "28%"),
    rank  = c(1, 2, 3),
    stringsAsFactors = FALSE
  )
}

test_that("wjp_funnel returns a buildable ggplot with centered bars and connectors", {
  p <- wjp_funnel(funnel_data(), "value", "stage", labels = "text")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))

  marks <- wjp_drawn(p, "marks")
  bars <- marks[marks$geom == "GeomRect", ]
  expect_equal(nrow(bars), 3)
  # the widest bar spans the bar area and every bar is centered on 50
  expect_equal(bars$xmin[1], 0)
  expect_equal(bars$xmax[1], 100)
  expect_equal((bars$xmin + bars$xmax) / 2, rep(50, 3))
  expect_equal(bars$xmax[2] - bars$xmin[2], 100 * 31.9 / 61.4)
  # two connectors (four vertices each)
  conn <- marks[marks$geom == "GeomPolygon", ]
  expect_equal(length(unique(conn$group)), 2)
})

test_that("wjp_funnel prints values as given and keeps label line breaks", {
  p <- wjp_funnel(funnel_data(), "value", "stage", labels = "text")
  txt <- wjp_drawn(p)
  expect_true(all(c("61%", "32%", "28%") %in% txt$label))
  expect_true(all(c("Obtained appropriate assistance", "when they needed it") %in% txt$label))

  # default labels are rounded percentages; connectors can be removed
  p2 <- wjp_funnel(funnel_data(), "value", "stage", connectors = FALSE)
  expect_true(all(c("61%", "32%", "28%") %in% wjp_drawn(p2)$label))
  expect_false("GeomPolygon" %in% wjp_drawn(p2, "marks")$geom)
})

test_that("wjp_funnel honors the order column and wraps labels to label_width", {
  d <- funnel_data()
  d$rank <- c(3, 1, 2)
  p <- wjp_funnel(d, "value", "stage", labels = "text", order = "rank")
  vals <- wjp_drawn(p)
  vals <- vals[vals$label %in% c("61%", "32%", "28%"), ]
  # the y scale is reversed (points from the top): built y values are negated,
  # so the first stage has the largest built y
  vals <- vals[order(vals$y, decreasing = TRUE), ]
  expect_equal(vals$label, c("32%", "28%", "61%"))

  wrapped <- wjp_funnel(d, "value", "stage", label_width = 80)
  lines <- wjp_drawn(wrapped)$label
  expect_false("Turned to a dispute resolution mechanism" %in% lines)
})

test_that("wjp_funnel has a definite size with width or panel_width", {
  p <- wjp_funnel(funnel_data(), "value", "stage", panel_width = 300)
  expect_equal(p$theme$panel.heights, wjp_bp(3 * 40 + 2 * 18))
  expect_equal(p$theme$panel.widths, wjp_bp(300))
  p2 <- wjp_funnel(funnel_data(), "value", "stage", width = 468)
  expect_false(is.null(p2$theme$panel.widths))
  expect_error(wjp_funnel(funnel_data(), "value", "stage", width = 468, panel_width = 300),
               "only one")
})

test_that("wjp_funnel validates its inputs", {
  d <- funnel_data()
  expect_error(wjp_funnel(d, "missing", "stage"), "existing column")
  d$value <- c(-1, 2, 3)
  expect_error(wjp_funnel(d, "value", "stage"), "non-negative")
  d$value <- c(0, 0, 0)
  expect_error(wjp_funnel(d, "value", "stage"), "positive value")
  expect_error(wjp_funnel(funnel_data(), "value", "stage", connectors = NA), "TRUE or FALSE")
  expect_error(wjp_funnel(funnel_data(), "value", "stage", bar_height = 0), "bar_height")
  expect_error(wjp_funnel(funnel_data(), "value", "stage", width = 20), "no room")
})

test_that("wjp_funnel saves to SVG", {
  skip_if_not_installed("svglite")
  p <- wjp_funnel(funnel_data(), "value", "stage", labels = "text", width = 468)
  f <- tempfile(fileext = ".svg")
  on.exit(unlink(f))
  expect_no_error(wjp_save(p, f, width = 6.5, height = 2.3, outline_text = FALSE))
  expect_true(file.exists(f))
})
