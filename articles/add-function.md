# Adding a New Function

This guide summarizes the recommended workflow for adding a new function
to WJPr. For more detail, see the [complete development
guide](https://worldjusticeproject.github.io/WJPr/articles/development-guide.md).

## 1. Create the file

Chart functions live in `R/` and follow this convention:

- `R/{type}Chart.R` for charts, for example `R/waterfallChart.R`.
- `R/{name}.R` for utilities, validators, or non-chart functions.

The exported function must use the `wjp_` prefix:

``` r

wjp_waterfall <- function(
    data,
    target,
    grouping,
    colors      = NULL,
    cvec        = NULL,
    labels      = NULL,
    ptheme      = WJP_theme(),
    show_legend = FALSE
) {
  # implementation
}
```

## 2. Document with roxygen2

Every public function needs complete roxygen documentation:

``` r

#' Plot a Waterfall Chart following WJP style guidelines
#'
#' @description
#' \ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
#'
#' `wjp_waterfall()` creates a waterfall chart following WJP style guidelines.
#'
#' @param data Data frame containing the data to plot.
#' @param target String. Column name containing numeric values.
#' @param grouping String. Column name containing categories.
#' @param colors String. Column name for color groups. Default is `NULL`.
#' @param cvec Named vector of colors. Default is `NULL` (the WJP palette,
#'   see [wjp_palette()], is applied).
#' @param labels String. Column name with labels. Default is `NULL`.
#' @param ptheme ggplot theme to apply. Default is [WJP_theme()].
#' @param show_legend Logical. If `TRUE`, displays a horizontal legend above
#'   the chart. Default is `FALSE`.
#'
#' @return A ggplot object.
#' @export
```

After documenting, run:

``` r

devtools::document()
```

This updates `NAMESPACE` and the files in `man/`.

## 3. Use the internal column pattern

Functions rename the input columns to stable internal names. This keeps
the code consistent across charts:

``` r

data <- data %>%
  dplyr::rename(
    target_var   = dplyr::all_of(target),
    grouping_var = dplyr::all_of(grouping)
  )

if (is.null(colors) || identical(colors, grouping)) {
  data <- data %>%
    dplyr::mutate(colors_var = grouping_var)
} else {
  data <- data %>%
    dplyr::rename(colors_var = dplyr::all_of(colors))
}
```

## 4. Validate important inputs

Add clear errors for cases that would produce invalid charts:

``` r

if (!is.data.frame(data)) {
  stop("`data` must be a data frame.", call. = FALSE)
}

if (any(!is.na(data$target_var) & data$target_var < 0)) {
  stop("`target` must contain non-negative values.", call. = FALSE)
}
```

For general validations, use or extend
[`wjp_check_data()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_data.md).

## 5. Apply colors, fonts, and theme

Functions return a `ggplot` object, fall back to the WJP palette when
`cvec` is `NULL`, read the active font with
[`wjp_font_family()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_font_family.md),
and respect `ptheme`:

``` r

if (is.null(cvec)) {
  cvec <- wjp_default_cvec(data$colors_var)
}

plt <- ggplot2::ggplot(data, ggplot2::aes(grouping_var, target_var, fill = colors_var)) +
  ggplot2::geom_col(show.legend = show_legend) +
  ggplot2::geom_text(
    ggplot2::aes(label = labels_var),
    family   = wjp_font_family(),
    fontface = "bold",
    size     = 3.514598
  ) +
  ggplot2::scale_fill_manual(
    values = cvec,
    breaks = wjp_legend_breaks(data$colors_var),
    name   = NULL
  )

plt <- plt + ptheme + wjp_legend_theme(show_legend)

return(plt)
```

Do not call
[`WJP_theme()`](https://worldjusticeproject.github.io/WJPr/reference/WJP_theme.md)
directly inside the function when a `ptheme` argument already exists.

## 6. Add tests

Add at least one test in `tests/testthat/` that confirms:

- The function returns a `ggplot` object.
- [`ggplot2::ggplot_build()`](https://ggplot2.tidyverse.org/reference/ggplot_build.html)
  does not fail.
- The important optional arguments work.
- Expected errors have clear messages.

Example:

``` r

test_that("wjp_waterfall returns a buildable ggplot", {
  data <- data.frame(
    category = c("Start", "Gain", "Loss"),
    value    = c(100, 30, -20)
  )

  plot <- wjp_waterfall(data, target = "value", grouping = "category")

  expect_s3_class(plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(plot))
})
```

## 7. Add the function to the website

Update `_pkgdown.yml`:

1.  Add the function to the `navbar > components > functions` dropdown.
2.  Add it to the right section in `reference`.
3.  If relevant, add a visual example to
    `vignettes/articles/gallery.Rmd` and `data-raw/generate-examples.R`.

Also add an entry to `NEWS.md`.

## 8. Check before pushing

Run:

``` r

devtools::test()
devtools::check()
pkgdown::build_site()
```

If everything passes, the function is ready for review.
