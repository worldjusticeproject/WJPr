# Data Preparation for WJPr

This vignette explains how to prepare your data for use with WJPr
visualization functions. All WJPr functions expect data in a specific
structure, and understanding this structure will help you create charts
quickly and avoid common errors.

``` r

library(dplyr)
library(tidyr)
library(WJPr)
```

## The Golden Rule: Long (Tidy) Format

All WJPr visualization functions expect data in **long format** (also
known as tidy format). This means:

- Each row represents a single observation
- Each column represents a single variable
- Each cell contains a single value

### Wide vs Long Format

Here’s an example of the same data in both formats:

**Wide format (NOT what WJPr expects):**

| country   | trust_2017 | trust_2019 | trust_2022 |
|:----------|-----------:|-----------:|-----------:|
| Atlantis  |       45.2 |       48.5 |       51.0 |
| Narnia    |       38.1 |       41.2 |       44.3 |
| Neverland |       52.3 |       49.8 |       47.5 |

Wide format - one column per year {.table}

**Long format (what WJPr expects):**

| country   | year | trust |
|:----------|:-----|------:|
| Atlantis  | 2017 |  45.2 |
| Atlantis  | 2019 |  48.5 |
| Atlantis  | 2022 |  51.0 |
| Narnia    | 2017 |  38.1 |
| Narnia    | 2019 |  41.2 |
| Narnia    | 2022 |  44.3 |
| Neverland | 2017 |  52.3 |
| Neverland | 2019 |  49.8 |
| Neverland | 2022 |  47.5 |

Long format - one row per observation {.table}

### Converting Wide to Long

