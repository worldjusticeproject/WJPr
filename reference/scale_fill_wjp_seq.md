# Sequential WJP Color Scales

**\[experimental\]**

`scale_fill_wjp_seq()` and `scale_colour_wjp_seq()` map a continuous
variable to a sequential scale between two WJP colors. The colors are
mixed linearly in RGB space, as in the cards and networks of WJP country
reports.

## Usage

``` r
scale_fill_wjp_seq(
  low = wjp_colors()[["card_low"]],
  high = wjp_colors()[["main"]],
  ...,
  na.value = "#ffffff",
  guide = "colourbar",
  aesthetics = "fill"
)

scale_colour_wjp_seq(
  low = wjp_colors()[["card_low"]],
  high = wjp_colors()[["main"]],
  ...,
  na.value = "#ffffff",
  guide = "colourbar",
  aesthetics = "colour"
)

scale_color_wjp_seq(
  low = wjp_colors()[["card_low"]],
  high = wjp_colors()[["main"]],
  ...,
  na.value = "#ffffff",
  guide = "colourbar",
  aesthetics = "colour"
)
```

## Arguments

- low, high:

  Colors of the low and high ends of the scale. Defaults to the report
  colors `card_low` and `main` (see
  [`wjp_colors()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_palette.md)).

- ...:

  Other arguments passed to
  [`ggplot2::continuous_scale()`](https://ggplot2.tidyverse.org/reference/continuous_scale.html),
  such as `name`, `limits`, `breaks`, and `labels`.

- na.value:

  Color for missing values.

- guide:

  Guide for the scale. Default is `"colourbar"`.

- aesthetics:

  Aesthetics the scale applies to.

## Value

A ggplot2 scale.

## Examples

``` r
library(ggplot2)

grid <- expand.grid(x = 1:5, y = 1:3)
grid$value <- seq(0, 100, length.out = nrow(grid))

ggplot(grid, aes(x, y, fill = value)) +
  geom_tile() +
  scale_fill_wjp_seq()

```
