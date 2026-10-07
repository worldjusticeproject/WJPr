# WJPr

WJPr is an R package from the World Justice Project Data Analytics Unit
for producing WJP-style graphics and working with Rule of Law Index
data. It is designed for analysts who need publication-ready charts,
reproducible examples, and consistent visual language across
country-report and research workflows.

## Features

WJPr provides:

- Chart functions for bars, diverging bars, grouped bars, edge bars,
  dots, lines, slopes, dumbbells, lollipops, radar, rose, and gauge
  visualizations.
- Built-in sample datasets for Rule of Law Index and General Population
  Poll workflows.
- A shared WJP theme
  ([`WJP_theme()`](https://worldjusticeproject.github.io/WJPr/reference/WJP_theme.md)),
  fonts
  ([`wjp_fonts()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_fonts.md),
  [`wjp_font_family()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_font_family.md)),
  and color palette
  ([`wjp_palette()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_palette.md))
  for consistent report graphics.
- [`spread_labels_x()`](https://worldjusticeproject.github.io/WJPr/reference/spread_labels_x.md),
  a deterministic helper that keeps value labels in row-based point
  charts from overlapping.
- Validation helpers for checking chart-ready data
  ([`wjp_check_data()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_data.md))
  and dependencies
  ([`wjp_check_deps()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_deps.md)),
  plus
  [`diffmeans()`](https://worldjusticeproject.github.io/WJPr/reference/diffmeans.md)
  for difference-in-means tests.

## Installation

WJPr is hosted on GitHub. Install it with `remotes` (or `devtools`):

``` r

# Install WJPr from GitHub
remotes::install_github("worldjusticeproject/WJPr")
```

## Usage

Load the package into your R session:

``` r

library(WJPr)
```

### Example: Accessing Rule of Law Index Data

The package provides built-in datasets for analysis:

``` r

# View the first few rows of the dataset
head(WJPr::roli)
```

### Example: Creating a Visualization

Create a simple WJP-style bar chart:

``` r

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

When `cvec` is omitted, every chart falls back to the WJP palette
([`wjp_palette()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_palette.md)).

### Example: Changing the Chart Font

[`wjp_fonts()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_fonts.md)
registers two font systems: **Lato** (the default, in Full, Light, and
Black weights) and **Inter Tight**. Switch every chart of the session
with the `wjpr.family` option:

``` r

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

See
[`wjp_font_family()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_font_family.md)
for per-chart and theme-only alternatives.

## Chart Gallery

WJPr includes focused chart functions for common WJP reporting patterns:

[![Example vertical bar chart](reference/figures/example-bars.png)**Bar
Chart**
`wjp_bars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_bars.md)
[![Example dot chart with confidence
intervals](reference/figures/example-dots.png)**Dots Chart**
`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md)
[![Example line chart](reference/figures/example-lines.png)**Line
Chart**
`wjp_lines()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lines.md)
[![Example diverging bar
chart](reference/figures/example-divbars.png)**Diverging Bars**
`wjp_divbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_divbars.md)
[![Example dumbbell
chart](reference/figures/example-dumbbells.png)**Dumbbells**
`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md)
[![Example slope chart](reference/figures/example-slope.png)**Slope
Chart**
`wjp_slope()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_slope.md)
[![Example radar chart](reference/figures/example-radar.png)**Radar
Chart**
`wjp_radar()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_radar.md)
[![Example rose chart](reference/figures/example-rose.png)**Rose Chart**
`wjp_rose()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_rose.md)
[![Example gauge chart](reference/figures/example-gauge.png)**Gauge
Chart**
`wjp_gauge()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_gauge.md)
[![Example lollipop
chart](reference/figures/example-lollipops.png)**Lollipop Chart**
`wjp_lollipops()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lollipops.md)
[![Example edge bar
chart](reference/figures/example-edgebars.png)**Edgebars**
`wjp_edgebars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_edgebars.md)
[![Example grouped bar chart with confidence
intervals](reference/figures/example-groupbars.png)**Grouped Bars**
`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md)

For a complete interactive gallery with code examples, see the [Chart
Gallery
vignette](https://worldjusticeproject.github.io/WJPr/articles/gallery.html).

## Data Structure

All WJPr visualization functions expect data in **long (tidy) format**:

    | grouping     | target | colors   | labels (optional) |
    |--------------|--------|----------|-------------------|
    | Category A   | 45.2   | Group 1  | "45%"             |
    | Category B   | 32.1   | Group 1  | "32%"             |
    | Category A   | 51.0   | Group 2  | "51%"             |
    | Category B   | 38.5   | Group 2  | "39%"             |

**Key parameters used across all functions:**

| Parameter  | Description                           | Type              |
|------------|---------------------------------------|-------------------|
| `target`   | Values to plot (Y-axis)               | Numeric column    |
| `grouping` | Categories (X-axis or rows)           | Character/Factor  |
| `colors`   | Variable for color grouping           | Character/Factor  |
| `cvec`     | Named vector mapping values to colors | `c("A" = "#HEX")` |
| `labels`   | Text labels to display                | Character column  |

### Validate Your Data

Use
[`wjp_check_data()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_data.md)
to verify your data structure before plotting:

``` r

wjp_check_data(
  data     = my_data,
  type     = "bars",
  target   = "value",
  grouping = "category",
  colors   = "group",
  cvec     = c("Group 1" = "#482d8b", "Group 2" = "#2894aa")
)
```

For detailed guidance, see the [Data Preparation
vignette](https://worldjusticeproject.github.io/WJPr/articles/data-preparation.html).

## Documentation

Comprehensive documentation is available for all functions and datasets.
Use the R help system to access it:

``` r

?WJPr::wjp_lines
```

## Contributing

Contributions are welcome! Before contributing, please read our
guidelines:

### Quick Start

1.  Fork the repository
2.  Create a feature branch: `git checkout -b feature/new-chart`
3.  Follow the coding conventions in
    [CONTRIBUTING.md](https://worldjusticeproject.github.io/WJPr/CONTRIBUTING.md)
4.  Submit a pull request

### Adding New Functions

All visualization functions must follow the WJPr patterns:

``` r

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
- Add tests in `tests/testthat/` and an example to
  `data-raw/generate-examples.R`
- Register the function in `_pkgdown.yml` and update `NEWS.md`

### Resources

- **[CONTRIBUTING.md](https://worldjusticeproject.github.io/WJPr/CONTRIBUTING.md)** -
  Complete contribution guidelines
- **[Development
  Guide](https://worldjusticeproject.github.io/WJPr/articles/development-guide.html)** -
  Step-by-step tutorial
- **[Issues](https://github.com/worldjusticeproject/WJPr/issues)** -
  Report bugs or request features

## License

This project is licensed under the MIT License. See the `LICENSE.md`
file for details.

## Acknowledgments

WJPr was developed by the Data Analytics Unit at The World Justice
Project. Special thanks to the whole team for their invaluable input in
creating this package.
