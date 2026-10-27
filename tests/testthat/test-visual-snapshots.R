# Visual regression tests: a snapshot of what every chart function draws.
#
# Each snapshot lists the texts a chart draws (wjp_drawn()) with their order
# along each axis, so changes such as a different row order, a missing label,
# or a label moved to another side fail before a release. Ranks, not raw
# coordinates, keep the snapshots independent of the fonts installed.
# Review changes with testthat::snapshot_review() and accept them only when
# they are intended.

drawn_signature <- function(p) {
  d <- wjp_drawn(p)
  key <- paste(d$source, d$layer, d$PANEL)
  rk <- function(v, desc = FALSE) {
    if (all(is.na(v))) return(rep(NA_integer_, length(v)))
    as.integer(rank(if (desc) -v else v, ties.method = "min", na.last = "keep"))
  }
  d$rank_x <- stats::ave(d$x, key, FUN = rk)
  d$rank_y <- stats::ave(d$y, key, FUN = function(v) rk(v, desc = TRUE))
  d$label <- gsub("\n", "\\\\n", d$label)
  d <- d[order(d$source, d$layer, d$PANEL, d$rank_y, d$rank_x, d$label),
         c("source", "layer", "PANEL", "label", "rank_x", "rank_y")]
  rownames(d) <- NULL
  d
}

expect_drawn_snapshot <- function(p) {
  testthat::local_reproducible_output(width = 120)
  expect_snapshot(print(drawn_signature(p), row.names = FALSE))
}

snapshot_data <- local({
  bars <- data.frame(cat = c("Courts", "Police", "Parliament"), val = c(64, 72, 39),
                     ord = c(2, 1, 3))
  bars$lab <- paste0(bars$val, "%")
  paired <- data.frame(cat = rep(c("Consumer", "Housing"), 2),
                       series = rep(c("Country", "EU Average"), each = 2),
                       val = c(40, 10, 21, 7))
  paired$lab <- paste0(paired$val, "%")
  list(bars = bars, paired = paired)
})

test_that("bar-like charts draw the same texts in the same order", {
  d <- snapshot_data
  expect_drawn_snapshot(wjp_bars(d$bars, "val", "cat", labels = "lab", order = "ord"))
  expect_drawn_snapshot(wjp_bars(d$paired, "val", "cat", labels = "lab", colors = "series",
                                 direction = "horizontal", position = "dodge",
                                 value_position = "column", track = TRUE))
  expect_drawn_snapshot(wjp_divbars(
    data.frame(cat = rep(c("A", "B"), each = 2), val = c(40, 60, 30, 70),
               side = rep(c("Yes", "No"), 2), lab = c("40%", "60%", "30%", "70%")),
    "val", "cat", "side", negative = "No", labels = "lab"
  ))
  expect_drawn_snapshot(wjp_edgebars(d$bars, "val", "cat", order = "ord"))
  expect_drawn_snapshot(wjp_lollipops(d$bars, "val", "cat", order = "ord"))
  expect_drawn_snapshot(wjp_funnel(
    data.frame(stage = c("Information", "Assistance", "Resolution"), value = c(61, 32, 28),
               text = c("61%", "32%", "28%")),
    target = "value", grouping = "stage", labels = "text"
  ))
})

test_that("grouped bars keep their row order in both header modes", {
  gb <- data.frame(group = c("Gender", "Gender", "Age", "Age", "Age"),
                   level = c("Male", "Female", "18-29", "30-49", "50+"),
                   value = c(45, 52, 38, NA, 55))
  expect_drawn_snapshot(wjp_groupbars(gb, "value", "group", "level"))
  expect_drawn_snapshot(wjp_groupbars(
    gb, "value", "group", "level", group_header = "row",
    group_order = c("Gender", "Age"), show_national = TRUE, national_style = "bar",
    national_value = c("National Average" = 50, "EU Average" = 42),
    na_label = "N/A", label_position = "column"
  ))
})

