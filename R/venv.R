#' Create Virtual Environment with SSURGO Portal Dependencies
#'
#' Uses reticulate to create a virtual environment with the SSURGO Portal dependencies. Select the environment name, default `"r-ssurgoportal"`, along with the specific Python and GDAL versions.
#'
#' @param envname _character_. Python virtual environment name. Default: `"r-ssurgoportal"`
#' @param python_version _character_. Semantic version number of 'Python' to install if not available. Default: `"3.10:latest"`, the latest version of Python 3.10.x.
#' @param gdal_version _character_. Semantic version number of 'GDAL' package to install. Default: `"3.7.3"`
#'
#' @return _character_. Path to virtual environment Python binary (invisible).
#' @export
create_ssurgo_venv <- function(envname = "r-ssurgoportal",
                               python_version = "3.10:latest",
                               gdal_version = "3.7.3") {
  if (!.has_reticulate()) {
    stop("please install the 'reticulate' package to manage virtual environments", call. = FALSE)
  }
  pkg <- c("bottle", "jsonschema", "requests", paste0("gdal==", gdal_version))
  if (nchar(envname) > 0) {
    if (!reticulate::py_available(initialize = TRUE)) {
      reticulate::install_python(version = python_version)
    }
    if (!reticulate::virtualenv_exists(envname = envname)) {
      res1 <- try(reticulate::virtualenv_create(envname = envname), silent = TRUE)
      res2 <- try(reticulate::virtualenv_install(envname = envname, packages = pkg), silent = TRUE)
      if (!inherits(res1, 'try-error') && inherits(res2, 'try-error')) {
        reticulate::py_install(pkg)
      }
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
ssurgo_portal_python <- function(envname = getOption("SSURGOPortalR.virtualenv_name", default = "r-ssurgoportal")) {
  if (!.has_reticulate()) {
    envname <- ""
  }
  options(SSURGOPortalR.virtualenv_name = envname)
  options(SSURGOPortalR.python_path = .rVENV())[[1]]
}

.rVENV <- function(python_version = SSURGOPORTAL_R_DEFAULT_PYTHON_VERSION(),
                   gdal_version   = SSURGOPORTAL_R_DEFAULT_GDAL_VERSION()) {
  n <-  getOption("SSURGOPortalR.virtualenv_name", default = "r-ssurgoportal")
  o <- .find_python("")
  if (nchar(n) > 0 && .has_reticulate()) {
    if (reticulate::virtualenv_exists(n)) {
      o <- getOption("SSURGOPortalR.python_path", default = NULL)
      if (is.null(o)) {
        o <- reticulate::virtualenv_python(n)
      }
    } else {
      o <- create_ssurgo_venv(envname = n,
                              python_version = python_version,
                              gdal_version = gdal_version)
    }
    options(SSURGOPortalR.python_path = o)
  }
  o
}
