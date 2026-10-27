cards_data <- function() {
  data.frame(
    hardship = rep(c("At least one hardship", "Health issues", "Alcohol or drug problems"), each = 2),
    outcome  = rep(c("Fully resolved", "Not resolved"), 3),
    value    = c(45.67, 61.79, 29.82, 40.18, 1.92, 5.90),
    stringsAsFactors = FALSE
  )
}

test_that("wjp_cards returns a buildable ggplot with one card per cell", {
  p <- wjp_cards(cards_data(), "hardship", "outcome", "value", ref = "col")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  marks <- wjp_drawn(p, "marks")
  expect_equal(length(unique(marks$group[marks$geom == "GeomPolygon"])), 6)
})

test_that("wjp_cards computes differences against the reference cards", {
  p <- wjp_cards(cards_data(), "hardship", "outcome", "value", ref = "col")
  txt <- wjp_drawn(p)$label
  expect_true(all(c("46%", "62%", "30%", "40%", "2%", "6%") %in% txt))
  expect_true(all(c("+16 points", "+10 points", "+4 points") %in% txt))
  expect_true(all(c("Fully resolved", "Not resolved") %in% txt))
  expect_true("At least one hardship" %in% txt)

  # first row as reference: differences against the first row of each column
  d <- cards_data()
  p_row <- wjp_cards(d, "hardship", "outcome", "value", ref = "row")
  txt_row <- wjp_drawn(p_row)$label
  expect_true("−16 points" %in% txt_row)
  expect_true("−44 points" %in% txt_row)

  # no references: values only
  p_none <- wjp_cards(d, "hardship", "outcome", "value", ref = "none")
  expect_false(any(grepl("points", wjp_drawn(p_none)$label)))
})

test_that("wjp_cards prints labels and deltas as given", {
  d <- cards_data()
  d$text <- c("A", "B", "C", "D", "E", "F")
  d$delta <- c("", "up", "", "same", "", "down")
  p <- wjp_cards(d, "hardship", "outcome", "value", labels = "text", deltas = "delta", ref = "col")
  txt <- wjp_drawn(p)$label
  expect_true(all(c("A", "B", "C", "D", "E", "F", "up", "same", "down") %in% txt))
})

test_that("wjp_cards colors cards on the sequential scale and contrasts texts", {
  p <- wjp_cards(cards_data(), "hardship", "outcome", "value", ref = "col", limits = c(2, 62))
  marks <- wjp_drawn(p, "marks")
  fills <- unique(marks$fill[marks$geom == "GeomPolygon"])
  expect_true(toupper(wjp_mix_rgb("#ECECF4", "#575796", 0.12 + 0.88 * (61.79 - 2) / 60)) %in% toupper(fills))
  txt <- wjp_drawn(p)
  expect_equal(unique(txt$colour[txt$label == "62%"]), "#FFFFFF")
  expect_equal(unique(txt$colour[txt$label == "2%"]), "#1A1A1A")
})

test_that("wjp_cards has a definite size from width or card_width", {
  p <- wjp_cards(cards_data(), "hardship", "outcome", "value", ref = "col", width = 468)
  cw <- (468 - 170 - 12 - 6) / 2
  expect_equal(p$theme$panel.widths, wjp_bp(2 * cw + 6))
  expect_equal(p$theme$panel.heights, wjp_bp(3 * 48 + 2 * 6))
  p2 <- wjp_cards(cards_data(), "hardship", "outcome", "value", card_width = 100)
  expect_equal(p2$theme$panel.widths, wjp_bp(206))
})

test_that("wjp_cards validates its inputs", {
  d <- cards_data()
  expect_error(wjp_cards(d, "missing", "outcome", "value"), "existing column")
  expect_error(wjp_cards(rbind(d, d[1, ]), "hardship", "outcome", "value"), "one row")
  expect_error(wjp_cards(d, "hardship", "outcome", "value", colors = "#000000"), "two colors")
  expect_error(wjp_cards(d, "hardship", "outcome", "value", ref = "diagonal"), "should be one of")
  expect_error(wjp_cards(d, "hardship", "outcome", "value", width = 100), "no room")
  expect_error(wjp_cards(d, "hardship", "outcome", "value", width = 468, card_width = 100), "only one")
})

test_that("wjp_cards saves to SVG", {
  skip_if_not_installed("svglite")
  p <- wjp_cards(cards_data(), "hardship", "outcome", "value", ref = "col", width = 468)
  f <- tempfile(fileext = ".svg")
  on.exit(unlink(f))
  expect_no_error(wjp_save(p, f, outline_text = FALSE))
  expect_true(file.exists(f))
})
