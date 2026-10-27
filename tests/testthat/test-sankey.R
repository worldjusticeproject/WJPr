sankey_data <- function() {
  data.frame(
    column  = c(1, 1, 2, 2, 2, 3, 3, 3),
    node    = c("yes", "no", "good", "need", "none", "access", "no_access", "excluded"),
    value   = c(30, 70, 22, 40, 30, 35, 65, 30),
    parent  = c(NA, NA, "yes", "no", "no", NA, NA, NA),
    outcome = c(NA, NA, "access", "no_access", "excluded", NA, NA, NA),
    label   = c("Contacted:", "Did not contact:", "Appropriate:", "Needed but\nno access:",
                "No need:", "Had access:", "No access:", "Excluded:"),
    text    = paste0(c(30, 70, 22, 40, 30, 35, 65, 30), "%"),
    note    = c(rep(NA, 7), "of all respondents"),
    stringsAsFactors = FALSE
  )
}

sankey_plot <- function(d = sankey_data(), ...) {
  wjp_sankey(d, column = "column", node = "node", target = "value",
             value_labels = "text", parent = "parent", outcome = "outcome",
             labels = "label", notes = "note", ...)
}

test_that("wjp_sankey returns a buildable ggplot with a definite size", {
  p <- sankey_plot(headers = c("First", "Second\ncolumn", "Third"), width = 500,
                   flow_height = 250, flow_top = 50, flow_bottom = 10)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_equal(unname(wjp_plot_size(p)), c(500, 310) / 72, tolerance = 1e-6)

  drawn <- wjp_drawn(p)$label
  expect_true(all(sankey_data()$text %in% drawn))
  expect_true(all(c("Needed but", "no access:", "of all respondents", "Second", "column") %in% drawn))
})

test_that("wjp_sankey flows follow parents and outcomes", {
  d <- sankey_data()
  cols <- c(access = "#111111", no_access = "#222222", excluded = "#333333")
  p <- sankey_plot(d, colors = cols, alpha = c(0.2, 0.6))
  marks <- wjp_drawn(p, what = "marks")
  bands <- marks[marks$geom == "GeomPolygon" & marks$fill %in% cols, ]
  # one band per second-column node into the second and into the third column
  expect_equal(length(unique(bands$group)), 2 * sum(d$column == 2))
  expect_setequal(unique(bands$alpha), c(0.2, 0.6))
  rects <- marks[marks$geom == "GeomRect", ]
  expect_equal(nrow(rects), nrow(d))
  # third-column heights are the sums of the flows that reach them
  third <- rects[rects$xmin == max(rects$xmin), ]
  h <- abs(third$ymax - third$ymin)
  expect_equal(h / sum(h), c(22, 40, 30) / 92, tolerance = 1e-8)

  d_over <- d
  d_over$value[d_over$node == "none"] <- 45
  expect_warning(sankey_plot(d_over), "more than their parent")
})

test_that("wjp_sankey validates its inputs", {
  d <- sankey_data()
  expect_error(sankey_plot(d[d$column != 3, ]), "Every column")
  d2 <- d
  d2$parent[3] <- "unknown"
  expect_error(sankey_plot(d2), "`parent`")
  d3 <- d
  d3$outcome[4] <- NA
  expect_error(sankey_plot(d3), "`outcome`")
  d4 <- d
  d4$column[1] <- 4
  expect_error(sankey_plot(d4), "`column`")
  expect_error(sankey_plot(headers = c("a", "b")), "`headers`")
  expect_error(sankey_plot(colors = c(access = "red")), "`colors`")
  expect_error(sankey_plot(alpha = 2), "`alpha`")
})

test_that("wjp_sankey can be saved as an outlined SVG", {
  skip_if_not_installed("svglite")
  skip_if_not_installed("xml2")
  skip_if_not_installed("textshaping")
  f <- tempfile(fileext = ".svg")
  out <- withr::with_options(list(wjpr.family = "sans"), wjp_save(sankey_plot(), f))
  expect_true(file.exists(f))
  expect_equal(out$height, (62 + 300 + 10) / 72, tolerance = 1e-6)
})
