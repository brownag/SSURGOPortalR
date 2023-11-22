SSURGOPORTAL_R_DEFAULT_PYTHON_VERSION <- function() {
  s <- Sys.getenv("SSURGOPORTAL_R_DEFAULT_PYTHON_VERSION", unset = "")
  if (nchar(s) > 0)
    return(s)
  o <- getOption("SSURGOPortalR.python_version", default = "")
  if (nchar(o) > 0)
    return(o)
  "3.10:latest"
}

SSURGOPORTAL_R_DEFAULT_GDAL_VERSION <-  function() {
  s <- Sys.getenv("SSURGOPORTAL_R_DEFAULT_GDAL_VERSION", unset = "")
  if (nchar(s) > 0)
    return(s)
  o <- getOption("SSURGOPortalR.gdal_version", default = "")
  if (nchar(o) > 0)
    return(o)
  "3.7.3"
}

.has_reticulate <- function() {
  ((length(find.package("reticulate", quiet = TRUE)) > 0) &&
     !inherits(try(requireNamespace("reticulate", quietly = TRUE)), 'try-error'))
}

.onLoad <- function(libname, pkgname) {
  pyp <- ssurgo_portal_python()
  ssp <- file.path(ssurgo_portal_dir("data"), "SSURGOPortal.pyz")
  packageStartupMessage("SSURGOPortal R Interface v",
                        packageVersion("SSURGOPortal"),
                        "\n\tPython: ", ifelse(length(pyp) > 0 && file.exists(pyp),
                                                 pyp, "<not found>"),
                        "\n SSURGO Portal: ", ifelse(length(ssp) > 0 && file.exists(ssp),
                                                       ssp, "<not found>"))
}
