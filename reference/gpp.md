# GPP Sample Data

A subset of data from the original General Population Poll (GPP).
Countries have been renamed into three fictional countries (Atlantis,
Narnia, Neverland) observed in three survey years.

## Usage

``` r
gpp
```

## Format

### `gpp`

A tibble with 750 rows and 19 columns:

- country:

  Country name (Atlantis, Narnia, or Neverland)

- year:

  Survey year (2017, 2019, or 2022)

- gend:

  Sex of respondent (1 = Male, 2 = Female)

- age:

  Age of respondent

- q1a, q1b, q1c, q1d, q1e, q1f:

  Trust in institutions A to F (1 = A lot, 2 = Some, 3 = A little, 4 =
  No trust, 99 = Don't know/No answer)

- q49a, q49b_G1, q49b_G2, q49c_G1, q49c_G2, q49d_G1, q49d_G2, q49e_G1,
  q49e_G2:

  Confidence in different attributes of the criminal justice system (1 =
  Very confident, 2 = Fairly confident, 3 = Not very confident, 4 = Not
  at all confident, 99 = Don't know/No answer). Items with the `_G1` and
  `_G2` suffixes are question variants asked to different subsamples,
  and most 2017 respondents were not asked this battery, so these
  columns contain many `NA` values.

## Source

<https://worldjusticeproject.org/>

## Details

Survey answers are stored as labelled vectors (`haven_labelled`, from
the haven package). Convert them to plain numbers before computing
indicators, e.g. `as.double(unclass(q1a))`.
