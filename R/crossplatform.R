.apply_crossplatform_patches <- function(pyz) {
  # if not on Windows, this function is invoked to apply patches to the downloaded .pyz file
  # TODO: add to R package

  if (Sys.info()["sysname"] != "Windows") {
    warning("SSURGO Portal cross-platform patches have not been applied; this tool does not currently work on Linux/macOS", call. = FALSE)
  }
}
