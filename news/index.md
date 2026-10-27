# Changelog

## WJPr 1.2.0

This release closes the gaps found when drawing the 42 figures of the
*Paths to Justice* country report with WJPr. Every figure of that report
can now be drawn with WJPr arguments alone (ink similarity with the
published figures between 0.992 and 1.000; see `dev/report-fidelity.R`),
where WJPr 1.1.0 needed 5 to 13 code workarounds per figure.

### New chart functions

- [`wjp_funnel()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_funnel.md):
  centered funnel bars with connectors between stages.
- [`wjp_cards()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_cards.md):
  grid of rounded cards colored on a sequential scale, with a value and
  a difference (“+16 points”) per card; differences can be computed
  against the first card of each row or column (`ref`).
- [`wjp_heatmap()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_heatmap.md):
  tile matrix with categorical bands or a continuous fill, text colored
  by contrast, rotated top axis and axis titles.
- [`wjp_scatter()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_scatter.md):
  faceted scatter plot with highlighted and hollow points, an optional
  linear trend, and repelled labels (ggrepel, with a seed).
- [`wjp_network()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_network.md):
  network of nodes (filled by centrality or value) and weighted edges on
  fixed coordinates, with labels colored by contrast.
- [`wjp_upset()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_upset.md):
  UpSet diagram returned as a single ggplot (intersection bars,
  membership matrix, and set sizes).
- [`wjp_sankey()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_sankey.md):
  three-column sankey (first-level nodes, second-level nodes with a
  parent and an outcome, outcomes with notes) with rounded label boxes.

### Geometry, theme, fonts, colors, and export

- New
  [`wjp_layout()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_layout.md):
  the geometry of a chart in points (label column, 100% track, value
  column, row, bar, and header heights, inset, and margins).
  [`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md),
  [`wjp_bars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_bars.md),
  and
  [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md)
  accept it in a new `layout` argument; the chart then has fixed panel
  sizes and a definite size.
