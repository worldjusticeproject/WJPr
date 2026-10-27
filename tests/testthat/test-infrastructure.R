test_that("WJP_theme exposes size, color, grid, and base theme", {
  th <- WJP_theme(base_size = 9, text_colour = "#1A1A1A", grid = "x")
  expect_equal(th$axis.text.x$size, 9)
  expect_equal(th$axis.text.y$colour, "#1A1A1A")
  expect_s3_class(th$panel.grid.major.y, "element_blank")
  expect_equal(th$text$family, wjp_font_family())

  none <- WJP_theme(grid = "none")
  expect_s3_class(none$panel.grid.major, "element_blank")
  expect_equal(WJP_theme(grid_linetype = "solid")$panel.grid.major$linetype, "solid")

  minimal <- WJP_theme(base_theme = ggplot2::theme_minimal())
  expect_true(isTRUE(attr(minimal, "complete")))
  expect_false(isTRUE(attr(WJP_theme(), "complete")))

  expect_error(WJP_theme(base_size = -1), "`base_size`")
  expect_error(WJP_theme(base_theme = "minimal"), "`base_theme`")
  expect_error(WJP_theme(grid = "both"))
})

test_that("report colors and sequential scales are available", {
  rep_pal <- wjp_palette("report")
  expect_named(rep_pal)
  expect_equal(rep_pal[["main"]], "#575796")
  expect_equal(wjp_colors()[["eu"]], "#A8A8C8")
  expect_equal(wjp_colors("categorical")[["violet"]], "#482d8b")
  expect_equal(wjp_palette(3), c("#482d8b", "#2894aa", "#f26b21"))
  expect_equal(unname(wjp_palette(2, palette = "report")), c("#575796", "#A8A8C8"))
  expect_error(wjp_palette(40, palette = "report"), "report palette")

  sc <- scale_fill_wjp_seq()
  expect_equal(toupper(sc$palette(c(0, 1))), c("#ECECF4", "#575796"))
  expect_equal(toupper(scale_colour_wjp_seq(low = "#000000", high = "#FFFFFF")$palette(0.5)), "#808080")

  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1, v = c(0, 50, 100)),
                       ggplot2::aes(x, y, fill = v)) +
    ggplot2::geom_tile() +
    scale_fill_wjp_seq()
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("wjp_layout validates and fills its geometry", {
  lay <- wjp_layout(label_width = 100, track_width = 250, margins = 2, inset = c(3, 0))
  expect_s3_class(lay, "wjp_layout")
  expect_equal(lay$margins, c(2, 2, 2, 2))
  expect_equal(lay$inset, c(3, 0))
  expect_output(print(lay), "wjp_layout")
  expect_error(wjp_layout(track_width = -1), "`track_width`")
  expect_error(wjp_layout(row_height = 0), "`row_height`")
  expect_error(wjp_layout(margins = c(1, 2)), "`margins`")
  expect_error(wjp_layout(inset = -1), "`inset`")

  full <- wjp_layout_resolve(lay, list(label_width = 10, row_height = 15))
  expect_equal(full$label_width, 100)
  expect_equal(full$row_height, 15)
})

test_that("ptheme overrides apply after the chart's own styling", {
  bars <- data.frame(cat = c("A", "B"), val = c(40, 60))

  default <- wjp_bars(bars, "val", "cat", direction = "horizontal")
  expect_equal(default$theme$axis.text.y$hjust, 0)

  custom <- wjp_bars(
    bars, "val", "cat", direction = "horizontal",
    ptheme = WJP_theme() + ggplot2::theme(axis.text.y = ggplot2::element_text(size = 7))
  )
  expect_equal(custom$theme$axis.text.y$size, 7)
  # the chart's alignment is kept: overrides merge into its elements
  expect_equal(custom$theme$axis.text.y$hjust, 0)

  smaller <- wjp_bars(bars, "val", "cat", ptheme = WJP_theme(base_size = 8))
  expect_equal(smaller$theme$axis.text.x$size, 8)

  # hidden elements stay hidden
  hidden <- wjp_bars(bars, "val", "cat", direction = "horizontal",
                     ptheme = WJP_theme(base_size = 8))
  expect_s3_class(hidden$theme$axis.title.x, "element_blank")

  # rich-text axis labels (national bar) accept plain overrides
  gb <- data.frame(group = c("G", "G"), level = c("A", "B"), value = c(40, 60))
  skip_if_not_installed("ggtext")
  p <- wjp_groupbars(
    gb, "value", "group", "level", show_national = TRUE, national_style = "bar",
    national_value = 50,
    ptheme = WJP_theme() + ggplot2::theme(axis.text.y = ggplot2::element_text(size = 8))
  )
  expect_no_error(ggplot2::ggplot_build(p))
  expect_equal(p$theme$axis.text.y$size, 8)
})

