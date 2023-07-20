#' @importFrom utils unzip
.apply_pyz_patches <- function(pyz, verbose) {

  # this function is invoked to apply patches to the downloaded .pyz file
  wd <- ssurgo_portal_dir("data")
  scd <- file.path(wd, "SSURGO-Portal")
  if (!dir.exists(scd)) {
    dir.create(scd, showWarnings = FALSE, recursive = TRUE)
  }

  #### EXTRACT .PYZ contents ----
  utils::unzip(file.path(wd, "SSURGOPortal.pyz"), exdir = scd)

  #### PATCH initializer.py ----
  # remove constraints on python version
  inpy <- file.path(scd, "utilities", "initializer.py")
  x <- readLines(inpy, warn = FALSE)
  x <- gsub("False, f'Invalid Python version found: {sys.version}'",
              "f'{sys.version}', False", x, fixed = TRUE)
  writeLines(x, inpy)

  if (Sys.info()["sysname"] != "Windows") {

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

    #### PATCH dataloader.py ----
    dlpy <- file.path(scd, "dlcore", "dataloader.py")
    x <- readLines(dlpy, warn = FALSE)
    # use lowercase areasymbol in dataloader .shp paths
    x <- gsub("(\\+ +)(areasym|ssaName|ssa)( *\\+*)", "\\1\\2.lower()\\3", x)
    x <- gsub("return  (None, None, None, None, None)",
              "return  (None, None, None, None, None, None, None)",
              x, fixed = TRUE)
    writeLines(x, dlpy)

  }

  #### REBUILD .PYZ file ----
  system(paste0(.find_python(), " -m zipapp ", shQuote(scd)), intern = TRUE)
  file.copy(
    file.path(wd, "SSURGO-Portal.pyz"),
    file.path(wd, "SSURGOPortal.pyz"),
    overwrite = TRUE
  )
  unlink(scd, recursive = TRUE, force = TRUE)
  if (verbose) {
    message(
      "SSURGO Portal cross-platform patches have been applied"
    )
  }
  file.remove(file.path(wd, "SSURGO-Portal.pyz"))
}
