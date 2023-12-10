#' Create Virtual Environment with SSURGO Portal Dependencies
#'
#' Uses 'reticulate' to create a virtual environment with the SSURGO Portal
#' dependencies. Select the environment name, default `"r-ssurgoportal"`,
#' along with the specific Python and GDAL versions.
#'
#' @param envname _character_. Python virtual environment name. Default: `"r-ssurgoportal"`
#' @param python_version _character_. Semantic version number of 'Python' to install if not available. Default: `"3.10.2"
#' @param gdal_version _character_. Semantic version number of 'GDAL' package to install. Default: `""` for no specific version.
#' @param ... Additional arguments not (currently) used.
#'
#' @return _character_. Path to virtual environment Python binary (invisible).
#' @export
create_ssurgo_venv <- function(envname = "r-ssurgoportal",
                               python_version = SSURGOPORTAL_PYTHON_VERSION(),
                               gdal_version = SSURGOPORTAL_GDAL_VERSION(),
                               ...) {
  if (!.has_reticulate()) {
    stop("please install the 'reticulate' package to manage virtual environments", call. = FALSE)
  }

  pkg <- c("bottle", "jsonschema", "requests",
           ifelse(Sys.info()['sysname'] == "Windows", character(0),
                  ifelse(
                    !is.null(gdal_version) && nchar(gdal_version) > 0,
                    paste0("gdal==", gdal_version),
                    "gdal"
                  )))

  if (nchar(envname) > 0) {

    if (!reticulate::py_available(initialize = TRUE)) {
      reticulate::install_python(version = python_version)
    }

    if (!reticulate::virtualenv_exists(envname = envname)) {
      res1 <- try(reticulate::virtualenv_create(envname = envname),
                  silent = TRUE)
      res2 <- try(reticulate::virtualenv_install(envname = envname, packages = pkg),
                  silent = TRUE)

      if (Sys.info()['sysname'] == "Windows" && !inherits(res2, 'try-error')) {

        if (!requireNamespace("rgeowheels")) {
          stop("package 'rgeowheels' is required to install GDAL on Windows, download it here: https://github.com/brownag/rgeowheels/")
        }

        system(paste(shQuote(reticulate::virtualenv_python(envname = envname)),
                     "-m pip install", rgeowheels::install_wheel(
                       "GDAL",
                       pyversion = python_version,
                       version = gdal_version,
                       architecture = ifelse(grepl("arm", Sys.info()['machine']),
                                             "win_arm64", "win_amd64"),
                       download_only = TRUE
                     ), collapse = ' '))
      }

      if (inherits(res1, 'try-error') || inherits(res2, 'try-error')) {
        reticulate::py_install(pkg)
      }

      # TODO: somehow flag if user install has taken place
      if (inherits(res1, 'try-error')) {
        system(paste(.find_python(""), "-m pip install --user ", paste(pkg, collapse = " ")))
      }
    }
  }
  ssurgo_portal_python(envname = envname)
}

install_ssurgo_portal_dependencies <- function() {

}

#' @export
#' @rdname create_ssurgo_venv
ssurgo_portal_python <- function(envname = getOption("SSURGOPortal.virtualenv_name",
                                                     default = "r-ssurgoportal"), ...) {
  r <- .has_reticulate()
  if (missing(envname) && !r) {
    envname <- ""
  }
  p <- .find_python(envname = envname)
  options(SSURGOPortal.virtualenv_name = envname)
  options(SSURGOPortal.python_path = p)
  getOption("SSURGOPortal.python_path")
}
