# Chart Geometry in Points

**\[experimental\]**

`wjp_layout()` describes the geometry of a chart in points (1/72 inch),
the unit of print layouts. Pass it to the `layout` argument of
[`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md),
[`wjp_bars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_bars.md),
or
[`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md)
to fix the label column, the 100% track, the row and header heights, and
the margins, so the chart keeps the same measurements whatever the size
of the device.

## Usage

``` r
wjp_layout(
  label_width = NULL,
  label_gap = NULL,
  track_width = NULL,
  value_gap = NULL,
  value_width = NULL,
  row_height = NULL,
  bar_height = NULL,
  header_height = NULL,
  header_baseline = NULL,
  inset = NULL,
  margins = NULL
)
```

## Arguments

- label_width:

  Width of the label column.

- label_gap:

  Gap between the label column and the start of the bars.

- track_width:

  Width of a full (100%) bar.

- value_gap:

  Gap between the end of the track (or of the bar) and the value labels.

- value_width:

  Width reserved for the value labels.

- row_height:

  Height of a data row (the pitch from one bar to the next).

- bar_height:

  Height of a bar within its row.

- header_height:

  Height of a group header row.

- header_baseline:

  Baseline of the header text, measured from the top of its row.

- inset:

  Space between the edges of the panel and the first and last rows: one
  value, or two values (top, bottom). Used by
  [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md)
  and
  [`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md)
  (row mode).

- margins:

  Outer margins: one value, or four values in the order top, right,
  bottom, left.

## Value

An object of class `wjp_layout` (a named list of numbers in points).

## Details

With a layout, the chart is drawn with fixed panel sizes (see the
`panel.widths` and `panel.heights` theme elements of ggplot2 \>= 3.5.0)
and its category labels are drawn as text layers in the label column, so
no measurement of the text is needed. The resulting plot has a definite
size, stored in `attr(plot, "wjp_size")` (inches), which
[`wjp_save()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_save.md)
uses when no `width` or `height` is given. Saving a plot with a layout
at another size centers it on the canvas without changing its
measurements.

Every argument is optional: the chart functions use their own defaults
(those of WJP country reports) for the values left as `NULL`.

A horizontal chart with a layout is organized as follows, from left to
right: `margins[4]`, the label column (`label_width`), `label_gap`, the
track (`track_width`, 0 to 100%), `value_gap`, the value column
(`value_width`), and `margins[2]`.

## See also

[`wjp_save()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_save.md)
to export a chart at its exact size.

## Examples

``` r
# Geometry of the grouped bars of WJP country reports
report <- wjp_layout(
  label_width = 149, label_gap = 6, track_width = 250,
  value_gap = 5, value_width = 27,
  row_height = 15.5, bar_height = 13.5,
  header_height = 22, header_baseline = 17,
  margins = c(2, 0, 4, 0)
)
report
#> <wjp_layout> (points)
#>   label_width     149
#>   label_gap       6
#>   track_width     250
#>   value_gap       5
#>   value_width     27
#>   row_height      15.5
#>   bar_height      13.5
#>   header_height   22
#>   header_baseline 17
#>   margins         2 0 4 0
```
