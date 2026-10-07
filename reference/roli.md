# Rule of Law Index Historical Data

Index scores at country-year level for all factors and subfactors from
2012 to 2024. Scores range from 0 to 1, where higher values indicate
stronger adherence to the rule of law.

## Usage

``` r
roli
```

## Format

### `roli`

A tibble with 1,341 rows and 57 columns:

- country:

  Country name

- year:

  Year of measurement (2012-2024)

- code:

  Three-letter ISO country code

- region:

  WJP region

- roli:

  Overall Rule of Law Index Score (0-1)

- f1:

  Factor 1: Constraints on Government Powers

- f2:

  Factor 2: Absence of Corruption

- f3:

  Factor 3: Open Government

- f4:

  Factor 4: Fundamental Rights

- f5:

  Factor 5: Order and Security

- f6:

  Factor 6: Regulatory Enforcement

- f7:

  Factor 7: Civil Justice

- f8:

  Factor 8: Criminal Justice

- sf11, sf12, ...:

  Subfactor scores (e.g., sf11 = Subfactor 1.1)

## Source

<https://worldjusticeproject.org/>
