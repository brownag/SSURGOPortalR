#' Generate Requests for 'SSURGO Portal' Data Loader
#'
#' Generate commands for the 'SSURGO Portal' Data Loader command-line interface, and parse resulting JSON output.
#'
#' @param request One of the available request types, see Details.
#' @param pyz_path Path to "SSURGO Portal" .pyz file. Default `"SSURGOPortal.pyz"` in `ssurgo_portal_dir("data")` directory.
#' @param ... Additional parameters for `request`
#' @param schema Return request and response schemas? Default: `FALSE`
#' @param command_only Return command string rather than executing it? Default: `FALSE`
#'
#' @details
#' |Request Name            |Description                                                                                                                                                            |
#' |:-----------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
#' |getstatus               |Quick check for application responsiveness                                                                                                                             |
#' |getusage                |Return usage information in payload.                                                                                                                                   |
#' |getwindowsdriveletters  |Return all drive letters (only valid for Microsoft Windows)                                                                                                            |
#' |getfoldertree           |Returns a file system tree.                                                                                                                                            |
#' |gettemplatecatalog      |Returns JSON containing information about all available empty SSURGO SQLite templates.                                                                                 |
#' |copytemplatefile        |Copies a template file to a specified folder path and name.                                                                                                            |
#' |opentemplate            |Opens a SQLite file to confirm that it meets certain minimal criteria.                                                                                                 |
#' |getdatabaseinventory    |List survey areas and related data within a SQLite database.                                                                                                           |
#' |deleteareasymbols       |Delete the specified areasymbols from the database.                                                                                                                    |
#' |pretestimportcandidates |Perform a 'pre-test' on subfolders under a root folder.                                                                                                                |
#' |importcandidates        |Import SSURGO data from subfolders under a root folder. The import terminates if any folder fails.                                                                     |
#' |importspatialdata       |For internal use only. Import SSURGO spatial data from shapefiles under a specified path. Note that this activity is isolated to support its use in a child process. |
#'
#' @return A `list` object corresponding to the JSON response. `NULL` (invisibly) on error along with any other standard output from the tool printed to the console.
#' @export
#'
#' @examples
#' \dontrun{
#' ssurgo_portal("getstatus")
#'
#' ssurgo_portal("getstatus", schema = TRUE)
#'
#' ssurgo_portal(
#'   "getfoldertree",
#'   path = "C:/SSURGO Portal/WV",
#'   folderpattern = "WV",
#'   filepattern = "txt",
#'   ignorefoldercase = TRUE,
#'   ignorefilecase = TRUE,
#'   showfiles = FALSE,
#'   maxdepth = 2
#' )
#'
#' ssurgo_portal("gettemplatecatalog")
#'
#' ssurgo_portal(
#'   "copytemplate",
#'   templatename = "GeoPackage",
#'   folder = "test",
#'   filename = "test.gpkg",
#'   overwrite = TRUE
#' )
#'
#' dbp <- "C:/SSURGO Portal/Databases/West_Virginia_Geopackage.gpkg"
#'
#' ssurgo_portal("opentemplate", database = dbp)
#'
#' ssurgo_portal(
#'   "pretestimportcandidates",
#'   database = dbp,
#'   root = "C:/SSURGO Portal/WV",
#'   istabularonly = FALSE
#' )
#'
#' ssurgo_portal(
#'   "importcandidates",
#'   database = dbp,
#'   root = "C:/SSURGO Portal/WV",
#'   istabularonly = FALSE,
#'   skippretest = TRUE,
#'   subfolders = list("WV603"),
#'   loadinspatialorder = FALSE,
#'   loadspatialdatawithinsubprocess = TRUE,
#'   dissolvemupolygon = TRUE
#' )
#'
#' ssurgo_portal("getdatabaseinventory", database = dbp)
#'
#' ssurgo_portal("deleteareasymbols",
#'               database = dbp,
#'               areasymbols = list("WV603"))
#' }
#' @importFrom jsonlite fromJSON toJSON
ssurgo_portal <- function(request = NULL,
                          pyz_path = file.path(ssurgo_portal_dir("data"), "SSURGOPortal.pyz"),
                          ...,
                          schema = FALSE,
                          command_only = FALSE) {

  # launch GUI
  if (missing(request) || is.null(request)) {

    cmd <- paste0(shQuote(c(
      .find_python(),
      file.path(ssurgo_portal_dir("data"), "SSURGOPortal.pyz")
    )), collapse = ' ')

    if (command_only) {
      return(cmd)
    }

    return(invisible(.syscall(cmd)))
  }

  request <- match.arg(request, c("getstatus",
                                  "getusage",
                                  "getwindowsdriveletters",
                                  "getfoldertree",
                                  "gettemplatecatalog",
                                  "copytemplatefile",
                                  "opentemplate",
                                  "getdatabaseinventory",
                                  "deleteareasymbols",
                                  "pretestimportcandidates",
                                  "importcandidates",
                                  "importspatialdata"))

  req <- list(request = request, ...)

  # normalize paths
  if (!is.null(req$database)) {
    req$database <- normalizePath(req$database)
  }

  if (!is.null(req$root)) {
    req$root <- normalizePath(req$root)
  }

  # allow vector of subfolders rather than list
  if (!is.null(req$subfolders) && !is.list(req$subfolders)) {
    req$subfolders <- as.list(req$subfolders)
  }

  py_path <- .find_python()

  # additional arguments (...) are passed in JSON w/ request type
  if (schema) {
    args <- paste0("?", request)
    cmd <- paste0(shQuote(py_path), " ", shQuote(pyz_path), " ", args)
  } else {
    args <- jsonlite::toJSON(req, auto_unbox = TRUE)

    winbase <- ""
    if (Sys.info()["sysname"] == "Windows") {
      winbase <- "cmd /c "
    } else {
      args <- shQuote(args)
    }
    cmd <- paste0(winbase, "echo ", args, " | ", shQuote(py_path), " ", shQuote(pyz_path), " @")
  }

  # short-circuit
  if (command_only) {
    return(cmd)
  }

  # execute and capture output
  res <- .syscall(cmd)

  # for PYZ ? requests (schema=TRUE)
  i <- grep("^(Request|Response) schema for", res)

  # process error message
  .procerr <- function(x) {
    e <- strsplit(x, "\n")[[1]]
    # fix booleans
    e <- gsub("True", "true", gsub("False", "false", e))

    # find multiline strings
    m0 <- grep('\"$', e)
    m <- unique(sort(c(m0, m0 + 1)))
    g0 <- c(2, diff(m)) > 1
    g <- cumsum(g0)

    # combine multiline strings
    h <- gsub('\"\"', '', sapply(split(e[m], g), function(y) paste0(trimws(y), collapse = "")))

    # replace first element from original error string
    e[m0[c(2, diff(m0)) > 1]] <- h

    # remove subsequent elements
    e <- e[-m[c(2, diff(m)) == 1]]

    # parse out schema and instance json blocks
    i <- grep("in schema:$", e)
    j <- grep("^On instance:$", e)

    # this happens for unhandled exceptions in the code
    # as opposed to the schema of the JSON error messages
    if (length(i) == 0 || length(j) == 0) {
      return(list(message = x,
                  schema = NULL,
                  instance = NULL))
    }

    # return as list
    list(
      message = e[1],
      schema = jsonlite::fromJSON(paste0(e[(i + 1):(j - 1)], collapse = "\n"), simplifyVector = FALSE),
      instance = jsonlite::fromJSON(paste0(e[(j + 1):length(e)], collapse = "\n"), simplifyVector = FALSE)
    )
  }

  if (length(res) > 0 && startsWith(res[1], "{") && length(i) < 2) {
    tmp1 <- gsub("\\r", "\\\\n", res)
    tmp2 <- gsub("'", '\\\\"', paste0(tmp1[nchar(trimws(tmp1)) > 0], collapse = ""))
    resjson <- jsonlite::fromJSON(tmp2, simplifyVector = FALSE)
    if (!is.null(resjson$errormessage)) {
      pe <- .procerr(resjson$errormessage)
      cat(paste0(resjson$message, ": ", pe$message, sep = "\n"))
      return(invisible(pe))
    }
    return(resjson)
  } else if (schema && length(i) == 2) {
    # get request and response schemas
    return(list(
      request = jsonlite::fromJSON(res[(i[1] + 1):(i[2] - 1)], simplifyVector = FALSE),
      response = jsonlite::fromJSON(res[(i[2] + 1):length(res)], simplifyVector = FALSE)
    )
    )
  } else {
    cat(res, sep = "\n")
    return(invisible(NULL))
  }
}

.find_python <- function(envname = "r-ssurgoportal",
                         python_version = SSURGOPORTAL_R_PYTHON_VERSION(),
                         gdal_version   = SSURGOPORTAL_R_GDAL_VERSION(), ...) {

  n <- getOption("SSURGOPortalR.virtualenv_name", default = envname)
  o <- getOption("SSURGOPortalR.python_path", default = "")

  # system python path
  py_path <- Sys.which("python")
  if (nchar(py_path) == 0) {
    py_path <- Sys.which("python3")
  }

  use_reticulate <- .has_reticulate()

  if (nchar(n) == 0 || !use_reticulate || !file.exists(o)) {
    o <- py_path
  }

  if (use_reticulate && reticulate::virtualenv_exists(n)) {
    vpy_path <- reticulate::virtualenv_python(envname = n)
    if (!file.exists(vpy_path)) {
      o <- py_path
    } else {
      o <- vpy_path
    }
  }

  options(SSURGOPortalR.python_path = o)[[1]]
}


.syscall <- function(cmd) {
  system(cmd,
         wait = FALSE,
         intern = TRUE,
         ignore.stdout = FALSE,
         ignore.stderr = FALSE,
         input = c("p", "\r"))
}
