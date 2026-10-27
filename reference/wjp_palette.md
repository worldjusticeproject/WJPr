# WJP Color Palettes

`wjp_palette()` returns the color palettes used across World Justice
Project visualizations, and `wjp_colors()` returns them as named
vectors. All WJPr chart functions fall back to the categorical palette
when no color vector (`cvec`) is supplied, so charts stay on-brand by
default.

## Usage

``` r
wjp_palette(n = NULL, palette = c("categorical", "report"))

wjp_colors(palette = c("report", "categorical"))
```

## Arguments

- n:

  Integer. Number of colors to return. If `NULL` (default), the full
  palette is returned. For convenience, a palette name can be passed as
  the first argument, e.g. `wjp_palette("report")`.

- palette:

  String. `"categorical"` (default) or `"report"`.

## Value

A character vector of hex color codes. `wjp_colors()` and the report
palette return named vectors.

## Details

The **categorical** palette contains nine colors, ordered so that the
first three (violet, teal-blue, orange) provide maximum contrast for
small categorical sets, followed by the Rule of Law Index factor colors:

|       |           |                     |
|-------|-----------|---------------------|
| Order | Hex code  | Name                |
| 1     | `#482d8b` | `violet` (primary)  |
| 2     | `#2894aa` | `teal` (secondary)  |
| 3     | `#f26b21` | `orange` (contrast) |
| 4     | `#137b3f` | `green`             |
| 5     | `#869d3b` | `olive`             |
| 6     | `#0f9581` | `teal_green`        |
| 7     | `#1a74b6` | `blue`              |
| 8     | `#8f2e8c` | `magenta`           |
| 9     | `#555659` | `gray` (neutral)    |

The **report** palette holds the colors of the WJP country reports
(e.g., *Paths to Justice*), named by role:

|             |           |                                               |
|-------------|-----------|-----------------------------------------------|
| Name        | Hex code  | Usage                                         |
| `main`      | `#575796` | Country series, headers, averages             |
| `eu`        | `#A8A8C8` | Comparison series (EU Average)                |
| `eu_text`   | `#7D7DA8` | Text of the comparison series                 |
| `track`     | `#E5E8E8` | 100% background track                         |
| `text`      | `#1A1A1A` | Body text                                     |
| `highlight` | `#B200AA` | Second series of perception/experience charts |
| `grid`      | `#D0D1D3` | Grid lines                                    |
| `node`      | `#8E9393` | Neutral nodes (sankey)                        |
| `excluded`  | `#C4C8C8` | Excluded flows (sankey)                       |
| `box`       | `#F2F3F3` | Note boxes                                    |
| `note`      | `#7D7DA8` | Notes                                         |
| `delta`     | `#4B4B7A` | Differences between cards                     |
| `card_low`  | `#ECECF4` | Low end of the sequential scale               |

When more categorical colors are requested than the palette holds, the
palette is interpolated with
[`grDevices::colorRampPalette()`](https://rdrr.io/r/grDevices/colorRamp.html).

## See also

[`scale_fill_wjp_seq()`](https://worldjusticeproject.github.io/WJPr/reference/scale_fill_wjp_seq.md)
for the sequential report scale.

## Examples

``` r
# Full palette
wjp_palette()
#> [1] "#482d8b" "#2894aa" "#f26b21" "#137b3f" "#869d3b" "#0f9581" "#1a74b6"
#> [8] "#8f2e8c" "#555659"

# First three colors for a small categorical set
wjp_palette(3)
#> [1] "#482d8b" "#2894aa" "#f26b21"

# Report colors, by role
wjp_palette("report")
#>      main        eu   eu_text     track      text highlight      grid      node 
#> "#575796" "#A8A8C8" "#7D7DA8" "#E5E8E8" "#1A1A1A" "#B200AA" "#D0D1D3" "#8E9393" 
#>  excluded       box      note     delta  card_low 
#> "#C4C8C8" "#F2F3F3" "#7D7DA8" "#4B4B7A" "#ECECF4" 
wjp_colors()[["main"]]
#> [1] "#575796"
```
