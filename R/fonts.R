#' Load WJP Fonts
#'
#' @description
#' `wjp_fonts()` loads the fonts used in WJP visualizations. Call it once at
#' the beginning of your R session before creating any WJP chart.
#'
#' Two engines are available:
#' \itemize{
#'   \item `engine = "showtext"` (default) downloads the fonts with
#'     \pkg{sysfonts} and activates \pkg{showtext}, which draws text as
#'     polygons on any graphics device. This is the historical behavior and
#'     works with the base `png()` and `pdf()` devices.
#'   \item `engine = "systemfonts"` makes the static font files available to
#'     \pkg{systemfonts}, without \pkg{showtext}. Devices built on systemfonts
#'     (\pkg{ragg}, \pkg{svglite}) then write real text that [wjp_save()] can
#'     convert to outlines, and every weight of the fonts can be used.
#' }
#'
#' @details
#' Both engines provide the family names used by WJPr:
#' \itemize{
#'   \item \strong{Lato Full}: regular (400) and bold (700). Default family of
#'     every WJPr chart.
#'   \item \strong{Lato Light}: light (300) and bold (700).
#'   \item \strong{Lato Black}: black (900).
#'   \item \strong{Inter Tight}: regular (400) and bold (700).
#' }
#'
#' The systemfonts engine also makes every static weight of Inter Tight
#' available and registers one family per weight, so that each role of a
#' chart can use its own weight: \strong{Inter Tight Medium} (500),
#' \strong{Inter Tight SemiBold} (600), and \strong{Inter Tight Bold} (700).
#' The text arguments of WJPr charts (e.g., `value_fontface`) accept the faces
#' `"medium"`, `"medium.italic"`, `"semibold"`, and `"semibold.italic"`, which
#' use these families when they are available and fall back to `"bold"` and
#' `"bold.italic"` otherwise (e.g., with the showtext engine or with Lato).
#' WJP country reports print values in Inter Tight SemiBold Italic
#' (`value_fontface = "semibold.italic"`).
#'
#' Static font files are read from `path` when supplied (file names as
#' distributed by Google Fonts, e.g. `InterTight-SemiBoldItalic.ttf` and
#' `Lato-Regular.ttf`). Otherwise they are downloaded once from Google Fonts
#' into `cache_dir`. Both fonts are licensed under the SIL Open Font License.
#' Fonts installed on the system with the same family names are superseded
#' by these static files.
#'
#' WJPr charts use \strong{Lato Full} by default. To switch every chart and
#' theme to another loaded family (e.g., Inter Tight), set the `wjpr.family`
#' option once per session: `options(wjpr.family = "Inter Tight")`. See
#' [wjp_font_family()].
#'
#' @param engine String. `"showtext"` (default) or `"systemfonts"`.
#' @param showtext Logical. Whether to activate \pkg{showtext}. Defaults to
#'   `TRUE` for the showtext engine and `FALSE` for the systemfonts engine,
#'   which also turns off an active showtext session.
#' @param path String. Optional directory containing the static font files
#'   (systemfonts engine only).
#' @param cache_dir String. Directory where downloaded font files are kept
#'   (systemfonts engine only). Default is the user cache directory of WJPr.
#'
#' @return Invisibly, `NULL` for the showtext engine, or a data frame with the
#'   font files and the families that resolve to them for the systemfonts
#'   engine.
#'
#' @export
#'
#' @examples
#' # Load fonts before creating charts
#' wjp_fonts()
#'
#' # Now you can use the fonts in ggplot2
#' library(ggplot2)
#' ggplot(mtcars, aes(x = mpg, y = wt)) +
#'   geom_point() +
#'   theme(text = element_text(family = "Lato Full"))
#'
#' \dontrun{
#' # Static files known to systemfonts (text can be outlined on export)
#' wjp_fonts(engine = "systemfonts")
#' options(wjpr.family = "Inter Tight")
#' }
#'
wjp_fonts <- function(engine    = c("showtext", "systemfonts"),
                      showtext  = NULL,
                      path      = NULL,
                      cache_dir = NULL) {
  engine <- match.arg(engine)
  if (is.null(showtext)) {
    showtext <- engine == "showtext"
  }
  if (length(showtext) != 1 || !is.logical(showtext) || is.na(showtext)) {
    stop("`showtext` must be TRUE or FALSE.", call. = FALSE)
  }

  if (engine == "systemfonts") {
    out <- wjp_fonts_systemfonts(path = path, cache_dir = cache_dir)
    if (isTRUE(showtext)) {
      showtext::showtext_auto()
    } else {
      showtext::showtext_auto(FALSE)
    }
    return(invisible(out))
  }

  # Use curl handle if available for better connection handling
  handle <- if (requireNamespace("curl", quietly = TRUE)) {
    curl::new_handle()
  } else {
    NULL
  }

  sysfonts::font_add_google(
    "Lato",
    family     = "Lato Full",
    regular.wt = 400,
    bold.wt    = 700,
    repo       = "https://fonts.gstatic.com/",
    db_cache   = TRUE,
    handle     = handle
  )
  sysfonts::font_add_google(
    "Lato",
    family     = "Lato Light",
    regular.wt = 300,
    bold.wt    = 700,
    repo       = "https://fonts.gstatic.com/",
    db_cache   = TRUE,
    handle     = handle
  )
  sysfonts::font_add_google(
    "Lato",
    family     = "Lato Black",
    regular.wt = 900,
    bold.wt    = 900,
    repo       = "https://fonts.gstatic.com/",
    db_cache   = TRUE,
    handle     = handle
  )
  sysfonts::font_add_google(
    "Inter Tight",
    family     = "Inter Tight",
    regular.wt = 400,
    bold.wt    = 700,
    repo       = "https://fonts.gstatic.com/",
    db_cache   = TRUE,
    handle     = handle
  )
  if (isTRUE(showtext)) {
    showtext::showtext_auto()
  }
  invisible(NULL)
}


