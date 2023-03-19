#' Download SSURGO Portal .PYZ file from GitHub
#'
#' This routine downloads the latest .pyz file from: \url{https://github.com/ncss-tech/SSURGO-Portal/}
#'
#' @param verbose Show download progress and location of file on successful download? Default `TRUE`
#' @param overwrite Overwrite existing PYZ file? Default: `FALSE`
#' @param timeout Default: `3000` seconds. Temporarily overrides `options()` for `timeout`.
#' @param ... Additional arguments to `download.file()`
#'
#' @return Path to downloaded file, or `try-error` on error.
#' @export
#'
#' @examples
#' \dontrun{
#'  install_ssurgo_portal()
#' }
#' @importFrom utils download.file
install_ssurgo_portal <- function(verbose = TRUE, overwrite = FALSE, timeout = 3000, ...) {

  # TODO: autoupdate link, use release, build pyz from GH source?
  urx <- "https://github.com/ncss-tech/SSURGO-Portal/raw/main/SSURGO%20Portal_03_08_2023.pyz"

  optorig <- getOption("timeout")
  on.exit(options(timeout = optorig))
  options(timeout = 3000)
  dstd <- ssurgo_portal_dir("data")
  dst <- file.path(dstd, "SSURGOPortal.pyz")

  if (!dir.exists(dstd)) {
    dir.create(dstd, recursive = TRUE)
  }

  if (file.exists(dst) && !overwrite) {
    stop("File ", dst, " already exists. Set overwrite=TRUE to proceed anyway.")
  }

  res <- try(download.file(urx, dst, quiet = !verbose, ...))


  if (!inherits(res, 'try-error')) {

    # apply patches if needed
    .apply_crossplatform_patches(res)

    if (verbose) {
      message("Downloaded SSURGO Portal to: ", dst)
    }
    return(invisible(dst))
  }

  message(res[0])
  invisible(res)
}

#' SSURGO Portal User Directories
#'
#' These are standard locations for storing data, config, and cache information for SSURGO Portal outside of the installation in the R package library.
#'
#' @param which One or more of: `"data"`, `"config"`, `"cache"`
#' @return `character`. Path to data, config or cache directories, respectively.
#'
#' @export
#' @rdname ssurgo_portal_dir
#'
#' @examples
#' ssurgo_portal_dir("data")
#' ssurgo_portal_dir("config")
#' ssurgo_portal_dir("cache")
ssurgo_portal_dir <- function(which = "data") {

  which <- match.arg(which,
                     choices = c("data", "config", "cache"),
                     several.ok = TRUE)

  vapply(which, FUN.VALUE = character(1),
         function(w) {
           tools::R_user_dir(package = "SSURGOPortal", which = w)
         })

}

