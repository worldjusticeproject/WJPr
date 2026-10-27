network_data <- function() {
  nodes <- data.frame(
    id   = c("A", "B", "C", "Money & Debt"),
    name = c("A", "B", "C", "Money &\nDebt"),
    pct  = c("(40%)", "(10%)", "(18%)", "(22%)"),
    x    = c(0, 1, 0.5, 0.2),
    y    = c(0, 0, 1, 0.6),
    stringsAsFactors = FALSE
  )
  edges <- data.frame(
    from = c("A", "A", "B", "C"),
    to   = c("B", "C", "C", "Money & Debt"),
    lift = c(1.5, 2.0, 3.0, 2.5),
    stringsAsFactors = FALSE
  )
  list(nodes = nodes, edges = edges)
}

test_that("wjp_network returns a buildable ggplot with nodes, edges and text", {
  nd <- network_data()
  p <- wjp_network(nd$nodes, nd$edges, labels = "name", ids = "id",
                   value_labels = "pct", weight = "lift")
  expect_s3_class(p, "ggplot")
  b <- expect_no_error(ggplot2::ggplot_build(p))

  # edges drawn from the thinnest to the thickest
  seg <- b$data[[1]]
  expect_equal(nrow(seg), 4)
  expect_true(all(diff(seg$linewidth) >= 0))
  expect_equal(range(seg$linewidth), wjp_pt_line(c(0.6, 3.2)))

  # one polygon per node, the most central darkest
  poly <- b$data[[2]]
  expect_equal(length(unique(poly$group)), 4)

  drawn <- wjp_drawn(p)
  txt <- drawn$label[drawn$source == "layer"]
  expect_true("Money &\nDebt\n(22%)" %in% txt)
  expect_true("A\n(40%)" %in% txt)
  expect_equal(sum(drawn$source == "axis-x"), 0)
})

test_that("wjp_network fills by centrality or by value and picks contrasting text", {
  nd <- network_data()
  p <- wjp_network(nd$nodes, nd$edges, ids = "id", labels = "name", weight = "lift",
                   colors = c("#FFFFFF", "#000000"))
  b <- ggplot2::ggplot_build(p)
  poly <- b$data[[2]]
  fills <- tapply(poly$fill, poly$group, unique)
  # node C has the largest strength (2 + 3 + 2.5)
  strength <- c(A = 3.5, B = 4.5, C = 7.5, `Money & Debt` = 2.5)
  expect_equal(unname(fills[which.max(strength)]), "#000000")
  expect_equal(unname(fills[which.min(strength)]), "#FFFFFF")
  txt <- b$data[[3]]
  expect_equal(as.character(txt$colour[3]), "#FFFFFF")
  expect_equal(as.character(txt$colour[4]), "#1A1A1A")

  nd$nodes$v <- c(1, 2, 3, 4)
  p2 <- wjp_network(nd$nodes, nd$edges, ids = "id", labels = "name", weight = "lift",
                    fill = "value", node_value = "v", colors = c("#FFFFFF", "#000000"))
  poly2 <- ggplot2::ggplot_build(p2)$data[[2]]
  expect_equal(unique(poly2$fill[poly2$group == 4]), "#000000")
})

test_that("wjp_network accepts functions and constants for edge styles", {
  nd <- network_data()
  p <- wjp_network(nd$nodes, nd$edges, ids = "id", labels = "name", weight = "lift",
                   edge_width = 1, edge_alpha = function(w) pmin(0.85, (w - 1) * 0.35 + 0.2))
  seg <- ggplot2::ggplot_build(p)$data[[1]]
  expect_true(all(seg$linewidth == wjp_pt_line(1)))
  expect_equal(sort(seg$alpha), sort(pmin(0.85, (nd$edges$lift - 1) * 0.35 + 0.2)))
})

test_that("wjp_network validates its inputs", {
  nd <- network_data()
  expect_error(wjp_network(nd$nodes[0, ], nd$edges), "non-empty")
  expect_error(wjp_network(nd$nodes, nd$edges, ids = "id", labels = "name"), "`weight`")
  bad <- nd$edges
  bad$from[1] <- "Z"
  expect_error(wjp_network(nd$nodes, bad, ids = "id", labels = "name", weight = "lift"),
               "not in `nodes`")
  expect_error(wjp_network(nd$nodes, nd$edges, ids = "id", labels = "name", weight = "lift",
                           fill = "value"), "node_value")
  expect_error(wjp_network(nd$nodes, nd$edges, ids = "id", labels = "name", weight = "lift",
                           edge_width = c(1, 2, 3)), "edge_width")
  dup <- nd$nodes
  dup$id[2] <- "A"
  expect_error(wjp_network(dup, nd$edges, ids = "id", labels = "name", weight = "lift"),
               "unique")
})

test_that("wjp_network saves to SVG", {
  skip_if_not_installed("svglite")
  nd <- network_data()
  p <- wjp_network(nd$nodes, nd$edges, ids = "id", labels = "name", weight = "lift")
  f <- tempfile(fileext = ".svg")
  res <- withr::with_options(list(wjpr.family = "sans"),
                             wjp_save(p, f, width = 5, height = 5, outline_text = FALSE))
  expect_true(file.exists(f))
  expect_equal(res$height, 5)
})
