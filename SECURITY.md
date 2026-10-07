# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.1.x   | ✅        |
| \< 1.1  | ❌        |

## Reporting a Vulnerability

If you discover a security vulnerability in WJPr, please report it by:

1.  **DO NOT** open a public issue
2.  Email the maintainer (<data-analytics@worldjusticeproject.org>) with
    details
3.  Include steps to reproduce the vulnerability
4.  Allow reasonable time for a fix before public disclosure

## Security Considerations

WJPr is a visualization package that:

- Does not make network requests (except for font loading via
  `sysfonts`)
- Does not execute arbitrary code
- Does not write files outside of user-specified locations
- Does not collect or transmit user data

### Font Loading

The
[`wjp_fonts()`](https://worldjusticeproject.github.io/WJPr/reference/wjp_fonts.md)
function downloads fonts from Google Fonts using the `sysfonts` package.
This requires an internet connection and trusts Google’s font servers.

### Data Handling

All data processing happens locally in R. The package does not send data
externally or store data persistently.
