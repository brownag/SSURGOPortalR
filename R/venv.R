.has_ssurgo_portal_dependencies <- function() {
  all(nchar(sapply(c("bottle", "jsonschema", "requests", "GDAL"), .get_python_package_version)) > 0)
}

#' Create Virtual Environment with SSURGO Portal Dependencies
#'
#' Uses 'reticulate' to create a virtual environment with the SSURGO Portal
#' dependencies. Select the environment name, default `"r-ssurgoportal"`,
#' along with the specific Python and GDAL versions.
#'
#' @param envname _character_. Python virtual environment name. Default: `"r-ssurgoportal"`
#' @param python_version _character_. Semantic version number of 'Python' to install if not available. Default: `"3.10.2"
#' @param gdal_version _character_. Semantic version number of 'GDAL' package to install. Default: `""` for no specific version.
#' @param conda _logical_ or _character_. Create Conda environment instead of virtual environment? Default: `FALSE`. `TRUE` is converted to `"auto"` which searches for a suitable Conda installation. Alternately, the path to the conda binary may be specified as a _character_ value.
#' @param ... Additional arguments used only when `conda=TRUE`
#'
#' @return _character_. Path to virtual environment Python binary (invisible).
#' @export
create_ssurgo_venv <- function(envname = "r-ssurgoportal",
                               python_version = SSURGOPORTAL_PYTHON_VERSION(),
                               gdal_version = SSURGOPORTAL_GDAL_VERSION(),
                               conda = FALSE,
                               ...) {
  if (!.has_reticulate()) {
    stop("please install the 'reticulate' package to manage virtual environments", call. = FALSE)
  }

  pkg <- c("bottle", "jsonschema", "requests",
           ifelse(Sys.info()['sysname'] == "Windows", "",
                  ifelse(
                    !is.null(gdal_version) && nchar(gdal_version) > 0,
                    paste0("gdal==", gdal_version),
                    "gdal"
                  )))
  pkg <- pkg[nchar(pkg) > 0]

  if (nchar(envname) > 0) {

    if (!missing(conda) && (is.logical(conda) && conda) || is.character(conda)) {
      if (is.logical(conda) && conda) {
        conda <- "auto"
      }
      if (reticulate::condaenv_exists(envname = envname, conda = conda)) {
        reticulate::use_condaenv(condaenv = envname, conda = conda)
      } else {
        reticulate::conda_create(
          envname = envname,
          packages = pkg,
          forge = TRUE,
          conda = conda,
          python_version = python_version
        )
      }
    } else if (!reticulate::virtualenv_exists(envname = envname)) {

      ipy <- TRUE
      if (!reticulate::py_available(initialize = FALSE)) {
        ipyv <- strsplit(python_version, ".", fixed = TRUE)[[1]]
        ipvv <- ifelse(length(ipyv) == 2, paste0(python_version, ":latest"), python_version)
        ipy <- try(reticulate::install_python(version = ipvv), silent = TRUE)
      }

      res1 <- NULL
      res2 <- NULL
      if (!inherits(ipy, 'try-error')) {
        res1 <- try(reticulate::virtualenv_create(envname = envname), silent = TRUE)

        if (!reticulate::py_available(initialize = TRUE)) {
          message("failed to initialize virtualenv python")
        }

        if (!inherits(res1, 'try-error')) {
          # TODO: install missing packages into existing environments
          res2 <- try(reticulate::virtualenv_install(envname = envname, packages = pkg), silent = TRUE)
        }
      }

      if (!inherits(ipy, 'try-error') &&
          !inherits(res1, 'try-error') &&
          !inherits(res2, 'try-error')) {
        py_path <- reticulate::virtualenv_python(envname = envname)
      } else {
        py_path <- .find_python("")

        if (!.has_ssurgo_portal_dependencies())
          system(paste(shQuote(py_path), "-m pip install --user --upgrade", paste(pkg, collapse = " ")))
      }

      if (Sys.info()['sysname'] == "Windows" && .get_python_package_version('GDAL') != gdal_version) {

        if (!requireNamespace("rgeowheels")) {
          stop("package 'rgeowheels' is required to install GDAL on Windows, download it here: https://github.com/brownag/rgeowheels/")
        }

        system(paste(shQuote(py_path),
                     "-m pip install", rgeowheels::install_wheel(
                       "GDAL",
                       pyversion = python_version,
                       version = gdal_version,
                       architecture = ifelse(grepl("arm", Sys.info()['machine']),
                                             "win_arm64", "win_amd64"),
                       download_only = TRUE
                     ), collapse = ' '))
      }
    }
  }
  ssurgo_portal_python(envname = envname)
}

#' @export
#' @rdname create_ssurgo_venv
#' @param conda logical. Look for Conda environment instead of virtual environment? Default: `FALSE`
ssurgo_portal_python <- function(envname = getOption("SSURGOPortal.virtualenv_name",
                                                     default = "r-ssurgoportal"),
                                 conda = FALSE,
                                 ...) {
  r <- .has_reticulate()
  if (missing(envname) && !r) {
    envname <- ""
  }
  p <- .find_python(envname = envname, conda = conda)
  options(SSURGOPortal.virtualenv_name = envname)
  options(SSURGOPortal.python_path = p)
  getOption("SSURGOPortal.python_path")
}
