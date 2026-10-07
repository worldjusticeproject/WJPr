# WJPr

<!-- badges: start -->
[![R-CMD-check](https://github.com/worldjusticeproject/WJPr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/worldjusticeproject/WJPr/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

WJPr is an R package from the World Justice Project Data Analytics Unit for producing WJP-style graphics and working with Rule of Law Index data. It is designed for analysts who need publication-ready charts, reproducible examples, and consistent visual language across country-report and research workflows.

## Features

WJPr provides:

- Chart functions for bars, diverging bars, grouped bars, edge bars, dots, lines, slopes, dumbbells, lollipops, radar, rose, and gauge visualizations.
- Built-in sample datasets for Rule of Law Index and General Population Poll workflows.
- A shared WJP theme (`WJP_theme()`), fonts (`wjp_fonts()`, `wjp_font_family()`), and color palette (`wjp_palette()`) for consistent report graphics.
- `spread_labels_x()`, a deterministic helper that keeps value labels in row-based point charts from overlapping.
- Validation helpers for checking chart-ready data (`wjp_check_data()`) and dependencies (`wjp_check_deps()`), plus `diffmeans()` for difference-in-means tests.

## Installation

WJPr is hosted on GitHub. Install it with `remotes` (or `devtools`):

```R
# Install WJPr from GitHub
remotes::install_github("worldjusticeproject/WJPr")
```

## Usage

Load the package into your R session:

```R
library(WJPr)
```

### Example: Accessing Rule of Law Index Data

The package provides built-in datasets for analysis:

```R
# View the first few rows of the dataset
head(WJPr::roli)
```

### Example: Creating a Visualization

Create a simple WJP-style bar chart:

```R
library(dplyr)

# Load the WJP fonts before plotting
wjp_fonts()

# Prepare the data: % of respondents who trust Institution A, 2022
data4bars <- WJPr::gpp %>%
  filter(year == 2022) %>%
  mutate(
    q1a   = as.double(unclass(q1a)),  # survey answers are labelled vectors
    trust = case_when(q1a <= 2 ~ 1, q1a <= 4 ~ 0),
    year  = as.character(year)
  ) %>%
  group_by(country, year) %>%
  summarise(trust = mean(trust, na.rm = TRUE) * 100, .groups = "drop")

# Draw the chart
wjp_bars(
  data4bars,
  target   = "trust",
  grouping = "country",
  colors   = "year",
  cvec     = c("2022" = "#482d8b")
)
```

When `cvec` is omitted, every chart falls back to the WJP palette (`wjp_palette()`).

### Example: Changing the Chart Font

`wjp_fonts()` registers two font systems: **Lato** (the default, in Full, Light, and Black weights) and **Inter Tight**. Switch every chart of the session with the `wjpr.family` option:

```R
# Load the WJP fonts (Lato + Inter Tight)
wjp_fonts()

# All charts use Lato by default
wjp_bars(data4bars, target = "trust", grouping = "country")

# Switch every chart to Inter Tight
options(wjpr.family = "Inter Tight")
wjp_bars(data4bars, target = "trust", grouping = "country")

# Check the active family at any time
wjp_font_family()
#> [1] "Inter Tight"

# Back to Lato
options(wjpr.family = NULL)
```

See `wjp_font_family()` for per-chart and theme-only alternatives.

## Chart Gallery

WJPr includes focused chart functions for common WJP reporting patterns:

<div class="wjp-gallery-grid">
  <a class="wjp-gallery-card" href="reference/wjp_bars.html">
    <img src="man/figures/example-bars.png" alt="Example vertical bar chart">
    <strong>Bar Chart</strong>
    <code>wjp_bars()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_dots.html">
    <img src="man/figures/example-dots.png" alt="Example dot chart with confidence intervals">
    <strong>Dots Chart</strong>
    <code>wjp_dots()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_lines.html">
    <img src="man/figures/example-lines.png" alt="Example line chart">
    <strong>Line Chart</strong>
    <code>wjp_lines()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_divbars.html">
    <img src="man/figures/example-divbars.png" alt="Example diverging bar chart">
    <strong>Diverging Bars</strong>
    <code>wjp_divbars()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_dumbbells.html">
    <img src="man/figures/example-dumbbells.png" alt="Example dumbbell chart">
    <strong>Dumbbells</strong>
    <code>wjp_dumbbells()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_slope.html">
    <img src="man/figures/example-slope.png" alt="Example slope chart">
    <strong>Slope Chart</strong>
    <code>wjp_slope()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_radar.html">
    <img src="man/figures/example-radar.png" alt="Example radar chart">
    <strong>Radar Chart</strong>
    <code>wjp_radar()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_rose.html">
    <img src="man/figures/example-rose.png" alt="Example rose chart">
    <strong>Rose Chart</strong>
    <code>wjp_rose()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_gauge.html">
    <img src="man/figures/example-gauge.png" alt="Example gauge chart">
    <strong>Gauge Chart</strong>
    <code>wjp_gauge()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_lollipops.html">
    <img src="man/figures/example-lollipops.png" alt="Example lollipop chart">
    <strong>Lollipop Chart</strong>
    <code>wjp_lollipops()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_edgebars.html">
    <img src="man/figures/example-edgebars.png" alt="Example edge bar chart">
    <strong>Edgebars</strong>
    <code>wjp_edgebars()</code>
  </a>
  <a class="wjp-gallery-card" href="reference/wjp_groupbars.html">
    <img src="man/figures/example-groupbars.png" alt="Example grouped bar chart with confidence intervals">
    <strong>Grouped Bars</strong>
    <code>wjp_groupbars()</code>
  </a>
</div>

For a complete interactive gallery with code examples, see the [Chart Gallery vignette](https://worldjusticeproject.github.io/WJPr/articles/gallery.html).

## Data Structure

All WJPr visualization functions expect data in **long (tidy) format**:

```
| grouping     | target | colors   | labels (optional) |
|--------------|--------|----------|-------------------|
| Category A   | 45.2   | Group 1  | "45%"             |
| Category B   | 32.1   | Group 1  | "32%"             |
| Category A   | 51.0   | Group 2  | "51%"             |
| Category B   | 38.5   | Group 2  | "39%"             |
```

**Key parameters used across all functions:**

| Parameter  | Description                          | Type            |
|------------|--------------------------------------|-----------------|
| `target`   | Values to plot (Y-axis)              | Numeric column  |
| `grouping` | Categories (X-axis or rows)          | Character/Factor|
| `colors`   | Variable for color grouping          | Character/Factor|
| `cvec`     | Named vector mapping values to colors| `c("A" = "#HEX")`|
| `labels`   | Text labels to display               | Character column|

### Validate Your Data

Use `wjp_check_data()` to verify your data structure before plotting:

```R
wjp_check_data(
  data     = my_data,
  type     = "bars",
  target   = "value",
  grouping = "category",
  colors   = "group",
  cvec     = c("Group 1" = "#482d8b", "Group 2" = "#2894aa")
)
```

For detailed guidance, see the [Data Preparation vignette](https://worldjusticeproject.github.io/WJPr/articles/data-preparation.html).

## Documentation

Comprehensive documentation is available for all functions and datasets. Use the R help system to access it:

```R
?WJPr::wjp_lines
```

## Contributing

Contributions are welcome! Before contributing, please read our guidelines:

### Quick Start

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-chart`
3. Follow the coding conventions in [CONTRIBUTING.md](CONTRIBUTING.md)
4. Submit a pull request

### Adding New Functions

All visualization functions must follow the WJPr patterns:

```r
wjp_newchart <- function(
    data,
    target,
    grouping,
    colors    = NULL,
    cvec      = NULL,
    labels    = NULL,
    ptheme    = WJP_theme()
) {
  # 1. Rename columns using all_of()
  # 2. Handle NULL parameters
  # 3. Fall back to the WJP palette when cvec is NULL (wjp_default_cvec())
  # 4. Create ggplot, using wjp_font_family() for text layers
  # 5. Apply ptheme, then chart-specific theme() tweaks
  return(plt)
}
```

### Documentation Requirements

- Roxygen2 with `@export`, `@param`, `@return`, `@examples`
- Include `lifecycle::badge("experimental")` in description
- Add tests in `tests/testthat/` and an example to `data-raw/generate-examples.R`
- Register the function in `_pkgdown.yml` and update `NEWS.md`

### Resources

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Complete contribution guidelines
- **[Development Guide](https://worldjusticeproject.github.io/WJPr/articles/development-guide.html)** - Step-by-step tutorial
- **[Issues](https://github.com/worldjusticeproject/WJPr/issues)** - Report bugs or request features

## License

This project is licensed under the MIT License. See the `LICENSE.md` file for details.

## Acknowledgments

WJPr was developed by the Data Analytics Unit at The World Justice Project. Special thanks to the whole team for their invaluable input in creating this package.
