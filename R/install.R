#' Download SSURGO Portal .PYZ file from Web Soil Survey
#'
#' This routine downloads the latest .pyz file from Web Soil Survey
#'
#' @param verbose Show download progress and location of file on successful download? Default `TRUE`
#' @param overwrite Overwrite existing .PYZ file? Default: `FALSE`
#' @param timeout Default: `3000` seconds. Temporarily overrides `options()` for `timeout`.
#' @param src Default: `"https://websoilsurvey.sc.egov.usda.gov/DSD/Download/SsurgoPortal/SSURGO_Portal.zip"`
#' @param envname Virtual environment to create for installation. Default: `"r-ssurgoportal"`. Use `""` for no virtual environment modifications.
#' @param ... Additional arguments to `create_ssurgo_venv()` when `venv=TRUE`.
#' @param python_version _character_. Semantic version number of 'Python' to install if not available. Default: `"3.10.2"`
#' @param gdal_version _character_. Semantic version number of 'GDAL' package to install. Default: `""`
#'
#' @return Path to downloaded file, or `try-error` on error.
#' @export
#'
#' @examples
#' \dontrun{
#'  install_ssurgo_portal()
#' }
#' @importFrom utils download.file
install_ssurgo_portal <- function(
    verbose = TRUE,
    overwrite = FALSE,
    timeout = 3000,
    src = "https://websoilsurvey.sc.egov.usda.gov/DSD/Download/SsurgoPortal/SSURGO_Portal.zip",
    envname = "r-ssurgoportal",
    python_version = SSURGOPORTAL_PYTHON_VERSION(),
    gdal_version = SSURGOPORTAL_GDAL_VERSION(),
    ...
) {

  if (nchar(envname) > 0) {
    o2 <- try(create_ssurgo_venv(envname = envname,
                                 python_version = python_version,
                                 gdal_version = gdal_version))

    if (inherits(o2, 'try-error'))
      stop('Failed to create virtual environment `\"', envname,
           '\"` or install required packages to base environment', call. = FALSE)

  }

  # update 2023/10/19: use WSS link
  # TODO: autoupdate link, use release, build .PYZ from a GH source?
  urx <- src

  optorig <- getOption("timeout")
  on.exit(options(timeout = optorig))
  options(timeout = timeout)
  dstd <- ssurgo_portal_dir("data")
  dst <- file.path(dstd, "SSURGOPortal.pyz.zip")
  dst2 <- normalizePath(file.path(dstd, "SSURGOPortal.pyz"), winslash = "/", mustWork = FALSE)

  if (!dir.exists(dstd)) {
    dir.create(dstd, recursive = TRUE)
  }

  if (file.exists(dst2) && !overwrite) {
    message("File ", dst2, " already exists. Set overwrite=TRUE to re-download")
    res <- TRUE
  } else {
    res <- try(download.file(urx, dst, quiet = !verbose, mode = "wb"))
    res <- try(suppressWarnings(unzip(dst, exdir = dstd)))
    res <- try(file.copy(list.files(dstd, recursive = TRUE, full.names = TRUE, pattern = "SSURGO_Portal.*pyz$")[1], dst2, overwrite = TRUE))
    res <- try(file.remove(list.files(dstd, recursive = TRUE, full.names = TRUE, pattern = "SSURGO_Portal")[1]))
  }

  if (!inherits(res, 'try-error')) {

    # apply patches if needed
    .apply_pyz_patches(res, verbose)

    if (verbose) {
      message("Downloaded SSURGO Portal to: ", dst2)
    }
    return(invisible(dst2))
  }

  message(res[0])
  invisible(res)
}

#' SSURGO Portal User Directories
#'
#' These are standard locations for storing data, config, and cache information for SSURGO Portal outside of the installation in the R package library.
#'
#' @param which One or more of: `"data"`, `"config"`, `"cache"`
#' @return `character`. Path to data, config or cache directories, respectively.
#'
#' @export
#' @rdname ssurgo_portal_dir
#'
#' @examples
#' ssurgo_portal_dir("data")
#' ssurgo_portal_dir("config")
#' ssurgo_portal_dir("cache")
ssurgo_portal_dir <- function(which = "data") {

  which <- match.arg(which,
                     choices = c("data", "config", "cache"),
                     several.ok = TRUE)

  vapply(which, FUN.VALUE = character(1),
         function(w) {
           tools::R_user_dir(package = "SSURGOPortal", which = w)
         })

}

