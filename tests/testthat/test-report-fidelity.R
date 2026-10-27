# Visual fidelity against the published figures of a WJP country report.
#
# The 42 figures of the Paths to Justice report (Hungary) are drawn with WJPr
# arguments only (dev/report-fidelity.R) and compared with the published PNGs
# (ink f1 at 96 dpi). The reference data and figures live in the report
# pipeline, outside this package, so the test runs only when SRC_REPORTS_ROOT
# points to that folder and the development scripts are available (they are
# not part of the built package):
#
#   SRC_REPORTS_ROOT=<path to src_reports> Rscript -e 'devtools::test(filter = "report-fidelity")'

test_that("report figures drawn with WJPr match the published figures", {
  root <- Sys.getenv("SRC_REPORTS_ROOT")
  skip_if(!nzchar(root), "SRC_REPORTS_ROOT is not set")
  repo <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
  skip_if_not(file.exists(file.path(repo, "dev", "report-fidelity.R")),
              "dev/report-fidelity.R is not available")
  skip_on_cran()
  for (pkg in c("svglite", "ragg", "png", "xml2", "textshaping", "systemfonts", "ggrepel")) {
    skip_if_not_installed(pkg)
  }

  env <- new.env(parent = asNamespace("WJPr"))
  withr::with_dir(repo, sys.source(file.path("dev", "report-fidelity.R"), envir = env))
  out <- withr::local_tempdir()
  res <- withr::with_dir(repo, env$fid_run(root, out = out))

  expect_equal(res$status, rep("ok", nrow(res)), info = paste(res$fig, res$status))
  low <- res[is.na(res$f1) | res$f1 < 0.99, , drop = FALSE]
  expect_equal(nrow(low), 0, info = paste("f1 below 0.99 in figures", paste(low$fig, collapse = ", ")))
})
