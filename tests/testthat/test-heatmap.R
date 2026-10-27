heatmap_data <- function() {
  problems <- c("Consumer", "Housing", "Employment")
  d <- expand.grid(column = problems, row = problems, stringsAsFactors = FALSE)
  d$value <- c(NA, 45, 62, 30, NA, 55, 18, 27, NA)
  d$band <- cut(d$value, c(-Inf, 25, 50, Inf), right = FALSE,
                labels = c("Less than 25%", "25% to 50%", "50% or more"))
  d$text <- ifelse(is.na(d$value), "–", paste0(d$value, "%"))
  d
}

test_that("wjp_heatmap returns a buildable ggplot with one tile per cell", {
  p <- wjp_heatmap(heatmap_data(), "column", "row", "band", labels = "text")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  marks <- wjp_drawn(p, "marks")
  expect_equal(sum(marks$geom == "GeomTile"), 9)
})

test_that("wjp_heatmap prints labels as given and contrasts them with the fill", {
  p <- wjp_heatmap(heatmap_data(), "column", "row", "band", labels = "text")
  txt <- wjp_drawn(p)
  layer <- txt[txt$source == "layer", ]
  expect_setequal(layer$label, heatmap_data()$text)
  expect_equal(unique(layer$colour[layer$label == "62%"]), "#FFFFFF")
  expect_equal(unique(layer$colour[layer$label == "18%"]), "#1A1A1A")
  expect_equal(unique(layer$colour[layer$label == "–"]), "#1A1A1A")
})

test_that("wjp_heatmap orders rows top to bottom and columns left to right", {
  p <- wjp_heatmap(heatmap_data(), "column", "row", "band",
                   x_order = c("Employment", "Housing", "Consumer"),
                   y_order = c("Housing", "Consumer", "Employment"))
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$layout$panel_params[[1]]$x$get_labels(), c("Employment", "Housing", "Consumer"))
  # discrete y levels are stored bottom to top
  expect_equal(rev(b$layout$panel_params[[1]]$y$get_labels()), c("Housing", "Consumer", "Employment"))
})

test_that("wjp_heatmap supports named colors, numeric fills, titles, and fixed cells", {
  cols <- c("Less than 25%" = "#E5E8E8", "25% to 50%" = "#A8A8C8", "50% or more" = "#575796")
  p <- wjp_heatmap(heatmap_data(), "column", "row", "band", cvec = cols,
                   x_title = "Among people with:", y_title = "Also had:", cell_size = 40)
  marks <- wjp_drawn(p, "marks")
  expect_true(all(toupper(cols) %in% toupper(marks$fill)))
  expect_equal(p$labels$x, "Among people with:")
  expect_equal(p$theme$panel.widths, wjp_bp(120))

  num <- wjp_heatmap(heatmap_data(), "column", "row", "value", labels = "text",
                     cvec = c("#FFFFFF", "#000000"))
  expect_no_error(ggplot2::ggplot_build(num))
  marks <- wjp_drawn(num, "marks")
  expect_true("#FFFFFF" %in% toupper(marks$fill))
})

test_that("wjp_heatmap validates its inputs", {
  d <- heatmap_data()
  expect_error(wjp_heatmap(d, "missing", "row", "band"), "existing column")
  expect_error(wjp_heatmap(rbind(d, d[1, ]), "column", "row", "band"), "one row")
  expect_error(wjp_heatmap(d, "column", "row", "band", cvec = c(a = "#000000")), "every fill value")
  expect_error(wjp_heatmap(d, "column", "row", "value", cvec = "#000000"), "two colors")
  expect_error(wjp_heatmap(d, "column", "row", "band", x_order = "Housing"), "x_order")
})

test_that("wjp_heatmap saves to SVG", {
  skip_if_not_installed("svglite")
  p <- wjp_heatmap(heatmap_data(), "column", "row", "band", labels = "text", cell_size = 40)
  f <- tempfile(fileext = ".svg")
  on.exit(unlink(f))
  expect_no_error(wjp_save(p, f, outline_text = FALSE))
  expect_true(file.exists(f))
})
