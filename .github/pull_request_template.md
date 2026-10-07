## Summary

Brief description of changes.

## Type of Change

- [ ] Bug fix
- [ ] New feature (new chart function)
- [ ] Enhancement (improvement to existing function)
- [ ] Documentation update
- [ ] Other: ___________

## Changes Made

- Change 1
- Change 2
- Change 3

## Screenshot

<!-- For visual changes, include before/after screenshots -->
| Before | After |
|--------|-------|
| N/A    | ![screenshot](url) |

## Checklist

### Code
- [ ] Function follows WJPr naming conventions (`wjp_*`)
- [ ] Parameters use standard names (`target`, `grouping`, `colors`, `cvec`, etc.)
- [ ] NULL parameters handled correctly
- [ ] No duplicate column renames when parameters match
- [ ] Uses `all_of()` for column selection
- [ ] Falls back to the WJP palette when `cvec` is NULL
- [ ] Text layers use `wjp_font_family()`
- [ ] Returns ggplot object

### Documentation
- [ ] Roxygen2 documentation complete
- [ ] `@export` tag present
- [ ] `lifecycle::badge()` in description
- [ ] `@examples` section with reproducible code
- [ ] All parameters documented with type

### Testing
- [ ] Tests added in `tests/testthat/`
- [ ] Example runs without errors
- [ ] `devtools::check()` passes
- [ ] `devtools::document()` run

### Files Updated
- [ ] New file named `{type}Chart.R`
- [ ] Example image added to `man/figures/`
- [ ] `data-raw/generate-examples.R` updated
- [ ] `_pkgdown.yml` updated (navbar and reference index)
- [ ] `NEWS.md` entry added
- [ ] `CLAUDE.md` updated with new function

## Related Issues

Fixes #___

## Additional Notes

Any additional context for reviewers.
