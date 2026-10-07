# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Project Overview

WJPr is an R package developed by the Data Analytics Unit at The World
Justice Project (WJP). It provides visualization functions for creating
publication-ready charts following WJP style guidelines, plus Rule of
Law Index data and analysis tools.

## Development Commands

### Package Installation

``` r

remotes::install_github("worldjusticeproject/WJPr")
```

### Environment Setup (renv)

``` r

renv::restore()         # Install exact package versions from renv.lock
renv::status()          # Check if environment matches lockfile
renv::snapshot()        # Update lockfile after installing packages
```

### Building and Checking

``` r

devtools::document()    # Generate documentation from Roxygen2 comments
devtools::build()       # Build the package
devtools::check()       # Run R CMD check (expected: 0 errors, 0 warnings, 0 notes)
devtools::load_all()    # Load package for testing during development
```

### Running Tests

``` r

devtools::test()                    # Run all tests
testthat::test_file("tests/testthat/test-charts.R")  # Run single test file
```

Test files: `test-charts.R` (chart functions), `test-spread_labels.R`
(label solver), `test-analysis.R`
([`diffmeans()`](https://worldjusticeproject.github.io/WJPr/reference/diffmeans.md),
[`wjp_check_data()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_data.md),
[`wjp_check_deps()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_deps.md)).

### Documentation

``` r

pkgdown::build_site()               # Build the documentation website locally
source("data-raw/generate-examples.R")  # Regenerate man/figures/example-*.png
```

## Architecture

### Function Pattern

All visualization functions follow a consistent pattern: - Named
`wjp_*()` (e.g.,
[`wjp_bars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_bars.md),
[`wjp_lines()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lines.md),
[`wjp_radar()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_radar.md)) -
Accept a data frame with tidy/long-format data - Return a ggplot2 object
for further customization - Use common parameters: `target`, `grouping`,
`colors`, `cvec` (named color vector), `labels`, `ptheme`,
`show_legend` - Known exceptions:
[`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md)
takes `colors` as a length-2 hex vector (primary, complement) and
`levels` for the rows;
[`wjp_radar()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_radar.md)
uses `axis_var` instead of `grouping` and has no `ptheme`;
[`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md)
takes `order` as a named vector instead of a column name

### Key Files

- `R/utils.R` -
  [`wjp_fonts()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_fonts.md)
  loads Lato and Inter Tight fonts;
  [`wjp_font_family()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_font_family.md)
  returns the active family (`options(wjpr.family = )`);
  [`WJP_theme()`](https://worldjusticeproject.github.io/WJPr/reference/WJP_theme.md)
  provides the base ggplot2 theme;
  [`wjp_palette()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_palette.md)
  exposes the WJP categorical palette; internal helpers
  `wjp_default_cvec()` (palette fallback when `cvec` is NULL),
  `wjp_legend_breaks()` and `wjp_legend_theme()` (shared top legend)
- `R/*Chart.R` - Each chart type has its own file (barsChart.R,
  lineChart.R, radarChart.R, etc.)
- `R/spread_labels.R` -
  [`spread_labels_x()`](https://worldjusticeproject.github.io/WJPr/reference/spread_labels_x.md)
  deterministic horizontal collision solver that spreads overlapping
  point labels for row-based charts (dots, lollipops); keeps points
  fixed and moves only labels
- `R/check_data.R` -
  [`wjp_check_data()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_data.md)
  validates data structure before plotting
- `R/check_deps.R` -
  [`wjp_check_deps()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_deps.md)
  reports core/optional dependency status
- `R/diffmeans.R` - Statistical analysis function for hypothesis testing
- `R/imports.R` - Centralized `@importFrom` declarations (optional
  packages are used with `pkg::` after
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html))
- `R/WJPr-package.R` -
  [`globalVariables()`](https://rdrr.io/r/utils/globalVariables.html)
  for NSE column names and the `.onAttach()` optional-dependency message
- `R/data.R` - Documentation of the `gpp` and `roli` datasets
  (`data/*.rda`, built by `data-raw/gpp.R` and `data-raw/roli.R`)
- `data-raw/generate-examples.R` - Regenerates the gallery/README images
  in `man/figures/`
- `dev/` - Ad-hoc visual preview scripts (excluded from the build)
- `vignettes/articles/` - pkgdown articles: `gallery`,
  `data-preparation`, `dataviz` (usage) and `add-function`,
  `development-guide` (development)

### Chart Functions (12)

| Function | File | Description |
|----|----|----|
| [`wjp_bars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_bars.md) | barsChart.R | Vertical/horizontal (and stacked) bar charts |
| [`wjp_divbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_divbars.md) | divbarsChart.R | Diverging bar charts |
| [`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md) | dotsChart.R | Dot plots, with optional CIs and collision-free value labels (`show_labels`, via [`spread_labels_x()`](https://worldjusticeproject.github.io/WJPr/reference/spread_labels_x.md)) |
| [`wjp_lines()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lines.md) | lineChart.R | Line charts with points |
| [`wjp_slope()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_slope.md) | slopeChart.R | Slope charts for two time points |
| [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md) | dumbbellsChart.R | Dumbbell plots |
| [`wjp_radar()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_radar.md) | radarChart.R | Radar/spider charts |
| [`wjp_rose()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_rose.md) | roseChart.R | Rose/polar bar charts |
| [`wjp_gauge()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_gauge.md) | gaugeChart.R | Gauge/speedometer charts |
| [`wjp_lollipops()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lollipops.md) | lollipopChart.R | Lollipop charts |
| [`wjp_edgebars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_edgebars.md) | edgebarsChart.R | Edge-aligned horizontal bars |
| [`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md) | groupbarsChart.R | Faceted stacked bars by demographic groups, with optional CI and national line/bar |

Other exported functions:
[`diffmeans()`](https://worldjusticeproject.github.io/WJPr/reference/diffmeans.md),
[`wjp_check_data()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_data.md),
[`wjp_check_deps()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_deps.md),
[`spread_labels_x()`](https://worldjusticeproject.github.io/WJPr/reference/spread_labels_x.md),
[`wjp_fonts()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_fonts.md),
[`wjp_font_family()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_font_family.md),
[`wjp_palette()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_palette.md),
[`WJP_theme()`](https://worldjusticeproject.github.io/WJPr/reference/WJP_theme.md),
and the re-exported `%>%`.

### Styling Conventions

- Font: Lato (loaded via Google Fonts using sysfonts/showtext); always
  use
  [`wjp_font_family()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_font_family.md)
  (never a hard-coded `"Lato Full"`) for text layers so
  `options(wjpr.family = )` switches every chart
- WJP color palette uses hex codes such as `#482d8b`, `#2894aa`,
  `#f26b21`, and `#555659` (full ordered palette available via
  [`wjp_palette()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_palette.md))
- Colors are passed via named vectors (`cvec`) where names match
  grouping variable values; when `cvec` is NULL, functions fall back to
  [`wjp_palette()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_palette.md)
  (via `wjp_default_cvec()`)
- Always call
  [`wjp_fonts()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_fonts.md)
  before plotting to ensure fonts are available
- Value labels: bold, `size = 3.514598` (10 pt), ink color `#4a4a49`
- Grid lines:
  [`WJP_theme()`](https://worldjusticeproject.github.io/WJPr/reference/WJP_theme.md)
  draws dashed `#5e5c5a` lines (kept by dots/dumbbells over their row
  strips); bar, line, and lollipop charts override the value-axis grid
  with solid `#d1cfd1`
- Category axis text: `#524F4C`, `hjust = 0`
- Horizontal charts display the first data row at the top
- Legends: horizontal, top-left, via `wjp_legend_theme(show_legend)`

### Documentation

- Uses Roxygen2 for inline documentation (roxygen2 8.0.0, recorded as
  `Config/roxygen2/version` in DESCRIPTION)
- All exported functions need `@export` tag
- Functions are marked with `lifecycle::badge("experimental")` where
  applicable
- Renamed/obsolete arguments use `arg = deprecated()` plus
  `lifecycle::deprecate_soft("<version>", "fn(arg)", "fn(new_arg)")`,
  and are documented with `lifecycle::badge("deprecated")`
- Examples should use the built-in
  [`WJPr::gpp`](https://worldjusticeproject.github.io/WJPr/reference/gpp.md)
  or
  [`WJPr::roli`](https://worldjusticeproject.github.io/WJPr/reference/roli.md)
  datasets; `gpp` survey answers are `haven_labelled`, so convert them
  with `as.double(unclass(x))`

## CI/CD

GitHub Actions workflows in `.github/workflows/`: - `R-CMD-check.yaml` -
R CMD check on macOS, Windows, and Ubuntu (devel, release, oldrel-1) for
pushes and PRs to main - `test-coverage.yaml` - covr coverage uploaded
to Codecov - `pkgdown.yaml` - builds the documentation site and deploys
it to GitHub Pages (`gh-pages` branch) on push to main/master

## Contributing Guidelines

### Adding New Functions

1.  **File naming**: `R/{tipo}Chart.R` (e.g., `R/waterfallChart.R`)
2.  **Function naming**: `wjp_{tipo}()` (e.g., `wjp_waterfall()`)
3.  **Required parameters**: `data`, `target`, `grouping`
4.  **Optional parameters**: `colors`, `cvec`, `labels`,
    `ptheme = WJP_theme()`, `show_legend = FALSE`

### Function Structure Pattern

``` r

wjp_newchart <- function(data, target, grouping, colors = NULL, cvec = NULL,
                         ptheme = WJP_theme(), show_legend = FALSE) {
  # 1. Rename columns with all_of()
  data <- data %>% rename(target_var = all_of(target), grouping_var = all_of(grouping))

  # 2. Handle NULL/duplicate parameters
  if (is.null(colors) || identical(colors, grouping)) {
    data <- data %>% mutate(colors_var = grouping_var)
  } else {
    data <- data %>% rename(colors_var = all_of(colors))
  }

  # 3. Fall back to the WJP palette when no color vector is supplied
  if (is.null(cvec)) cvec <- wjp_default_cvec(data$colors_var)

  # 4. Create ggplot (text layers use family = wjp_font_family())
  plt <- ggplot(data, aes(...)) + geom_*(show.legend = show_legend) +
    scale_fill_manual(values = cvec, breaks = wjp_legend_breaks(data$colors_var), name = NULL)

  # 5. Apply theme, chart-specific tweaks, and the shared legend
  plt <- plt + ptheme + theme(...) + wjp_legend_theme(show_legend)

  return(plt)
}
```

### Checklist Before PR

Roxygen2 docs with `@export`, `@param`, `@return`, `@examples`

Include `lifecycle::badge("experimental")`

Add tests in `tests/testthat/`

Add to `data-raw/generate-examples.R` and
`vignettes/articles/gallery.Rmd`

Register the function in `_pkgdown.yml` (navbar menu and reference
index)

Add an entry to `NEWS.md` and update this CLAUDE.md file

Run `devtools::document()` and `devtools::check()`

### Documentation Files

- `CONTRIBUTING.md` - Complete contribution guidelines
- `vignettes/articles/add-function.Rmd` - Short checklist-style guide
- `vignettes/articles/development-guide.Rmd` - Step-by-step tutorial
- `.github/ISSUE_TEMPLATE/` - Issue templates
- `.github/pull_request_template.md` - PR template
- `.github/REVIEW_CHECKLIST.md` - Reviewer checklist