Use
[`tidyr::pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html)
to convert your data:

``` r

wide_data <- data.frame(
  country = c("Atlantis", "Narnia", "Neverland"),
  trust_2017 = c(45.2, 38.1, 52.3),
  trust_2019 = c(48.5, 41.2, 49.8),
  trust_2022 = c(51.0, 44.3, 47.5)
)

long_data <- wide_data %>%
  pivot_longer(
    cols      = starts_with("trust_"),
    names_to  = "year",
    values_to = "trust"
  ) %>%
  mutate(
    year = gsub("trust_", "", year)
  )

knitr::kable(long_data)
```

| country   | year | trust |
|:----------|:-----|------:|
| Atlantis  | 2017 |  45.2 |
| Atlantis  | 2019 |  48.5 |
| Atlantis  | 2022 |  51.0 |
| Narnia    | 2017 |  38.1 |
| Narnia    | 2019 |  41.2 |
| Narnia    | 2022 |  44.3 |
| Neverland | 2017 |  52.3 |
| Neverland | 2019 |  49.8 |
| Neverland | 2022 |  47.5 |

## Standard Column Structure

WJPr functions use consistent parameter names across all chart types.
Here’s what each parameter expects:

| Parameter | Purpose | Expected Type | Example |
|----|----|----|----|
| `target` | Values to plot (Y-axis) | Numeric | Percentages, scores, counts |
| `grouping` | Categories (X-axis or rows) | Character/Factor | Countries, institutions, years |
| `colors` | Color grouping variable | Character/Factor | Groups, categories, years |
| `labels` | Text labels to display | Character | “45%”, “High”, formatted values |
| `cvec` | Color mapping | Named vector | `c("Group A" = "#482d8b")` |

### Minimal Required Structure

For most charts, you need at minimum:

``` r

minimal_data <- data.frame(
  category = c("A", "B", "C", "D"),
  value    = c(25, 45, 30, 50)
)

knitr::kable(minimal_data, caption = "Minimal structure: grouping + target")
```

| category | value |
|:---------|------:|
| A        |    25 |
| B        |    45 |
| C        |    30 |
| D        |    50 |

Minimal structure: grouping + target {.table}

### Complete Structure with All Options

``` r

complete_data <- data.frame(
  category     = c("A", "B", "C", "D"),
  value        = c(25, 45, 30, 50),
  group        = c("Type 1", "Type 1", "Type 2", "Type 2"),
  value_label  = c("25%", "45%", "30%", "50%"),
  label_pos    = c(30, 50, 35, 55),
  order        = c(1, 2, 3, 4)
)

knitr::kable(complete_data, caption = "Complete structure with all optional columns")
```

| category | value | group  | value_label | label_pos | order |
|:---------|------:|:-------|:------------|----------:|------:|
| A        |    25 | Type 1 | 25%         |        30 |     1 |
| B        |    45 | Type 1 | 45%         |        50 |     2 |
| C        |    30 | Type 2 | 30%         |        35 |     3 |
| D        |    50 | Type 2 | 50%         |        55 |     4 |

Complete structure with all optional columns {.table}

## Preparing Data: Step by Step

### Step 1: Calculate Your Metrics

Start from raw data and calculate the values you want to plot:

``` r

gpp_data <- WJPr::gpp

step1 <- gpp_data %>%
  mutate(
    q1a = as.double(unclass(q1a)),
    trust = case_when(
      q1a <= 2  ~ 1,
      q1a <= 4  ~ 0,
      q1a == 99 ~ NA_real_
    )
  )
```

### Step 2: Aggregate by Groups

Group and summarize to get one value per category:

``` r

step2 <- step1 %>%
  group_by(country, year) %>%
  summarise(
    trust = mean(trust, na.rm = TRUE) * 100,
    .groups = "drop"
  )

knitr::kable(step2)
```

| country   | year |    trust |
|:----------|-----:|---------:|
| Atlantis  | 2017 | 62.39316 |
| Atlantis  | 2019 | 63.51351 |
| Atlantis  | 2022 | 49.09091 |
| Narnia    | 2017 | 61.66667 |
| Narnia    | 2019 | 68.29268 |
| Narnia    | 2022 | 45.65217 |
| Neverland | 2017 | 53.63636 |
| Neverland | 2019 | 62.50000 |
| Neverland | 2022 | 63.63636 |

### Step 3: Add Display Columns

Create columns for labels, colors, and ordering:

``` r

step3 <- step2 %>%
  filter(year == 2022) %>%
  mutate(
    value_label = paste0(round(trust, 0), "%"),
    label_pos   = trust + 5,
    color_group = country
  )

knitr::kable(step3)
```

| country   | year |    trust | value_label | label_pos | color_group |
|:----------|-----:|---------:|:------------|----------:|:------------|
| Atlantis  | 2022 | 49.09091 | 49%         |  54.09091 | Atlantis    |
| Narnia    | 2022 | 45.65217 | 46%         |  50.65217 | Narnia      |
| Neverland | 2022 | 63.63636 | 64%         |  68.63636 | Neverland   |

### Step 4: Plot

Now your data is ready for WJPr:

``` r

wjp_fonts()

wjp_bars(
  step3,
  target   = "trust",
  grouping = "country",
  labels   = "value_label",
  lab_pos  = "label_pos",
  colors   = "color_group",
  cvec     = c("Atlantis"  = "#482d8b",
               "Narnia"    = "#2894aa",
               "Neverland" = "#f26b21")
)
```

## Common Data Patterns

### Pattern 1: Simple Comparison (Bar/Lollipop)

One value per category:

``` r

pattern_simple <- data.frame(
  institution = c("Police", "Courts", "Parliament", "Government"),
  trust       = c(45, 38, 29, 35),
  label       = c("45%", "38%", "29%", "35%")
)
```

### Pattern 2: Grouped Comparison (Dots/Grouped Bars)

Multiple groups per category:

``` r

pattern_grouped <- data.frame(
  institution = rep(c("Police", "Courts", "Parliament"), 2),
  gender      = rep(c("Male", "Female"), each = 3),
  trust       = c(48, 40, 31, 42, 36, 27)
)
```

### Pattern 3: Time Series (Lines/Slopes)

Values across time:

``` r

pattern_time <- data.frame(
  year  = rep(2017:2022, 2),
  group = rep(c("Urban", "Rural"), each = 6),
  value = c(45, 47, 48, 46, 50, 52, 38, 40, 39, 41, 43, 44)
)
```

### Pattern 4: Two-Point Comparison (Dumbbells)

Start and end values:

``` r

pattern_dumbbell <- data.frame(
  category = rep(c("A", "B", "C"), 2),
  period   = rep(c("2017", "2022"), each = 3),
  value    = c(40, 35, 45, 52, 48, 50)
)
```

### Pattern 5: Composition (Diverging Bars/Stacked)

Parts that sum to 100%. All values can be positive:
[`wjp_divbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_divbars.md)
flips the group named in `negative` (here `negative = "Disagree"`) to
the left side automatically.

``` r

pattern_composition <- data.frame(
  country  = rep(c("Atlantis", "Narnia"), each = 2),
  response = rep(c("Agree", "Disagree"), 2),
  percent  = c(65, 35, 45, 55)
)
```

### Pattern 6: Multi-dimensional (Radar/Rose)

