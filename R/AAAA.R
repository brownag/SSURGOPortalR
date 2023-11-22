SSURGOPORTAL_R_PYTHON_VERSION <- function() {
  s <- Sys.getenv("R_SSURGOPORTAL_PYTHON_VERSION", unset = "")
  if (nchar(s) > 0)
    return(s)
  o <- getOption("SSURGOPortalR.python_version", default = "")
  if (nchar(o) > 0)
    return(o)
  "3.10:latest"
}

SSURGOPORTAL_R_GDAL_VERSION <-  function() {
  s <- Sys.getenv("R_SSURGOPORTAL_GDAL_VERSION", unset = "")
  if (nchar(s) > 0)
    return(s)
  o <- getOption("SSURGOPortalR.gdal_version", default = "")
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
  pyp <- normalizePath(ssurgo_portal_python(), "/")
  ssp <- normalizePath(file.path(ssurgo_portal_dir("data"), "SSURGOPortal.pyz"), "/")
  packageStartupMessage("SSURGOPortal R Interface v",
                        utils::packageVersion("SSURGOPortal"),
                        "\n\tPython: ", ifelse(length(pyp) > 0 && file.exists(pyp),
                                                 pyp, "<not found>"),
                        "\n SSURGO Portal: ", ifelse(length(ssp) > 0 && file.exists(ssp),
                                                       ssp, "<not found>"))
}
