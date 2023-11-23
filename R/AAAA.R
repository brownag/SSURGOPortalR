#' SSURGOPortal Environment Variables
#'
#' `SSURGOPORTAL_PYTHON_VERSION()`: returns value of system environment
#'   variable `R_SSURGOPORTAL_PYTHON_VERSION` or option `SSURGOPortal.python_version`.
#'   If neither are set then returns `"3.10.2"`, the suggested Python version.
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
  "3.10.2"
}
#' `SSURGOPORTAL_GDAL_VERSION()`: returns value of system environment
#'   variable `R_SSURGOPORTAL_GDAL_VERSION` or option `SSURGOPortal.gdal_version`.
#'   If neither are set then returns the version returned by running `gdalinfo --version`
#'   If there is no `gdalinfo` on the path, or other error, the result is `""`
#'   which is handled as no version constraint. If the version is an empty string,
#'   the most recent version of the library will be installed. The latest version
#'   may not be compatible with installed versions of libgdal, etc.
#' @export
#' @rdname ssurgo-env-vars
SSURGOPORTAL_GDAL_VERSION <-  function() {
  s <- Sys.getenv("R_SSURGOPORTAL_GDAL_VERSION", unset = "")
  if (nchar(s) > 0)
    return(s)
  o <- getOption("SSURGOPortal.gdal_version", default = "")
  if (nchar(o) > 0)
    return(o)
  i <- .get_system_gdal_version()
  if (nchar(i) > 0)
    return(i)
  ""
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
.onAttach <- function(libname, pkgname) {
  pyp <- suppressWarnings(normalizePath(ssurgo_portal_python(), "/"))
  ssp <- suppressWarnings(normalizePath(file.path(ssurgo_portal_dir("data"), "SSURGOPortal.pyz"), "/"))
  packageStartupMessage("SSURGOPortal R Interface v",
                        utils::packageVersion("SSURGOPortal"),
                        "\n\tPython: ", ifelse(length(pyp) > 0 && file.exists(pyp),
                                                 pyp, "<not found>"),
                        "\n SSURGO Portal: ", ifelse(length(ssp) > 0 && file.exists(ssp),
                                                       ssp, "<not found>"))
}
