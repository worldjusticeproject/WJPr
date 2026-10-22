# Edgebars examples

From the repository root, run:

```sh
Rscript --vanilla examples/edgebars.R
```

The script loads the local package through `pkgload`, uses a portable system
font, and saves six charts. All numbers are fictional.

| Example | Image | Main arguments |
| --- | --- | --- |
| Basic percentage bars | [Preview](edgebars.png) | `target`, `grouping`, `labels` |
| 100% background tracks | [Preview](edgebars_track.png) | `background_track = TRUE` |
| Highlighted category | [Preview](edgebars_highlight.png) | `highlight = "Courts"`, `sort = "descending"` |
| Paired bars | [Preview](edgebars_paired.png) | `series = "year"`, named `cvec` |
| Confidence intervals | [Preview](edgebars_ci.png) | `ci_lower = "lower"`, `ci_upper = "upper"` |
| All four features together | [Preview](edgebars_combined.png) | Tracks, highlight, series, bounds, wrapped labels |

Each plot has its own code block and object in [edgebars.R](edgebars.R).
Paired data require exactly one observation for each of two series in every
category. Confidence bounds must already be calculated, enclose the estimate,
and use the same 0–100 scale. The chart does not calculate survey intervals.

The new default is a fixed percentage scale and plain-text labels. Use
`scale = "auto"` for the previous automatic scaling behavior, or
`label_style = "rich"` with `ggtext` for HTML labels. Plain labels wrap with
`label_wrap`; rich labels use explicit `<br>` breaks. The legacy `x_lab_pos`
and `y_lab_pos` arguments remain available as aliases for `order` and
`label_start`. Do not supply both an alias and its replacement.

Use `accuracy` or `label_format` for value text, `value_position = "column"`
for aligned values, and `show_values = FALSE` to hide values. Missing required
data raise an error unless `na_action = "omit"`; omission removes the entire
affected category, including both rows of a pair.

Export height should grow with the number of categories and wrapped lines.
The independent [visual audit](edgebars-audit.md) records the inspected sizes
and results.
