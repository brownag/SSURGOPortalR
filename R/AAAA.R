.GLOBAL <- list()
.GLOBAL$SSURGOPortal.debug <- TRUE
.GLOBAL$SSURGOPortal.debug_message_function <- packageStartupMessage
utils::globalVariables(".GLOBAL", "SSURGOPortal")

.ssurgo_portal_debug <- function(...) {
  if (.GLOBAL$SSURGOPortal.debug)
    .GLOBAL$SSURGOPortal.debug_message_function(paste("debug: ", ...))
}

#' SSURGOPortal Environment Variables
#'
#' `SSURGOPORTAL_PYTHON_VERSION()`: returns value of system environment
#'   variable `R_SSURGOPORTAL_PYTHON_VERSION` or option `SSURGOPortal.python_version`.
#'   If neither are set then returns `"3.10"`, the suggested Python version.
#'
#' @return character. Version number for Python or GDAL to be used when building Python environment.
#' @export
#' @rdname ssurgo-env-vars
SSURGOPORTAL_PYTHON_VERSION <- function() {
  s <- Sys.getenv("R_SSURGOPORTAL_PYTHON_VERSION", unset = "")
  if (nchar(s) > 0)
    return(s)
  o <- getOption("SSURGOPortal.python_version", default = "")
  if (nchar(o) > 0)
    return(o)
  i <- .get_system_python_version()
  if (nchar(i) > 0)
    return(i)
  "3.10"
}
#' `SSURGOPORTAL_GDAL_VERSION()`: returns value of system environment
#'   variable `R_SSURGOPORTAL_GDAL_VERSION` or option `SSURGOPortal.gdal_version`.
#'   If neither are set then returns the version returned by running `gdalinfo --version`
#'   If there is no `gdalinfo` on the path, or other error, the result is `"3.7.3"`
#'   which is handled as no version constraint. If the version is an empty string,
#'   the most recent version of the library will be installed. The latest version
#'   may not be compatible with installed versions of libgdal, etc.
#' @export
#' @rdname ssurgo-env-vars
SSURGOPORTAL_GDAL_VERSION <-  function() {
  s <- Sys.getenv("R_SSURGOPORTAL_GDAL_VERSION", unset = "")
  o <- getOption("SSURGOPortal.gdal_version", default = "")
  p <- .get_python_package_version('GDAL')
  if (s == p || o == p || nchar(p) > 0) {
    attr(p, "installed") <- TRUE
  } else {
    if (nchar(s) > 0)
      return(s)
    if (nchar(o) > 0)
      return(o)
  }
  if (nchar(p) > 0)
    return(p)
  i <- .get_system_gdal_version()
  if (nchar(i) > 0)
    return(i)
  "3.7.3"
}

.get_system_python_version <- function() {
  gsub("([^.]*\\.[^.]*)\\..*", "\\1", as.character(gsub("^Python (.*)$|.*", "\\1",
                    try(system(paste(
                      .find_python(""), "--version"
                    ), intern = TRUE), silent = TRUE)
  )))
}

.get_python_package_version <- function(x) {
  try(reticulate::py_eval(paste0("version('", x, "')")), silent = TRUE)
}

.get_system_gdal_version <- function() {
  as.character(gsub("^GDAL (.*), released .*$|.*", "\\1",
                    try(system(paste(
                      Sys.which("gdalinfo"), "--version"
                    ), intern = TRUE), silent = TRUE)
  ))
}

.has_reticulate <- function() {
  ((length(find.package("reticulate", quiet = TRUE)) > 0) &&
     !inherits(try(requireNamespace("reticulate", quietly = TRUE)), 'try-error'))
}

#' @importFrom utils packageVersion
#' @importFrom reticulate virtualenv_exists condaenv_exists
.onAttach <- function(libname, pkgname) {

  sev <- as.logical(Sys.getenv("R_SSURGOPORTAL_USE_VIRTUALENV", unset = "TRUE"))
  .ssurgo_portal_debug("R_SSURGOPORTAL_USE_VIRTUALENV:", sev)

  cev <- as.logical(Sys.getenv("R_SSURGOPORTAL_USE_CONDAENV", unset = "FALSE"))
  .ssurgo_portal_debug("R_SSURGOPORTAL_USE_CONDAENV:", cev)

  # only perform automatic setup if reticulate is available, user is attaching lib interactively
  # and they have not turned off the default behavior to try and create/use a venv

  use_conda <- as.logical(getOption("SSURGOPortal.use_condaenv", default = cev))

  # NB: must have reticulate to tinker with virtual environments
  if (.has_reticulate()) {
    # NB: requires Python >= 3.8
    try(reticulate::py_run_string("from importlib.metadata import version"), silent = TRUE)

    # NB: never sets up virtual or conda environment unless package is being loaded interactively
    if (interactive() && (use_conda || as.logical(getOption("SSURGOPortal.use_virtualenv", default = sev)))) {

      # default behavior is to use a virtual environment "r-ssurgoportal"
      ven <- getOption("SSURGOPortal.virtualenv_name", default = "r-ssurgoportal")
      .ssurgo_portal_debug("SSURGOPortal.virtualenv_name:", ven)

      if (!reticulate::virtualenv_exists(ven) && !reticulate::condaenv_exists(ven))
        create_ssurgo_venv(ven)

      reticulate::use_python(ssurgo_portal_python(envname = ven, conda = use_conda))
    }
  }

  .winpath <- function(x) if (Sys.info()["sysname"] == "Windows") normalizePath(x, "/") else x

  # TODO: indicate that these paths exist (and are executable?)
  pyp <- suppressWarnings(.winpath(ssurgo_portal_python()))
  ssp <- suppressWarnings(.winpath(file.path(ssurgo_portal_dir("data"), "SSURGOPortal.pyz")))

  packageStartupMessage("SSURGOPortal R Interface v",
                        utils::packageVersion("SSURGOPortal"),
                        "\n\tPython: ", ifelse(length(pyp) > 0 && file.exists(pyp),
                                               pyp, "<not found>"),
                        "\n SSURGO Portal: ", ifelse(length(ssp) > 0 && file.exists(ssp),
                                                     ssp, "<not found>"))
}