# Static faces used by the systemfonts engine: Google Fonts family, file stem,
# weight and style of each file.
wjp_font_faces <- function() {
  inter <- data.frame(
    google = "Inter Tight",
    stem   = "InterTight",
    face   = c("Regular", "Italic", "Medium", "MediumItalic",
               "SemiBold", "SemiBoldItalic", "Bold", "BoldItalic"),
    weight = c(400, 400, 500, 500, 600, 600, 700, 700),
    italic = rep(c(FALSE, TRUE), 4),
    stringsAsFactors = FALSE
  )
  lato <- data.frame(
    google = "Lato",
    stem   = "Lato",
    face   = c("Light", "LightItalic", "Regular", "Italic",
               "Bold", "BoldItalic", "Black", "BlackItalic"),
    weight = c(300, 300, 400, 400, 700, 700, 900, 900),
    italic = rep(c(FALSE, TRUE), 4),
    stringsAsFactors = FALSE
  )
  faces <- rbind(inter, lato)
  faces$file <- paste0(faces$stem, "-", faces$face, ".ttf")
  faces
}

# Download URLs of the static faces of one Google Fonts family (CSS2 API).
# Google serves TrueType files to clients that do not announce WOFF2 support.
wjp_google_font_urls <- function(family, faces) {
  axis <- paste0(as.integer(faces$italic), ",", faces$weight)
  css_url <- paste0(
    "https://fonts.googleapis.com/css2?family=",
    gsub(" ", "+", family, fixed = TRUE),
    ":ital,wght@", paste(sort(unique(axis)), collapse = ";")
  )
  css <- paste(readLines(url(css_url), warn = FALSE), collapse = "\n")
  blocks <- regmatches(css, gregexpr("@font-face\\s*\\{[^}]*\\}", css))[[1]]
  if (length(blocks) == 0) {
    stop("Google Fonts returned no font files for ", family, ".", call. = FALSE)
  }
  info <- data.frame(
    italic = grepl("font-style:\\s*italic", blocks),
    weight = as.numeric(sub(".*font-weight:\\s*([0-9]+).*", "\\1", blocks)),
    url    = sub(".*src:\\s*url\\(([^)]+)\\).*", "\\1", blocks),
    stringsAsFactors = FALSE
  )
  info <- info[grepl("\\.ttf$", info$url), , drop = FALSE]
  key <- paste(info$italic, info$weight)
  info <- info[!duplicated(key, fromLast = TRUE), , drop = FALSE]
  idx <- match(paste(faces$italic, faces$weight), paste(info$italic, info$weight))
  if (anyNA(idx)) {
    stop("Google Fonts did not return every face of ", family, ".", call. = FALSE)
  }
  info$url[idx]
}

