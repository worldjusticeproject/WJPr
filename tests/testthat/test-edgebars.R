edge_data <- function() data.frame(category = c("A", "B", "C"), value = c(0, 45.25, 100))
edge_build <- function(...) ggplot2::ggplot_build(wjp_edgebars(...))

test_that("edgebars isolate source columns and allow shared plotting roles", {
  d <- edge_data()
  d$color <- d$value
  d$y_value <- 99
  d$x_var <- "unused"
  p <- wjp_edgebars(d, "color", "category", labels = "category", order = "color")
  expect_equal(p$data$value, d$value)
  expect_equal(p$data$category, d$category)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_equal(d$y_value, rep(99, 3))
  expect_equal(wjp_edgebars(d, "value", "category", x_lab_pos = "value")$data$y, p$data$y)
})

test_that("edgebars reject malformed values and duplicate categories", {
  d <- edge_data()
  expect_error(wjp_edgebars(d, "missing", "category"), "existing column")
  expect_error(wjp_edgebars(d[FALSE, ], "value", "category"), "non-empty")
  for (bad in list(c(-1, 50, 100), c(0, 50, 101), c(0, Inf, 100))) {
    d$value <- bad
    expect_error(wjp_edgebars(d, "value", "category"), "finite|between 0 and 100")
  }
  d$value <- c("0", "50", "100")
  expect_error(wjp_edgebars(d, "value", "category"), "numeric")
  d <- edge_data()
  expect_error(wjp_edgebars(rbind(d, d[1, ]), "value", "category"), "one row per category")
  d$category[1] <- " "
  expect_error(wjp_edgebars(d, "value", "category"), "must not be empty")
})

test_that("missing data policy preserves complete pairs", {
  d <- rbind(transform(edge_data(), series = "Before"), transform(edge_data(), series = "After"))
  d$value[2] <- NA_real_
  expect_error(wjp_edgebars(d, "value", "category", series = "series"), "Missing required")
  expect_warning(p <- wjp_edgebars(d, "value", "category", series = "series", na_action = "omit"), "Omitted 2")
  expect_setequal(p$data$category, c("A", "C"))
  expect_equal(nrow(p$data), 4)
  d$value[] <- NA_real_
  expect_warning(expect_error(wjp_edgebars(d, "value", "category", na_action = "omit"),
                             "No complete categories"), "Omitted")
})

test_that("ordering and formatting are explicit and validated", {
  d <- edge_data()
  p <- wjp_edgebars(d, "value", "category", sort = "descending", accuracy = 0.1)
  expect_equal(p$data$category[order(-p$data$y)], c("C", "B", "A"))
  expect_equal(p$data$value_label, c("0.0%", "45.2%", "100.0%"))
  expect_error(wjp_edgebars(d, "value", "category", order = "value", sort = "descending"), "either")
  expect_error(wjp_edgebars(d, "value", "category", order = "value", x_lab_pos = "value"), "only one")
  expect_error(wjp_edgebars(d, "value", "category", label_start = 0, y_lab_pos = 0), "only one")
  p <- wjp_edgebars(d, "value", "category", label_format = function(x) paste0(x, " points"))
  expect_equal(p$data$value_label, c("0 points", "45.25 points", "100 points"))
  expect_error(wjp_edgebars(d, "value", "category", label_format = function(x) "one"), "one non-missing")
  expect_error(wjp_edgebars(d, "value", "category", bar_width = -1), "bar_width")
  expect_error(wjp_edgebars(d, "value", "category", show_values = NA), "TRUE or FALSE")
  expect_error(wjp_edgebars(d, "value", "category", label_wrap = 0), "positive integer")
})

test_that("fixed scales compare charts and tracks always cover 100 percent", {
  d <- edge_data()
  p <- edge_build(d, "value", "category")
  d$value <- c(5, 10, 20)
  q <- edge_build(d, "value", "category")
  expect_equal(p$layout$panel_params[[1]]$x.range, q$layout$panel_params[[1]]$x.range)
  auto <- edge_build(d, "value", "category", scale = "auto")
  expect_lt(max(auto$layout$panel_params[[1]]$x.range), max(q$layout$panel_params[[1]]$x.range))
  track <- edge_build(d, "value", "category", scale = "auto", background_track = TRUE)
  expect_equal(track$data[[1]]$xmin, rep(0, 3))
  expect_equal(track$data[[1]]$xmax, rep(100, 3))
})

test_that("paired bars have distinct positions, stable labels and valid series", {
  d <- rbind(transform(edge_data(), series = "Before"), transform(edge_data(), series = "After"))
  p <- wjp_edgebars(d, "value", "category", series = "series", highlight = "B",
                    value_position = "column", show_values = FALSE)
  expect_true(all(vapply(split(p$data$y, p$data$category), function(x) length(unique(x)) == 2, logical(1))))
  expect_equal(length(unique(p$data$fill[p$data$category == "B"])), 2)
  expect_equal(unique(p$data$fill[p$data$category == "A"]), "#b9b7bf")
  b <- ggplot2::ggplot_build(p)
  expect_setequal(as.character(b$data[[3]]$label), c("Before", "After"))
  expect_equal(nrow(b$data[[2]]), 3) # One heading per category.
  expect_error(wjp_edgebars(d[-1, ], "value", "category", series = "series"), "both series")
  expect_error(wjp_edgebars(rbind(d, d[1, ]), "value", "category", series = "series"), "duplicate pairs")
  expect_error(wjp_edgebars(d, "value", "category", series = "series", cvec = c(X = "red", Y = "blue")), "Names of")
  d$order <- seq_len(nrow(d))
  expect_error(wjp_edgebars(d, "value", "category", series = "series", order = "order"), "constant within")
})

test_that("confidence bounds are validated and labels clear their upper end", {
  d <- edge_data()
  d$lower <- c(0, 40, 95)
  d$upper <- c(5, 50, 100)
  p <- wjp_edgebars(d, "value", "category", ci_lower = "lower", ci_upper = "upper")
  expect_true(all(p$data$value_x > p$data$upper))
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$data[[2]]$x, d$lower)
  expect_equal(b$data[[2]]$xend, d$upper)
  expect_error(wjp_edgebars(d, "value", "category", ci_lower = "lower"), "both")
  d$lower[2] <- 46
  expect_error(wjp_edgebars(d, "value", "category", ci_lower = "lower", ci_upper = "upper"), "enclose")
})

test_that("plain and rich labels share positions and layout controls", {
  d <- edge_data()
  d$label <- c("A long category label with several words", "Second category", "Third category")
  p <- wjp_edgebars(d, "value", "category", labels = "label", label_wrap = 15)
  expect_match(p$layers[[2]]$data$label[1], "\n", fixed = TRUE)
  expect_s3_class(p$theme$axis.text.y, "element_blank")
  expect_s3_class(p$theme$panel.grid.major.x, "element_blank")
  expect_true(all(as.numeric(p$theme$plot.margin) >= 0))
  expect_gt(wjp_edgebars(d, "value", "category", nudge_lab = 5)$data$y[1] * -1,
            wjp_edgebars(d, "value", "category", nudge_lab = 1)$data$y[1] * -1)
  skip_if_not_installed("ggtext")
  plain <- wjp_edgebars(d, "value", "category", label_style = "plain")
  rich <- wjp_edgebars(d, "value", "category", label_style = "rich")
  expect_equal(plain$data$y, rich$data$y)
  expect_equal(plain$layers[[2]]$data$y, rich$layers[[2]]$data$y)
  expect_no_error(ggplot2::ggplot_build(rich))
})
