#' @importFrom utils unzip
.apply_crossplatform_patches <- function(pyz) {
  # if not on Windows, this function is invoked
  # to apply patches to the downloaded .pyz file
  if (Sys.info()["sysname"] != "Windows") {

    wd <- ssurgo_portal_dir("data")
    scd <- file.path(wd, "SSURGO-Portal")

    if (!dir.exists(scd)) {
      dir.create(scd, showWarnings = FALSE, recursive = TRUE)
    }


    #### EXTRACT .PYZ contents ----
    utils::unzip(file.path(wd, "SSURGOPortal.pyz"), exdir = scd)

    #### PATCH main.py ----

    mainpy <- file.path(scd, "main.py")
    x <- readLines(mainpy, warn = FALSE)

    # comment out usage of ctypes.windll
    # (alternately move idx1 to after idx2 to make usage conditional)
    idx1 <- grep("from ctypes import windll", x, fixed = TRUE)
    idx2 <- grep("if config.osType == \"nt\":", x, fixed = TRUE)
    idx <- c(idx1, idx2, idx2 + 1:2)

    if (length(idx) > 0) {
      x[idx] <- paste0("# ", x[idx])
    }
    writeLines(x, mainpy)


    #### REBUILD .PYZ file ----
    system(paste0(.find_python(), " -m zipapp ", shQuote(scd)), intern = TRUE)
    file.copy(
      file.path(wd, "SSURGO-Portal.pyz"),
      file.path(wd, "SSURGOPortal.pyz"),
      overwrite = TRUE
    )

    if (all(unlink(scd, recursive = TRUE, force = TRUE))) {
      message(
        "SSURGO Portal cross-platform patches have been applied\n
        NOTE: usage on Linux/macOS is experimental",
        call. = FALSE
      )
    }
  }
}