- [`WJP_theme()`](https://worldjusticeproject.github.io/WJPr/reference/WJP_theme.md)
  gains `base_size`, `text_colour`, `grid` (`"major"`, `"x"`, `"y"`,
  `"none"`), `grid_colour`, `grid_linetype`, and `base_theme`. The font
  family is also set on the root `text` element, so titles, legends, and
  strips inherit it.
- `ptheme` now takes precedence over the chart’s own styling: the
  elements of `ptheme` that differ from the default
  [`WJP_theme()`](https://worldjusticeproject.github.io/WJPr/reference/WJP_theme.md)
  are applied last in every chart function (for example,
  `ptheme = WJP_theme(base_size = 9)` resizes the axis labels). The
  default output is unchanged. Complete themes (including
  `WJP_theme(base_theme = )`) are used as the starting point instead.
- `wjp_fonts(engine = "systemfonts")` registers the static font files of
  Inter Tight and Lato with systemfonts instead of showtext, so devices
  write real text that can be converted to outlines, and every weight is
  available. Files are downloaded once from Google Fonts or read from
  `path`; they take precedence over fonts with the same name installed
  on the system. Text arguments accept the weight faces `"medium"`,
  `"semibold"` (and their `.italic` variants),
  e.g. `value_fontface = "semibold.italic"`.
- New
  [`wjp_save()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_save.md):
  writes SVG (with text converted to outlines), PNG (at `png_dpi`, with
  the same layout as the SVG), or PDF at an exact size; the size
  defaults to the definite size of charts drawn with a layout.
- New
  [`wjp_colors()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_palette.md)
  and `wjp_palette("report")`: the named colors of WJP country reports
  (`main`, `eu`, `eu_text`, `track`, `text`, …).
- New
  [`scale_fill_wjp_seq()`](https://worldjusticeproject.github.io/WJPr/reference/scale_fill_wjp_seq.md)
  and
  [`scale_colour_wjp_seq()`](https://worldjusticeproject.github.io/WJPr/reference/scale_fill_wjp_seq.md):
  sequential scales between two colors mixed in RGB space.
- New
  [`wjp_drawn()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_drawn.md):
  the texts (with position, size, font, and color) and marks that a
  chart draws, to verify a chart without rasterizing it.
- Shared legends gain position, direction, text size and face, key size,
  and justification arguments in
  [`wjp_bars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_bars.md)
  and
  [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md).

### Changes to existing functions

- [`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md):
  - `group_header = "row"` draws the chart in one panel with group
    titles as header rows in the label column (selected automatically
    with a `layout`).
  - `national_value` accepts several named values (e.g. National and EU
    averages), each drawn as a reference row; `national_value_label`
    sets their printed text.
  - `na_label` prints a text (e.g. “N/A”) for suppressed cells;
    `label_position = "column"` aligns the values after the track, with
    `value_gap` in points.
  - `scale_max` plots other scales (e.g. a 0-10 mean);
    `show_complement = FALSE` removes the gray track; `xlim` sets the
    value axis.
  - Text roles: `value_size`, `value_fontface`, `value_colour`,
    `label_size`, `label_colour`, `highlight_levels`,
    `highlight_fontface`, `highlight_colour`, `header_fontface`,
    `header_colour`, `header_size`.
  - Rich text is used only for highlighted labels, and plain theme
    overrides of `axis.text.y` now work with ggplot2 \>= 4.0.
- [`wjp_bars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_bars.md):
  - `position = "dodge"` draws series side by side (`dodge_width`,
    `series_reverse`); value labels and the new 100% `track` follow the
    bars.
  - `value_position` (`"end"`, `"outside"`, `"center"`, `"column"`) with
    `value_offset` in points, `value_size`, `value_fontface`, and
    `value_colors` per series.
  - `align = "center"` centers the bars; `limits` (use `NA` to scale to
    the data), `breaks`, `axis_labels`, `expand_mult`,
    `expand_discrete`.
  - `value_axis`, `grid`, `grid_color`, `ylab`, `baseline`, `ref_lines`,
    `clip`, `label_align`, `label_size`, `label_colour`, `label_wrap`,
    and `label_lineheight`.
  - Without `lab_pos`, labels of stacked segments now follow their
    segments
    ([`position_stack()`](https://ggplot2.tidyverse.org/reference/position_stack.html));
    previously they were placed at the segment value.
- [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md):
  - Categories may have a single value (the point and its label are
    drawn).
  - `headers` draws a header row above each group; `highlight_levels`
    styles rows such as a national average.
  - `legend_labels`, `legend_position`, `legend_direction`, `breaks`,
    `expand_mult`, `axis_line`, `value_axis`, `strips`, `strip_color`,
    `grid`, `grid_ontop`, `value_position = "outside"` with `value_gap`,
    `value_size`, `value_fontface`, `point_size`, `point_stroke`,
    `segment_color`, `segment_width`, `clip`, `label_align`,
    `label_size`, and `label_colour`.
- [`wjp_lollipops()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lollipops.md)
  gains `label_gap` (points), `label_hjust`, `points`, `label_size`,
  `label_fontface`, and `label_color`.
- [`wjp_edgebars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_edgebars.md)
  gains `label_position = "left"`, `value_labels` (printed as given),
  `axis`, `grid`, and `margins`.

### Testing

- Visual regression tests: a snapshot of the texts every chart function
  draws, in order (`tests/testthat/_snaps/visual-snapshots.md`).
- `dev/report-fidelity.R` draws the 42 figures of the report with WJPr
  arguments only and measures their similarity with the published
  figures; `tests/testthat/test-report-fidelity.R` runs it when
  `SRC_REPORTS_ROOT` points to the report pipeline.

### Other changes

- WJPr now requires ggplot2 \>= 3.5.0 (fixed panel sizes and dodge
  order).
- svglite, xml2, textshaping, ragg, and png are suggested for
  [`wjp_save()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_save.md).

### Names that differ from the gap analysis

The gap analysis proposed names per function; the implementation uses
one vocabulary for every chart: `value_*` for printed values, `label_*`
for category labels, and `header_*` for group titles. Where a proposal
differed:

| Proposed | Implemented |
|----|----|
| `wjp_groupbars(label_size, label_fontface)` for values | `value_size`, `value_fontface` |
| `wjp_groupbars(label_gap)` | `value_gap` |
| `wjp_groupbars(reference_rows)` | named `national_value` |
| `row_height`, `header_height`, `label_width`, `track_width` arguments | fields of [`wjp_layout()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_layout.md) |
| `wjp_bars(label_colors, label_face, label_size, label_position, label_offset)` | `value_colors`, `value_fontface`, `value_size`, `value_position`, `value_offset` |
| `wjp_bars(labels)` for axis labels, `scale_max = "data"` | `axis_labels`, `limits = c(0, NA)` |
| `wjp_dumbbells(label_face, label_size, label_side, label_gap)` | `value_fontface`, `value_size`, `value_position`, `value_gap` |
| `wjp_dumbbells(header_style, expand)` | `header_fontface`/`header_colour`/`header_size`, `expand_mult` |
| `attr(p, "wjp_drawn")` | `wjp_drawn(p)` |
| [`wjp_fonts()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_fonts.md) weights per role | weight faces such as `"semibold.italic"` |

### Edgebars

- [`wjp_edgebars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_edgebars.md)
  now supports 100% background tracks, highlighted categories, complete
  paired series, and precomputed confidence intervals. Paired rows
  receive direct series labels, including when highlighting makes bars
  neutral.
- Edgebars validate percentages, categories, ordering, colors, and
  confidence bounds; missing required data can explicitly omit whole
  categories. Internal plotting names no longer conflict with user
  columns, and a value column can also supply ordering.
- Edgebars use a fixed percentage scale and plain text by default.
  Automatic scaling and rich text are explicit options. Added label
  wrapping, formatting, aligned values, spacing controls, and positive
  margins. Legacy position arguments remain available as aliases. See
  `examples/edgebars.R` for six rendered examples and
  `examples/edgebars-audit.md` for visual audit results.

## WJPr 1.1.0

### New features

- New
  [`wjp_font_family()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_font_family.md)
  function and `wjpr.family` option: switch every WJPr chart and theme
  between the loaded font families (Lato by default, Inter Tight as
  alternative) with a single line, e.g.
  `options(wjpr.family = "Inter Tight")`.
  [`WJP_theme()`](https://worldjusticeproject.github.io/WJPr/reference/WJP_theme.md)
  also gains a `family` parameter.
- New
  [`wjp_palette()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_palette.md)
  function exposing the official WJP categorical color palette. All
  chart functions now fall back to this palette when no `cvec` is
  supplied, so charts stay on-brand by default (previously they fell
  back to the default ggplot2 hues).
- New
  [`spread_labels_x()`](https://worldjusticeproject.github.io/WJPr/reference/spread_labels_x.md)
  helper: a deterministic solver that spreads overlapping value labels
  horizontally in row-based point charts (e.g.
  [`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md),
  [`wjp_lollipops()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lollipops.md))
  while keeping every point at its true value. Labels stay on a single
  row, move by the minimum amount needed, are kept inside the panel
  limits, and produce reproducible output.
- [`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md)
  gains `show_labels`, `labels`, and `label_offset`: value labels can be
  drawn above each point and are spread horizontally with
  [`spread_labels_x()`](https://worldjusticeproject.github.io/WJPr/reference/spread_labels_x.md)
  so near-equal series do not collide. Identical labels within a row are
  collapsed to a single mark and points are never moved.
- [`wjp_lines()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lines.md)
  and
  [`wjp_slope()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_slope.md)
  no longer require the `ngroups` parameter: lines are grouped by the
  `colors` variable automatically. Both functions also work without
  `colors` (a single series is drawn).
- [`wjp_slope()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_slope.md)
  accepts time points stored as text (e.g., `"2019"`) and converts them
  to numbers.
- [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md)
  gains an alternating strip background (visual consistency with
  [`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md)),
  automatic label positions when `labpos` is not supplied, and support
  for named `cvec` vectors matched against `cgroups`.
- [`wjp_lollipops()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lollipops.md)
  gains `labels`, `order`, and `ptheme` parameters. Value labels are
  generated automatically when `labels` is not supplied.
- [`wjp_edgebars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_edgebars.md)
  `labels` parameter is now optional and defaults to the `grouping`
  values.
- [`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md)
  automatically enables per-group opacities and shapes when `opacities`
  or `shapes` are supplied.
- [`wjp_divbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_divbars.md)
  enables custom ordering automatically when `order` is supplied.
- [`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md)
  accepts the original `national_var` value in `group_order` and
  `level_order`.
- [`wjp_check_data()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_data.md)
  gains support for `type = "groupbars"`.

### Parameter harmonization and deprecations

- [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md):
  `color` was renamed to `colors`.
- [`wjp_radar()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_radar.md)
  and
  [`wjp_rose()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_rose.md):
  `order_var` was renamed to `order`.
- [`wjp_lines()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lines.md)
  and
  [`wjp_slope()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_slope.md):
  `ngroups` is deprecated (lines are grouped by `colors`).
- [`wjp_divbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_divbars.md):
  `custom_order` is deprecated (supplying `order` is enough).
- The old argument names still work but now signal a soft deprecation
  through the lifecycle package.

### Bug fixes

- Fixed a bug in
  [`wjp_gauge()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_gauge.md)
  where the invisible padding segment received a visible palette color
  when no `cvec` was supplied, drawing a full circle instead of a
  semicircle.
- [`wjp_gauge()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_gauge.md)
  now hides labels of segments smaller than 5% of the total, as
  documented. Previously the raw value was compared with 5, which hid
  every label when values were proportions.
- [`wjp_edgebars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_edgebars.md)
  value labels are no longer padded with leading spaces (e.g., `" 5%"`).
- [`spread_labels_x()`](https://worldjusticeproject.github.io/WJPr/reference/spread_labels_x.md)
  no longer opens a graphics device (leaving a stray `Rplots.pdf`) when
  sizing gaps from `labels` with absolute units.
- Fixed a bug in
  [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md)
  where the `order` parameter was ignored.
- [`wjp_divbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_divbars.md)
  reports a missing `order` column instead of silently ignoring it.
- [`diffmeans()`](https://worldjusticeproject.github.io/WJPr/reference/diffmeans.md)
  now returns its results explicitly (previously the value was returned
  invisibly) and validates `type` and `t` with clear errors.
- [`wjp_radar()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_radar.md)
  validates `source` (case-insensitive), so `"gpp"` no longer draws
  percentages on the 0-1 scale.
- [`wjp_lines()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lines.md)
  gives a clear error when `transparency = TRUE` is used without
  `transparencies`, and
  [`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md)
  does the same when `diffOpac` or `diffShp` are set without `opacities`
  or `shapes`.
- [`wjp_lines()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lines.md)
  value labels no longer get clipped when values are close to 100%: the
  label flips below the point instead.

### Package infrastructure

- Package, site, and issue-template URLs now point to the renamed
  `worldjusticeproject` GitHub organization; the documentation site
  lives at <https://worldjusticeproject.github.io/WJPr/> (the previous
  `worldjusticeproject-org.github.io` address returned a 404).
- `grDevices` moved from `Suggests` to `Imports` (it was already
  imported).
- Removed the unused `glue` dependency and 35 unused `@importFrom`
  declarations.
- `CODEOWNERS` updated to the current maintainer.
- [`wjp_check_deps()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_check_deps.md)
  lists `purrr` as a core dependency and `systemfonts` as an optional
  one, with corrected feature descriptions.

### Documentation

- Expanded the reference documentation of every chart function with a
  “Details” section describing the expected data structure and
  additional worked examples (stacked bars, confidence intervals in dots
  charts, highlighted lines, custom ordering, Rule of Law Index radar,
  and more).
- The `gpp` and `roli` dataset documentation now lists the actual
  columns (`q1a`-`q1f`, the `q49*_G1`/`_G2` items, `code`, `region`) and
  explains how to work with the labelled survey answers.
- Contributor documentation (CONTRIBUTING, review checklist, development
  articles) translated to English and updated to the current function
  pattern (WJP palette fallback,
  [`wjp_font_family()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_font_family.md)).
- Reference-page figures are now rendered with
  [`grDevices::png`](https://rdrr.io/r/grDevices/png.html) so rich text
  labels (ggtext) keep correct word spacing with the WJP fonts.

### Visual consistency

- Value labels now share the same typography across all charts (Lato
  bold, 10 pt, ink `#4a4a49`).
- Value-axis grid lines in bar, line, and lollipop charts harmonized to
  a single light gray (`#d1cfd1`); dot and dumbbell charts keep the
  dashed
  [`WJP_theme()`](https://worldjusticeproject.github.io/WJPr/reference/WJP_theme.md)
  grid drawn over their row strips.
- Category axis text harmonized (`#524F4C`, left-aligned) across
  horizontal charts.
- Horizontal charts
  ([`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md),
  [`wjp_dumbbells()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dumbbells.md),
  [`wjp_lollipops()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_lollipops.md),
  [`wjp_edgebars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_edgebars.md))
  now consistently display the first row of the data at the top of the
  chart.
- [`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md):
  when confidence intervals are drawn, value labels are now placed at
  the end of the full bar (after the gray complement), aligned in a
  single column, instead of next to the upper interval whisker.
- [`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md):
  `strip_position = "top"` in single-column layouts now renders group
  titles as horizontal headers above each group instead of rotated (and
  clipped) strips on the right.

## WJPr 1.0.1

- Updated
  [`wjp_groupbars()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_groupbars.md)
  documentation and gallery images to show the corrected grouped-bar
  layout with neutral complement bars, confidence intervals, a national
  bar, and an optional percentage axis.

## WJPr 1.0.0

- Fixed bugs preventing
  [`wjp_radar()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_radar.md)
  to plot specific data structures.
- Fixed bugs preventing
  [`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md)
  to plot specific data structures.
- Change the way that
  [`wjp_dots()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_dots.md)
  calculated and added Confidence Intervals to charts.
- [`wjp_slope()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_slope.md)
  added.
- [`diffmeans()`](https://worldjusticeproject.github.io/WJPr/reference/diffmeans.md)
  added.

## WJPr 0.0.0

- Initial base release
