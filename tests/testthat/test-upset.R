upset_data <- function() {
  data.frame(
    combination = c("A + B", "A", "B + C", "C"),
    value       = c(20, 15, 8, 3),
    text        = c("20.0%", "15.0%", "8.0%", "3.0%"),
    stringsAsFactors = FALSE
  )
}

test_that("wjp_upset returns a single buildable ggplot with a definite size", {
  d <- upset_data()
  sets <- data.frame(set = c("C", "B", "A"), size = c(11, 28, 35), text = c("11%", "28%", "35%"))
  p <- wjp_upset(d, intersections = "combination", sets = sets, target = "value",
                 labels = "text", set_target = "size", set_labels = "text",
                 y_title = "% of people\nwithin the gap", width = 400, height = 300)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  size <- wjp_plot_size(p)
  expect_equal(unname(size), c(400, 300) / 72, tolerance = 1e-6)

  drawn <- wjp_drawn(p)
  layer_text <- drawn$label[drawn$source == "layer"]
  expect_true(all(c("20.0%", "15.0%", "8.0%", "3.0%") %in% layer_text))
  expect_true(all(c("11%", "28%", "35%") %in% layer_text))
  expect_true(all(c("A", "B", "C") %in% layer_text))
  expect_true(any(grepl("within the gap", layer_text, fixed = TRUE)))
})

test_that("wjp_upset draws one dot per intersection and set, active ones colored", {
  d <- upset_data()
  p <- wjp_upset(d, "combination", target = "value", sets = c("A", "B", "C"),
                 dot_colors = c("#000000", "#DDDDDD"))
  marks <- wjp_drawn(p, what = "marks")
  dots <- marks[marks$geom == "GeomPoint", ]
  expect_equal(nrow(dots), nrow(d) * 3)
  expect_equal(sum(dots$colour == "#000000"), sum(lengths(strsplit(d$combination, " + ", fixed = TRUE))))
  segs <- marks[marks$geom == "GeomSegment" & !is.na(marks$yend), ]
  expect_true(nrow(segs) >= 2)
})

test_that("wjp_upset computes set sizes and honors the order column", {
  d <- upset_data()
  d$ord <- c(4, 3, 2, 1)
  p <- wjp_upset(d, "combination", target = "value", labels = "text", order = "ord")
  drawn <- wjp_drawn(p)
  vals <- drawn[drawn$label %in% d$text, ]
  expect_equal(vals$label[order(vals$x)], rev(d$text))
  # list column of memberships
  d2 <- d
  d2$sets <- strsplit(d2$combination, " + ", fixed = TRUE)
  expect_no_error(ggplot2::ggplot_build(wjp_upset(d2, "sets", target = "value")))
})

test_that("wjp_upset validates its inputs", {
  d <- upset_data()
  expect_error(wjp_upset(d, "missing", target = "value"), "`intersections`")
  expect_error(wjp_upset(d, "combination", target = "text"), "`target`")
  expect_error(wjp_upset(d, "combination", target = "value", sets = c("A", "B")), "not listed")
  expect_error(wjp_upset(d, "combination", target = "value", set_target = "size"), "data frame")
  expect_error(wjp_upset(d, "combination", target = "value", dot_colors = "black"), "`dot_colors`")
  expect_error(wjp_upset(d, "combination", target = "value", width = 20), "too small")
})

test_that("wjp_upset can be saved as an outlined SVG", {
  skip_if_not_installed("svglite")
  skip_if_not_installed("xml2")
  skip_if_not_installed("textshaping")
  p <- wjp_upset(upset_data(), "combination", target = "value", labels = "text")
  f <- tempfile(fileext = ".svg")
  out <- withr::with_options(list(wjpr.family = "sans"), wjp_save(p, f))
  expect_true(file.exists(f))
  expect_equal(out$width, 468 / 72, tolerance = 1e-6)
})
