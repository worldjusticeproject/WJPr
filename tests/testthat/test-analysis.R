test_that("diffmeans returns one tidy table per grouping variable", {
  set.seed(1)
  survey <- data.frame(
    country = rep(c("Atlantis", "Narnia"), each = 100),
    female  = rep(c(0, 1), 100),
    trust   = rbinom(200, 1, 0.5)
  )

  results <- diffmeans(
    data        = survey,
    target_vars = "trust",
    group_vars  = "female",
    geo_var     = "country"
  )

  expect_named(results, "female")
  expect_s3_class(results$female, "data.frame")
  expect_true(all(c("variable", "geovar", "mean_A", "mean_B", "diff",
                    "stat", "p_value", "stat_sig") %in% names(results$female)))
  expect_equal(nrow(results$female), 2)
  expect_equal(results$female$diff, results$female$mean_A - results$female$mean_B)

  uncollapsed <- diffmeans(survey, "trust", "female", "country", collapse = FALSE)
  expect_named(uncollapsed$female, "trust")
})

test_that("diffmeans validates the test type and threshold", {
  survey <- data.frame(geo = "A", g = c(0, 1, 0, 1), y = c(1, 0, 1, 1))
  expect_error(diffmeans(survey, "y", "g", "geo", type = "foo"), "`type`")
  expect_error(diffmeans(survey, "y", "g", "geo", t = 5), "`t`")
})

test_that("wjp_check_data reports valid and invalid structures", {
  sample_data <- data.frame(
    country = c("Atlantis", "Narnia"),
    trust   = c(45.2, 38.1)
  )

  ok <- wjp_check_data(sample_data, "bars", "trust", grouping = "country",
                       verbose = FALSE)
  expect_true(ok$valid)
  expect_length(ok$errors, 0)

  bad <- wjp_check_data(sample_data, "bars", "missing", verbose = FALSE)
  expect_false(bad$valid)
  expect_match(bad$errors, "missing", all = FALSE)

  out_of_range <- wjp_check_data(
    transform(sample_data, trust = c(45, 145)), "bars", "trust", verbose = FALSE
  )
  expect_true(out_of_range$valid)
  expect_match(out_of_range$warnings, "0-100", all = FALSE)

  expect_false(wjp_check_data(sample_data, "pie", "trust", verbose = FALSE)$valid)
  expect_output(valid <- wjp_check_data(sample_data, "bars", "trust"), "valid")
  expect_true(valid)
})

test_that("wjp_check_deps returns the dependency status invisibly", {
  status <- wjp_check_deps(quiet = TRUE)
  expect_named(status, c("core", "optional"))
  expect_true(all(c("ggplot2", "dplyr", "purrr") %in% names(status$core)))
  expect_type(status$optional, "logical")
})