test_that("point and line charts draw the same texts in the same order", {
  dots <- data.frame(cat = rep(c("A", "B"), 2), group = rep(c("G1", "G2"), each = 2),
                     val = c(20, 40, 30, 50))
  expect_drawn_snapshot(wjp_dots(dots, "val", "cat", "group"))

  dumb <- data.frame(cat = rep(c("Courts", "Police"), each = 2),
                     yr = rep(c("2019", "2024"), 2), val = c(40, 45, 60, NA))
  dumb$lab <- ifelse(is.na(dumb$val), "", paste0(dumb$val, "%"))
  expect_drawn_snapshot(wjp_dumbbells(dumb, "val", "cat", cgroups = c("2019", "2024"),
                                      colors = "yr", labels = "lab"))

  lines <- data.frame(year = rep(2019:2021, 2), group = rep(c("A", "B"), each = 3),
                      val = c(20, 25, 35, 50, 55, 60))
  lines$lab <- paste0(lines$val, "%")
  expect_drawn_snapshot(wjp_lines(lines, "val", "year", colors = "group", labels = "lab"))
  expect_drawn_snapshot(wjp_slope(lines[lines$year %in% c(2019, 2021), ], "val", "year",
                                  colors = "group", labels = "lab"))

  pts <- data.frame(area = rep(c("Urban", "Rural"), each = 3),
                    problem = rep(c("Housing", "Consumer", "Family"), 2),
                    prev = c(10, 40, 20, 12, 38, 22), sev = c(5, 6, 4.5, 5.5, 6.2, 4.8))
  expect_drawn_snapshot(wjp_scatter(pts, "prev", "sev", labels = "problem", facet = "area",
                                    highlight = "Consumer", repel = FALSE))
})

test_that("radial and special charts draw the same texts in the same order", {
  radar <- data.frame(axis = rep(LETTERS[1:5], 2), val = c(20, 40, 60, 80, 50, 30, 50, 70, 65, 45),
                      lab = rep(LETTERS[1:5], 2), group = rep(c("G1", "G2"), each = 5))
  expect_drawn_snapshot(wjp_radar(radar, "axis", "val", "lab", "group"))
  expect_drawn_snapshot(wjp_rose(radar[radar$group == "G1", ], "val", "axis", "lab"))
  expect_drawn_snapshot(wjp_gauge(data.frame(cat = c("A", "B", "C"), val = c(25, 35, 40),
                                             lab = c("25%", "35%", "40%")),
                                  "val", "cat", labels = "lab"))

  cards <- data.frame(row = rep(c("Health issues", "Economic issues"), each = 2),
                      col = rep(c("Resolved", "Not resolved"), 2), value = c(30, 40, 26, 36))
  cards$text <- paste0(cards$value, "%")
  expect_drawn_snapshot(wjp_cards(cards, rows = "row", cols = "col", target = "value",
                                  labels = "text", ref = "row"))

  cells <- expand.grid(x = c("A", "B"), y = c("A", "B"), stringsAsFactors = FALSE)
  cells$band <- c("Low", "High", "High", "Low")
  cells$text <- c("10%", "60%", "55%", "12%")
  expect_drawn_snapshot(wjp_heatmap(cells, x = "x", y = "y", fill = "band", labels = "text"))

  nodes <- data.frame(label = c("Consumer", "Housing", "Family"), x = c(0, 1, 0.5),
                      y = c(0, 0, 1), text = c("(40%)", "(10%)", "(18%)"))
  edges <- data.frame(from = c("Consumer", "Housing"), to = c("Family", "Family"),
                      weight = c(1.5, 2.5))
  expect_drawn_snapshot(wjp_network(nodes, edges, value_labels = "text"))

  ups <- data.frame(inter = c("Information + Assistance", "Information", "Assistance"),
                    value = c(17, 8, 12), text = c("17%", "8%", "12%"))
  expect_drawn_snapshot(wjp_upset(ups, intersections = "inter", target = "value", labels = "text"))

  flows <- data.frame(
    column = c(1, 1, 2, 2, 2, 3, 3, 3),
    node   = c("yes", "no", "good", "none", "skip", "access", "no_access", "excluded"),
    value  = c(30, 70, 30, 40, 30, 30, 40, 30),
    parent = c(NA, NA, "yes", "no", "no", NA, NA, NA),
    outcome = c(NA, NA, "access", "no_access", "excluded", NA, NA, NA)
  )
  flows$text <- paste0(flows$value, "%")
  expect_drawn_snapshot(wjp_sankey(flows, column = "column", node = "node", target = "value",
                                   value_labels = "text", parent = "parent",
                                   outcome = "outcome"))
})
