#' Check WJPr Dependencies
#'
#' @description
#' `wjp_check_deps()` verifies that all required and optional dependencies for WJPr
#' are installed and reports their status.
#'
#' @param install Logical. If TRUE, attempts to install missing packages. Default is FALSE.
#' @param quiet Logical. If TRUE, suppresses output messages. Default is FALSE.
#' @param ask Logical. If TRUE in an interactive session, asks before installing
#'   missing packages. Default is \code{interactive()}.
#'
#' @return Invisibly returns a list with two elements:
#' \itemize{
#'   \item \code{core}: Named logical vector of core dependency status
#'   \item \code{optional}: Named logical vector of optional dependency status
#' }
#'
#' @export
#'
#' @examples
#' # Check all dependencies
#' wjp_check_deps()
#'
#' # Check and install missing packages
#' # wjp_check_deps(install = TRUE)
#'
wjp_check_deps <- function(install = FALSE, quiet = FALSE, ask = interactive()) {

  # Define dependencies
  core_deps <- list(
    ggplot2   = list(min_version = "3.4.0", used_for = "All chart functions"),
    dplyr     = list(min_version = "1.1.0", used_for = "Data manipulation"),
    tidyr     = list(min_version = "1.3.0", used_for = "Data reshaping"),
    magrittr  = list(min_version = "2.0.0", used_for = "Pipe operator"),
    rlang     = list(min_version = "1.0.0", used_for = "Tidy evaluation"),
    tibble    = list(min_version = "3.0.0", used_for = "Data frames"),
    purrr     = list(min_version = "1.0.0", used_for = "Functional programming"),
    sysfonts  = list(min_version = "0.8.0", used_for = "Font loading"),
    showtext  = list(min_version = "0.9.0", used_for = "Font rendering")
  )

  optional_deps <- list(
    ggtext      = list(min_version = "0.1.0", used_for = "Rich text labels (radar, rose, edgebars, groupbars)"),
    ggrepel     = list(min_version = "0.9.0", used_for = "Non-overlapping labels (wjp_lines, wjp_slope)"),
    ggh4x       = list(min_version = "0.2.0", used_for = "Minor axis ticks (wjp_lines custom.axis)"),
    systemfonts = list(min_version = "1.0.0", used_for = "Label width measurement (spread_labels_x)"),
    haven       = list(min_version = "2.5.0", used_for = "Reading Stata/SPSS files")
  )

  # Check function
  check_pkg <- function(pkg, info) {
    installed <- requireNamespace(pkg, quietly = TRUE)
    version <- if (installed) {
      as.character(utils::packageVersion(pkg))
    } else {
      NA_character_
    }
    meets_min <- if (installed && !is.null(info$min_version)) {
      utils::packageVersion(pkg) >= package_version(info$min_version)
    } else {
      FALSE
    }

    list(
      installed = installed,
      version = version,
      min_version = info$min_version,
      meets_min = meets_min,
      used_for = info$used_for
    )
  }

  # Check all dependencies
  core_status <- lapply(names(core_deps), function(pkg) {
    check_pkg(pkg, core_deps[[pkg]])
  })
  names(core_status) <- names(core_deps)

  optional_status <- lapply(names(optional_deps), function(pkg) {
    check_pkg(pkg, optional_deps[[pkg]])
  })
  names(optional_status) <- names(optional_deps)

  # Print results
  if (!quiet) {
    cat("\n")
    cat("WJPr Dependency Check\n")
    cat(strrep("=", 60), "\n\n")

    # Core dependencies
    cat("CORE DEPENDENCIES (Required)\n")
    cat(strrep("-", 40), "\n")

    for (pkg in names(core_status)) {
      status <- core_status[[pkg]]
      icon <- if (status$installed && status$meets_min) {
        "\033[32m[OK]\033[0m"
      } else if (status$installed) {
        "\033[33m[OLD]\033[0m"
      } else {
        "\033[31m[MISSING]\033[0m"
      }

      version_str <- if (status$installed) {
        paste0("v", status$version)
      } else {
        "not installed"
      }

      cat(sprintf("  %-12s %s %s\n", pkg, icon, version_str))
    }

    cat("\n")

    # Optional dependencies
    cat("OPTIONAL DEPENDENCIES\n")
    cat(strrep("-", 40), "\n")

    for (pkg in names(optional_status)) {
      status <- optional_status[[pkg]]
      icon <- if (status$installed) {
        "\033[32m[OK]\033[0m"
      } else {
        "\033[90m[--]\033[0m"
      }

      version_str <- if (status$installed) {
        paste0("v", status$version)
      } else {
        "not installed"
      }

      cat(sprintf("  %-12s %s %-20s  %s\n",
                  pkg, icon, version_str, status$used_for))
    }

    cat("\n")

    # Summary
    missing_core <- !vapply(core_status, function(x) x$installed && x$meets_min, logical(1))
    missing_optional <- !vapply(optional_status, function(x) x$installed, logical(1))

    if (any(missing_core)) {
      cat("\033[31mWARNING:\033[0m Missing core dependencies: ",
          paste(names(core_status)[missing_core], collapse = ", "), "\n")
      cat("Install with:\n")
      cat("  install.packages(c('",
          paste(names(core_status)[missing_core], collapse = "', '"),
          "'))\n\n")
    }

    if (any(missing_optional)) {
      cat("\033[33mNOTE:\033[0m Some optional packages not installed: ",
          paste(names(optional_status)[missing_optional], collapse = ", "), "\n")
      cat("Install with:\n")
      cat("  install.packages(c('",
          paste(names(optional_status)[missing_optional], collapse = "', '"),
          "'))\n\n")
    }

    if (!any(missing_core) && !any(missing_optional)) {
      cat("\033[32mAll dependencies are installed!\033[0m\n\n")
    }
  }

  # Install missing packages if requested
  if (install) {
    missing_core_pkgs <- names(core_status)[!vapply(core_status, function(x) x$installed, logical(1))]
    missing_optional_pkgs <- names(optional_status)[!vapply(optional_status, function(x) x$installed, logical(1))]

    all_missing <- c(missing_core_pkgs, missing_optional_pkgs)

    if (length(all_missing) > 0) {
      if (isTRUE(ask) && interactive()) {
        proceed <- utils::askYesNo(
          paste0(
            "Install missing packages from the configured R repositories? ",
            paste(all_missing, collapse = ", ")
          ),
          default = FALSE
        )

        if (!isTRUE(proceed)) {
          if (!quiet) {
            cat("Package installation cancelled.\n")
          }
          return(invisible(list(
            core = vapply(core_status, function(x) x$installed && x$meets_min, logical(1)),
            optional = vapply(optional_status, function(x) x$installed, logical(1))
          )))
        }
      }

      if (!quiet) {
        cat("Installing missing packages: ", paste(all_missing, collapse = ", "), "\n")
      }
      utils::install.packages(all_missing)
    } else {
      if (!quiet) {
        cat("No packages to install.\n")
      }
    }
  }

  # Return status invisibly
  invisible(list(
    core = vapply(core_status, function(x) x$installed && x$meets_min, logical(1)),
    optional = vapply(optional_status, function(x) x$installed, logical(1))
  ))
}


#' Check if Optional Package is Available
#'
#' @description
#' Internal helper to check if an optional package is available and
#' provide a helpful message if not.
#'
#' @param pkg Package name
#' @param feature Feature that requires the package
#'
#' @return Logical indicating if package is available
#' @keywords internal
#' @noRd
check_optional_pkg <- function(pkg, feature = NULL) {
  available <- requireNamespace(pkg, quietly = TRUE)

  if (!available && !is.null(feature)) {
    warning(
      "Package '", pkg, "' is not installed. ",
      "Feature '", feature, "' will not work.\n",
      "Install with: install.packages('", pkg, "')",
      call. = FALSE
    )
  }

  available
}
