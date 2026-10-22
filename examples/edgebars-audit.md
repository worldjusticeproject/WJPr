# Edgebars visual audit

An independent audit agent inspected the rendered PNGs after the visual fixes,
using the export dimensions in `edgebars.R` (8 inches wide, 150 dpi).

| Chart | Export height | Result |
| --- | --- | --- |
| `edgebars.png` | 5.5 inches | Pass: category headings clear the bars; end values and caption are readable and unclipped. |
| `edgebars_track.png` | 5.5 inches | Pass: equal-length 100% tracks are visible; values remain readable over the pale track. |
| `edgebars_highlight.png` | 5.5 inches | Pass: courts are clearly emphasized; aligned decimal values have adequate right-hand clearance. |
| `edgebars_paired.png` | 7 inches | Pass: each pair is separated; year labels, legend, category headings, and aligned values are readable. |
| `edgebars_ci.png` | 5.5 inches | Pass: interval lines are visible against violet bars; values follow the upper bounds without collisions. |
| `edgebars_combined.png` | 8 inches | Pass: the wrapped courts heading clears its pair; direct year labels identify neutral pairs; intervals and values do not overlap. |

The first inspection identified exposed internal row coordinates, gridlines
crossing labels, ambiguous series identification for neutral pairs, and weak
confidence-interval contrast. The regenerated images resolve these findings.
Numeric axes are intentionally hidden in this chart style.

Additional temporary renderings checked 0%, 100%, and 50% estimates with
confidence intervals and a two-line category heading, using both plain text and
rich text at 8 by 5 inches. Both passed: the labels, interval caps, and 100% end
value remained visible and clear of neighboring elements.

These results apply to the inspected dimensions and labels. More categories,
larger text, longer series names, or smaller export sizes require renewed visual
inspection and potentially more height or adjusted wrapping.