Multiple variables per unit.
[`wjp_rose()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_rose.md)
accepts proportions (0-1) or percentages (0-100); for
[`wjp_radar()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_radar.md),
set `source = "QRQ"` for 0-1 scores (the default `"GPP"` expects
percentages).

``` r

pattern_radar <- data.frame(
  dimension = c("Speed", "Quality", "Cost", "Access", "Trust"),
  score     = c(0.72, 0.65, 0.48, 0.81, 0.55),
  label     = c("Speed", "Quality", "Cost", "Access", "Trust")
)
```

## Working with the GPP Sample Data

Survey answers in
[`WJPr::gpp`](https://worldjusticeproject.github.io/WJPr/reference/gpp.md)
are stored as labelled vectors (`haven_labelled`). Convert them to plain
numbers before comparing or summarizing them:

``` r

gpp_numeric <- WJPr::gpp %>%
  mutate(across(c(gend, starts_with("q")), \(x) as.double(unclass(x))))
```

Code `99` means “Don’t know/No answer”; decide explicitly whether to
exclude it (as in the examples above) or count it in the denominator.

## Using wjp_check_data()

WJPr includes a helper function to validate your data structure before
plotting:

``` r

# Check if data is ready for a bar chart
wjp_check_data(
  data     = my_data,
  type     = "bars",
  target   = "value",
  grouping = "category",
  colors   = "group"
)
```

This will check:

- Required columns exist
- Column types are correct
- No unexpected NA values
- Color vector matches data values

## Common Mistakes and Solutions

### Mistake 1: Data in Wide Format

**Problem:**

``` r

# This won't work
bad_data <- data.frame(
  country    = c("A", "B"),
  year_2017  = c(45, 50),
  year_2022  = c(52, 55)
)
```

**Solution:** Use
[`pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html):

``` r

good_data <- bad_data %>%
  pivot_longer(
    cols      = starts_with("year_"),
    names_to  = "year",
    values_to = "value"
  )
```

### Mistake 2: Missing Color Mapping

**Problem:**

``` r

# cvec names don't match data values
cvec = c("Group1" = "#482d8b")  # But data has "group1" (lowercase)
```

**Solution:** Ensure exact match between cvec names and data values:

``` r

# Check unique values first
unique(data$color_column)

# Then create matching cvec
cvec = c("group1" = "#482d8b")
```

### Mistake 3: Target Column is Character

**Problem:**

``` r

# Values stored as text
data$value <- c("45%", "50%", "38%")
```

**Solution:** Keep numeric values separate from labels:

``` r

data <- data %>%
  mutate(
    value = c(45, 50, 38),
    label = paste0(value, "%")
  )
```

### Mistake 4: Grouped Data Not Aggregated

**Problem:** Raw survey data with one row per respondent.

**Solution:** Aggregate first:

``` r

data <- raw_data %>%
  group_by(country, year) %>%
  summarise(
    value = mean(variable, na.rm = TRUE),
    .groups = "drop"
  )
```

## Quick Reference: Data Structure by Chart Type

Required and optional column arguments (each one names a column of your
data), plus the main non-column options:

| Chart Type | Required Columns | Optional Columns | Main Options |
|----|----|----|----|
| [`wjp_bars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_bars.md) | target, grouping | colors, labels, lab_pos, order | direction, stacked, expand, show_legend |
| [`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md) | target, grouping, colors | order, labels, sd + sample_size (for CI) | draw_ci, show_labels, opacities, shapes, show_legend |
| [`wjp_lines()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lines.md) | target, grouping | colors, labels | repel, transparency + transparencies, show_legend |
| [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md) | target, grouping, colors | labels, labpos | cgroups (required), order (named vector), label_offset, show_legend |
| [`wjp_divbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_divbars.md) | target, grouping, diverging | labels, order | negative, show_legend |
| [`wjp_radar()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_radar.md) | target, axis_var, labels, colors | order, maincat | source, show_legend |
| [`wjp_rose()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_rose.md) | target, grouping, labels | order | cvec |
| [`wjp_slope()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_slope.md) | target, grouping | colors, labels | repel, show_legend |
| [`wjp_gauge()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_gauge.md) | target, colors | labels | factor_order, show_legend |
| [`wjp_lollipops()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lollipops.md) | target, grouping | labels, order | line_color, point_color |
| [`wjp_edgebars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_edgebars.md) | target, grouping | labels, x_lab_pos | bar_width |
| [`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md) | target, grouping, levels | labels, ci_lower + ci_upper or sd + sample_size (for CI) | group_order, level_order, draw_ci, show_national + national_value, national_style, national_ci_lower + national_ci_upper, show_axis, label_position |
