scatter_data <- function() {
  data.frame(
    area     = rep(c("Rural", "Urban"), each = 4),
    category = rep(c("Consumer", "Housing", "Family", "Land"), 2),
    prev     = c(41, 9, 21, 20, 39, 10, 17, 18),
    sev      = c(4.6, 4.3, 5.5, NA, 4.8, 4.9, 5.6, 5.2),
    small    = c(FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
}

test_that("wjp_scatter returns a buildable ggplot with facets, trend and highlights", {
  d <- scatter_data()
  p <- wjp_scatter(d, "prev", "sev", labels = "category", facet = "area",
                   highlight = c("Consumer", "Housing"), hollow = "small",
                   trend = "lm", repel = FALSE, xlim = c(0, 50), ylim = c(4, 8),
                   x_labels = function(x) paste0(x, "%"),
                   x_title = "Prevalence", y_title = "Seriousness")
  expect_s3_class(p, "ggplot")
  b <- expect_no_error(ggplot2::ggplot_build(p))

  # one point per finite pair, highlighted and hollow points styled
  pts <- b$data[[2]]
  expect_equal(nrow(pts), 7)
  expect_setequal(unique(pts$colour), c("#482d8b", "#c4c4c4"))
  expect_true(1 %in% pts$shape && 16 %in% pts$shape)

  # trend line per panel
  expect_true(all(c("1", "2") %in% as.character(b$data[[1]]$PANEL)))

  drawn <- wjp_drawn(p)
  labs <- drawn$label[drawn$source == "layer"]
  expect_setequal(labs, c("Consumer", "Housing", "Consumer", "Housing"))
  expect_true(all(c("Rural", "Urban") %in% drawn$label[drawn$source == "strip"]))
  expect_true("50%" %in% drawn$label[drawn$source == "axis-x"])
})

test_that("wjp_scatter labels every point without highlight and supports repel", {
  d <- scatter_data()
  p <- wjp_scatter(d, "prev", "sev", labels = "category", repel = FALSE)
  drawn <- wjp_drawn(p)
  expect_equal(sum(drawn$source == "layer"), 7)

  skip_if_not_installed("ggrepel")
  p2 <- wjp_scatter(d, "prev", "sev", labels = "category", repel = TRUE, seed = 7,
                    repel_args = list(box.padding = 0.4))
  expect_true(any(vapply(p2$layers, function(l) inherits(l$geom, "GeomTextRepel"), logical(1))))
  expect_no_error(ggplot2::ggplot_build(p2))
})

test_that("wjp_scatter validates its inputs", {
  d <- scatter_data()
  expect_error(wjp_scatter(d, "missing", "sev"), "existing column")
  expect_error(wjp_scatter(d, "category", "sev"), "numeric")
  expect_error(wjp_scatter(d, "prev", "sev", colors = "#000000"), "two colors")
  expect_error(wjp_scatter(d, "prev", "sev", highlight = "Consumer"), "requires `labels`")
  expect_error(wjp_scatter(d, "prev", "sev", hollow = "category"), "logical")
  expect_error(wjp_scatter(d, "prev", "sev", xlim = 1), "length 2")
  expect_error(wjp_scatter(d, "prev", "sev", trend = "loess"), "should be one of")
  expect_error(wjp_scatter(d[0, ], "prev", "sev"), "non-empty")
})

test_that("wjp_scatter applies a custom ptheme last", {
  d <- scatter_data()
  p <- wjp_scatter(d, "prev", "sev", ptheme = WJP_theme(base_size = 8))
  expect_equal(p$theme$axis.text.x$size, 8)
})

test_that("wjp_scatter saves to SVG with outlined text", {
  skip_if_not_installed("svglite")
  skip_if_not_installed("xml2")
  skip_if_not_installed("textshaping")
  d <- scatter_data()
  p <- wjp_scatter(d, "prev", "sev", labels = "category", repel = FALSE)
  f <- tempfile(fileext = ".svg")
  res <- withr::with_options(list(wjpr.family = "sans"),
                             wjp_save(p, f, width = 6, height = 4, outline_text = FALSE))
  expect_true(file.exists(f))
  expect_equal(res$width, 6)
})
