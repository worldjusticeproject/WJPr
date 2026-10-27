# Save a WJP Chart at Its Exact Size

**\[experimental\]**

`wjp_save()` writes a chart to an SVG, PNG, or PDF file at an exact
physical size. SVG files can have their text converted to outlines
(`outline_text = TRUE`), so the figure looks the same on machines
without the fonts, and PNG files are rendered at `png_dpi` dots per
inch.

## Usage

``` r
wjp_save(
  plot,
  file,
  width = NULL,
  height = NULL,
  units = c("in", "cm", "mm", "pt", "px"),
  outline_text = TRUE,
  png_dpi = 300,
  bg = "white"
)
```

## Arguments

- plot:

  A ggplot object.

- file:

  Path of the output file (`.svg`, `.png`, or `.pdf`).

- width, height:

  Size of the figure in `units`. Default is `NULL` (the definite size of
  the chart).

- units:

  Units of `width` and `height`: `"in"` (default), `"cm"`, `"mm"`,
  `"pt"` (1/72 inch), or `"px"` (pixels at `png_dpi`).

- outline_text:

  Logical. Convert the text of SVG files to outlines. Default is `TRUE`.

- png_dpi:

  Numeric. Resolution of PNG files. Default is `300`.

- bg:

  Background color. Default is `"white"`.

## Value

Invisibly, a list with the `file`, its `width` and `height` in inches
and, for outlined SVG files, a data frame `text` with one row per
outlined text (`text`, `family`, `size`, `weight`, `italic`,
`font_file`, `doubtful`; `doubtful` flags texts whose width in the SVG
differs by more than 3% from the font, a sign that they were measured
with another font).

## Details

The output format follows the extension of `file`:

- `.svg`: written with svglite. With `outline_text = TRUE`, every
  `<text>` element is replaced by a `<path>` with the outlines of its
  glyphs, read from the font files with systemfonts and shaped with
  textshaping. Requires the packages svglite, xml2, systemfonts, and
  textshaping.

- `.png`: written with
  [`ragg::agg_png()`](https://ragg.r-lib.org/reference/agg_png.html)
  when ragg is installed (otherwise with
  [`grDevices::png()`](https://rdrr.io/r/grDevices/png.html)) at
  `png_dpi`.

- `.pdf`: written with
  [`grDevices::cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html).

Fonts: text outlines and the SVG and PNG devices read fonts through
systemfonts. Register the WJP fonts with
`wjp_fonts(engine = "systemfonts")` for exact results. When showtext is
active and the families of the chart are only known to showtext (the
default
[`wjp_fonts()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_fonts.md)),
the chart is drawn with showtext, which already renders text as
polygons; `outline_text` then has no further effect.

Size: when `width` or `height` is `NULL`, the size of the chart is used
if it is definite, i.e. when its panels have a fixed size (charts drawn
with a
[`wjp_layout()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_layout.md),
or plots with the `panel.widths` and `panel.heights` theme elements).

## See also

[`wjp_layout()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_layout.md)
for charts with a definite size.

## Examples

``` r
if (FALSE) { # \dontrun{
wjp_fonts(engine = "systemfonts")
p <- wjp_bars(
  data.frame(country = c("A", "B"), value = c(40, 60)),
  target = "value", grouping = "country"
)
wjp_save(p, "bars.svg", width = 6, height = 4)
wjp_save(p, "bars.png", width = 6, height = 4, png_dpi = 300)
} # }
```
