# Run from the repository root: Rscript --vanilla examples/edgebars.R
# All values and confidence intervals below are fictional, not survey results.
pkgload::load_all(".", quiet = TRUE)
options(wjpr.family = "sans") # Or register the WJP fonts with wjp_fonts().

example_data <- data.frame(
  institution = c("Police", "Courts", "Local government", "Parliament"),
  trust = c(72.4, 64.8, 51.2, 38.6),
  bar_label = c("Trust in the police", "Trust in the courts and justice system",
                "Trust in local government officials", "Trust in members of parliament"),
  lower = c(68.2, 60.1, 46.8, 34.2),
  upper = c(76.6, 69.5, 55.6, 43.0)
)

# Each named plot is also available interactively after sourcing this script.
base_chart <- function(...) {
  wjp_edgebars(example_data, "trust", "institution", labels = "bar_label", ...)
}
finish_chart <- function(plot, title, subtitle) {
  plot + ggplot2::labs(
    title = title, subtitle = subtitle,
    caption = "Fictional data for demonstration only."
  )
}
save_chart <- function(plot, filename, height = 5.5) {
  ggplot2::ggsave(file.path("examples", filename), plot,
                 width = 8, height = height, dpi = 150, bg = "white")
}

edgebars_plot <- finish_chart(base_chart(cvec = "#2894aa"),
  "Trust in public institutions", "Percentage of respondents | Fixed 0–100 scale")
save_chart(edgebars_plot, "edgebars.png")

# 1. The background track always represents 100%.
track_plot <- finish_chart(base_chart(background_track = TRUE),
  "How much of the public trusts each institution?", "Each light background track represents 100%")
save_chart(track_plot, "edgebars_track.png")

# 2. Highlight one or several categories; other bars become neutral.
highlight_plot <- finish_chart(base_chart(highlight = "Courts", sort = "descending",
                                         value_position = "column", accuracy = 0.1),
  "Trust in the courts in context", "Courts highlighted | Values aligned for comparison")
save_chart(highlight_plot, "edgebars_highlight.png")

# 3. Complete pairs: one row per institution/year. Category labels are shared.
paired_data <- rbind(transform(example_data, year = "2022", trust = c(65, 59, 48, 42)),
                     transform(example_data, year = "2026"))
paired_plot <- finish_chart(wjp_edgebars(
  paired_data, "trust", "institution", labels = "bar_label", series = "year",
  cvec = c("2022" = "#482d8b", "2026" = "#2894aa"),
  background_track = TRUE, value_position = "column"
), "Trust in institutions over time", "Two series per institution | Percentage of respondents")
save_chart(paired_plot, "edgebars_paired.png", height = 7)

# 4. Precomputed confidence bounds: these illustrative bounds are not calculated
# by wjp_edgebars(). For surveys, supply bounds appropriate to the survey design.
ci_plot <- finish_chart(base_chart(ci_lower = "lower", ci_upper = "upper", accuracy = 0.1),
  "Trust estimates and their uncertainty", "Lines show illustrative 95% confidence intervals")
save_chart(ci_plot, "edgebars_ci.png")

# Combined example exercises all four features, long labels, and complete pairs.
paired_data$lower <- pmax(0, paired_data$trust - 4)
paired_data$upper <- pmin(100, paired_data$trust + 4)
paired_data$bar_label[paired_data$institution == "Courts"] <-
  "Trust in the courts and the institutions responsible for administering justice"
combined_plot <- finish_chart(wjp_edgebars(
  paired_data, "trust", "institution", labels = "bar_label", series = "year",
  background_track = TRUE, highlight = c("Courts", "Police"),
  ci_lower = "lower", ci_upper = "upper", value_position = "column", label_wrap = 45
), "Comparing institutional trust", "Paired estimates, confidence intervals, tracks, and highlighted categories")
save_chart(combined_plot, "edgebars_combined.png", height = 8)
