#' GPP Sample Data
#'
#' A subset of data from the original General Population Poll (GPP).
#' Countries have been renamed into three fictional countries (Atlantis,
#' Narnia, Neverland) observed in three survey years.
#'
#' Survey answers are stored as labelled vectors (`haven_labelled`, from
#' the haven package). Convert them to plain numbers before computing
#' indicators, e.g. `as.double(unclass(q1a))`.
#'
#' @format ## `gpp`
#' A tibble with 750 rows and 19 columns:
#' \describe{
#'   \item{country}{Country name (Atlantis, Narnia, or Neverland)}
#'   \item{year}{Survey year (2017, 2019, or 2022)}
#'   \item{gend}{Sex of respondent (1 = Male, 2 = Female)}
#'   \item{age}{Age of respondent}
#'   \item{q1a, q1b, q1c, q1d, q1e, q1f}{Trust in institutions A to F
#'     (1 = A lot, 2 = Some, 3 = A little, 4 = No trust,
#'     99 = Don't know/No answer)}
#'   \item{q49a, q49b_G1, q49b_G2, q49c_G1, q49c_G2, q49d_G1, q49d_G2,
#'     q49e_G1, q49e_G2}{Confidence in different attributes of the criminal
#'     justice system (1 = Very confident, 2 = Fairly confident,
#'     3 = Not very confident, 4 = Not at all confident,
#'     99 = Don't know/No answer). Items with the `_G1` and `_G2` suffixes
#'     are question variants asked to different subsamples, and most 2017
#'     respondents were not asked this battery, so these columns contain
#'     many `NA` values.}
#' }
#'
#' @source \url{https://worldjusticeproject.org/}
"gpp"

#' Rule of Law Index Historical Data
#'
#' Index scores at country-year level for all factors and subfactors
#' from 2012 to 2024. Scores range from 0 to 1, where higher values indicate
#' stronger adherence to the rule of law.
#'
#' @format ## `roli`
#' A tibble with 1,341 rows and 57 columns:
#' \describe{
#'   \item{country}{Country name}
#'   \item{year}{Year of measurement (2012-2024)}
#'   \item{code}{Three-letter ISO country code}
#'   \item{region}{WJP region}
#'   \item{roli}{Overall Rule of Law Index Score (0-1)}
#'   \item{f1}{Factor 1: Constraints on Government Powers}
#'   \item{f2}{Factor 2: Absence of Corruption}
#'   \item{f3}{Factor 3: Open Government}
#'   \item{f4}{Factor 4: Fundamental Rights}
#'   \item{f5}{Factor 5: Order and Security}
#'   \item{f6}{Factor 6: Regulatory Enforcement}
#'   \item{f7}{Factor 7: Civil Justice}
#'   \item{f8}{Factor 8: Criminal Justice}
#'   \item{sf11, sf12, ...}{Subfactor scores (e.g., sf11 = Subfactor 1.1)}
#' }
#'
#' @source \url{https://worldjusticeproject.org/}
"roli"
