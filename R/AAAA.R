SSURGOPORTAL_R_DEFAULT_PYTHON_VERSION = "3.10:latest"
SSURGOPORTAL_R_DEFAULT_GDAL_VERSION = "3.7.3"

.has_reticulate <- function() {
    ((nchar(find.package("reticulate", quiet = TRUE)) > 0) &&
       requireNamespace("reticulate"))
}

.onLoad <- function(libname, pkgname) {
  if (.has_reticulate()) {
      n <-  getOption("SSURGOPortalR.virtualenv_name", default = "r-ssurgoportal")
      if (reticulate::virtualenv_exists(n)) {
        o <- getOption("SSURGOPortalR.python_path", default = NULL)
        if (is.null(o)) {
          o <- reticulate::virtualenv_python(n)
        }
      } else {
        o <- create_ssurgo_venv(envname = n,
                                getOption("SSURGOPortalR.python_version",
                                          default = SSURGOPORTAL_R_DEFAULT_PYTHON_VERSION),
                                getOption("SSURGOPortalR.gdal_version",
                                          default = SSURGOPORTAL_R_DEFAULT_GDAL_VERSION))
      }
      options(SSURGOPortalR.python_path = o)
  } else {
    options(SSURGOPortalR.virtualenv_name = "")
    options(SSURGOPortalR.python_path = .find_python(""))
  }
}
