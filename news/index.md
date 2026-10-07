# Changelog

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
