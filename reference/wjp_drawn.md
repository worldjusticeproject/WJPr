# Texts and Marks Drawn by a Chart

**\[experimental\]**

`wjp_drawn()` builds a chart and returns what it draws as a data frame,
so the printed texts, their positions, and their fonts can be checked
without rasterizing the figure (for example in tests, or to compare a
chart with a published table).

## Usage

``` r
wjp_drawn(plot, what = c("text", "marks"))
```

## Arguments

- plot:

  A ggplot object.

- what:

  `"text"` (default) or `"marks"`.

## Value

A data frame. For `what = "text"`: `source` (`"layer"`, `"axis-x"`,
`"axis-y"`, or `"strip"`), `layer`, `PANEL`, `label`, `x`, `y`,
`colour`, `size` (points), `family`, `fontface`, `hjust`, and `vjust`.
For `what = "marks"`: `layer`, `geom`, and the computed columns.

## Details

With `what = "text"`, one row per text: labels of the text layers
([`geom_text()`](https://ggplot2.tidyverse.org/reference/geom_text.html),
[`geom_label()`](https://ggplot2.tidyverse.org/reference/geom_text.html),
ggtext and ggrepel layers), axis labels, and facet strip labels.
Rich-text markup (`<b>`, `<span>`, ...) is removed from `label`. Text
layers report their position in data coordinates and their size in
points.

With `what = "marks"`, one row per mark of every non-text layer (bars,
points, segments, polygons), with the columns that the layer computes
(`x`, `y`, `xmin`, `xmax`, `ymin`, `ymax`, `fill`, `colour`, ...).

## Examples

``` r
p <- wjp_bars(
  data.frame(country = c("A", "B"), value = c(40, 60), lab = c("40%", "60%")),
  target = "value", grouping = "country", labels = "lab"
)
wjp_drawn(p)
#>    source layer PANEL label         x           y  colour size    family
#> 1   layer     2     1   40% 1.0000000 40.00000000 #4a4a49   10 Lato Full
#> 2   layer     2     1   60% 2.0000000 60.00000000 #4a4a49   10 Lato Full
#> 3  axis-x    NA     1     A 0.2727273          NA    <NA>   NA      <NA>
#> 4  axis-x    NA     1     B 0.7272727          NA    <NA>   NA      <NA>
#> 5  axis-y    NA     1    0%        NA  0.04545455    <NA>   NA      <NA>
#> 6  axis-y    NA     1   20%        NA  0.21074380    <NA>   NA      <NA>
#> 7  axis-y    NA     1   40%        NA  0.37603306    <NA>   NA      <NA>
#> 8  axis-y    NA     1   60%        NA  0.54132231    <NA>   NA      <NA>
#> 9  axis-y    NA     1   80%        NA  0.70661157    <NA>   NA      <NA>
#> 10 axis-y    NA     1  100%        NA  0.87190083    <NA>   NA      <NA>
#>    fontface hjust vjust
#> 1      bold   0.5   0.5
#> 2      bold   0.5   0.5
#> 3      <NA>  <NA>  <NA>
#> 4      <NA>  <NA>  <NA>
#> 5      <NA>  <NA>  <NA>
#> 6      <NA>  <NA>  <NA>
#> 7      <NA>  <NA>  <NA>
#> 8      <NA>  <NA>  <NA>
#> 9      <NA>  <NA>  <NA>
#> 10     <NA>  <NA>  <NA>
```