# Locate (or download) the static font files and make the WJP families known
# to systemfonts.
wjp_fonts_systemfonts <- function(path = NULL, cache_dir = NULL) {
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    stop("`engine = \"systemfonts\"` requires the systemfonts package.", call. = FALSE)
  }
  faces <- wjp_font_faces()

  if (!is.null(path)) {
    if (!is.character(path) || length(path) != 1 || !dir.exists(path)) {
      stop("`path` must be an existing directory.", call. = FALSE)
    }
    faces$path <- file.path(path, faces$file)
    missing <- faces$file[!file.exists(faces$path)]
    if (length(missing) > 0) {
      stop("Font files not found in `path`: ", paste(missing, collapse = ", "), ".",
           call. = FALSE)
    }
  } else {
    if (is.null(cache_dir)) {
      cache_dir <- file.path(tools::R_user_dir("WJPr", which = "cache"), "fonts")
    }
    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    faces$path <- file.path(cache_dir, faces$file)
    for (fam in unique(faces$google)) {
      need <- faces$google == fam & !file.exists(faces$path)
      if (!any(need)) {
        next
      }
      urls <- wjp_google_font_urls(fam, faces[need, , drop = FALSE])
      for (i in seq_along(urls)) {
        dest <- faces$path[need][i]
        tmp <- paste0(dest, ".part")
        utils::download.file(urls[i], tmp, mode = "wb", quiet = TRUE)
        file.rename(tmp, dest)
      }
    }
  }

  # Every static file becomes known to systemfonts, ahead of fonts installed
  # on the system with the same family name (e.g., a variable Inter Tight)
  if (exists("add_fonts", envir = asNamespace("systemfonts"), inherits = FALSE)) {
    systemfonts::add_fonts(faces$path)
  }

  file_of <- function(stem, weight, italic) {
    faces$path[faces$stem == stem & faces$weight == weight & faces$italic == italic]
  }
  taken <- unique(as.character(systemfonts::system_fonts()$family))
  register <- function(name, stem, plain, bold) {
    files <- c(plain = file_of(stem, plain, FALSE), bold = file_of(stem, bold, FALSE),
               italic = file_of(stem, plain, TRUE), bolditalic = file_of(stem, bold, TRUE))
    status <- if (name %in% taken) {
      "system family (static files take precedence)"
    } else {
      systemfonts::register_font(
        name = name, plain = files[["plain"]], bold = files[["bold"]],
        italic = files[["italic"]], bolditalic = files[["bolditalic"]]
      )
      "registered"
    }
    data.frame(family = name, plain = basename(files[["plain"]]),
               bold = basename(files[["bold"]]), status = status,
               stringsAsFactors = FALSE)
  }

  out <- rbind(
    register("Lato Full",            "Lato",       400, 700),
    register("Lato Light",           "Lato",       300, 700),
    register("Lato Black",           "Lato",       900, 900),
    register("Inter Tight",          "InterTight", 400, 700),
    register("Inter Tight Medium",   "InterTight", 500, 700),
    register("Inter Tight SemiBold", "InterTight", 600, 700),
    register("Inter Tight Bold",     "InterTight", 700, 700)
  )
  out$dir <- dirname(faces$path[1])
  .wjp_glyph_cache_reset()
  out
}


#' Check whether a font family is known to systemfonts
#'
#' @param family Font family name.
#' @return Logical scalar.
#' @noRd
wjp_systemfonts_has <- function(family) {
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    return(FALSE)
  }
  if (family %in% systemfonts::registry_fonts()$family) {
    return(TRUE)
  }
  family %in% as.character(systemfonts::system_fonts()$family)
}

#' Resolve a role font face to a family and a ggplot2 fontface
#'
#' Faces `"plain"`, `"bold"`, `"italic"`, `"bold.italic"` keep the active
#' family. Faces `"medium"`, `"semibold"` (and their `.italic` variants) use
#' the family `"<family> Medium"` / `"<family> SemiBold"` when it is available
#' to the drawing engine, and fall back to bold otherwise.
#'
#' @param face Face name (or a ggplot2 fontface number).
#' @param family Base family.
#' @return `list(family, fontface)`.
#' @noRd
wjp_face <- function(face, family = wjp_font_family()) {
  if (is.numeric(face) || face %in% c("plain", "bold", "italic", "bold.italic")) {
    return(list(family = family, fontface = face))
  }
  valid <- c("medium", "medium.italic", "semibold", "semibold.italic")
  if (length(face) != 1 || !face %in% valid) {
    stop("Font faces must be one of \"plain\", \"bold\", \"italic\", \"bold.italic\", ",
         "\"medium\", \"medium.italic\", \"semibold\", or \"semibold.italic\".",
         call. = FALSE)
  }
  italic <- grepl("italic", face, fixed = TRUE)
  weight_name <- if (startsWith(face, "medium")) "Medium" else "SemiBold"
  candidate <- paste(family, weight_name)
  available <- if (wjp_showtext_active()) {
    candidate %in% sysfonts::font_families()
  } else {
    wjp_systemfonts_has(candidate)
  }
  if (available) {
    list(family = candidate, fontface = if (italic) "italic" else "plain")
  } else {
    list(family = family, fontface = if (italic) "bold.italic" else "bold")
  }
}