test_that("role faces fall back to bold when the weight family is missing", {
  withr::local_options(wjpr.family = "No Such Family")
  expect_equal(wjp_face("semibold.italic"),
               list(family = "No Such Family", fontface = "bold.italic"))
  expect_equal(wjp_face("plain")$fontface, "plain")
  expect_error(wjp_face("heavy"), "Font faces")
})

test_that("wjp_drawn reports drawn texts and marks", {
  d <- data.frame(country = c("A", "B"), value = c(40, 60), lab = c("40%", "60%"))
  p <- wjp_bars(d, "value", "country", labels = "lab")
  txt <- wjp_drawn(p)
  expect_true(all(c("40%", "60%") %in% txt$label[txt$source == "layer"]))
  expect_true(all(c("A", "B") %in% txt$label[txt$source == "axis-x"]))
  expect_equal(unique(txt$size[txt$source == "layer"]), 10, tolerance = 1e-6)

  marks <- wjp_drawn(p, "marks")
  expect_true("GeomCol" %in% marks$geom)
  expect_equal(sort(marks$y[marks$geom == "GeomCol"]), c(40, 60))
  expect_error(wjp_drawn("not a plot"), "ggplot")
})

test_that("wjp_save writes exact sizes and outlines SVG text", {
  skip_if_not_installed("svglite")
  skip_if_not_installed("xml2")
  skip_if_not_installed("textshaping")
  skip_if_not_installed("systemfonts")
  skip_if_not_installed("png")
  withr::local_options(wjpr.family = "sans")

  d <- data.frame(country = c("A", "B"), value = c(40, 60), lab = c("40%", "60%"))
  p <- wjp_bars(d, "value", "country", labels = "lab")

  svg <- withr::local_tempfile(fileext = ".svg")
  res <- wjp_save(p, svg, width = 4, height = 3)
  expect_equal(c(res$width, res$height), c(4, 3))
  doc <- readLines(svg)
  expect_length(grep("<text", doc), 0)
  expect_true(any(grepl("<path", doc)))
  expect_true(all(c("40%", "60%") %in% res$text$text))

  png_file <- withr::local_tempfile(fileext = ".png")
  wjp_save(p, png_file, width = 2, height = 1, png_dpi = 100)
  img <- png::readPNG(png_file)
  expect_equal(dim(img)[1:2], c(100, 200))

  expect_error(wjp_save(p, withr::local_tempfile(fileext = ".png")), "definite size")
  expect_error(wjp_save(p, "chart.jpg", width = 1, height = 1), "\\.svg")

  # a chart with a layout has a definite size
  lay <- wjp_bars(d, "value", "country", labels = "lab", direction = "horizontal",
                  layout = wjp_layout(label_width = 50, track_width = 200, value_width = 30,
                                      value_gap = 5, row_height = 20, bar_height = 12))
  size <- wjp_plot_size(lay)
  expect_equal(unname(size[["width"]]), (50 + 6 + 200 + 5 + 30) / 72, tolerance = 1e-3)
  png2 <- withr::local_tempfile(fileext = ".png")
  expect_no_error(wjp_save(lay, png2, png_dpi = 72))
})
