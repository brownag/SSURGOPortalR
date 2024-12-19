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
#' |importspatialdata       |For internal use only. Import SSURGO spatial data from shapefiles under a specified path. Note that this activity is isolated to support its use in a child process.   |
#' |getrecordlistbytable    |Retrieve table rows for a specified table                                                                                                                              |
#' |generaterasters         |Generate rasters of the mupolygon dataset in the user specified SSURGO Template Database.                                                                              |
#' |logjavascripterror      |Write an error to the log file                                                                                                |
#' |getsdvattributesbyfolder|Get Soil Data Viewer attributes                                                                                                                                        |
#' |getsdvratingoptions     |Get Soil Data Viewer rating options                                                                                                                                    |
#' |generateaggregation     |Generate an aggregation                                                                                                                                                |
#' |sortratingtable         |Sort a rating table by a specified column name                                                                                                                         |
#' |exportratingresults     |Export rating results                                                                                                                                                  |
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
      ssurgo_portal_python(),
      pyz_path
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
                                  "importspatialdata",
                                  "getrecordlistbytable",
                                  "generaterasters",
                                  "logjavascripterror",
                                  "getsdvattributesbyfolder",
                                  "getsdvratingoptions",
                                  "generateaggregation",
                                  "sortratingtable",
                                  "exportratingresults"))

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

  py_path <- ssurgo_portal_python()

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

.python_can_run <- function(x) {
  (is.character(x) && length(x) == 1 &&
     file.exists(x) &&
       !inherits(system2(x, "--version", stdout = TRUE), 'try-error'))
}

#' @importFrom reticulate virtualenv_exists virtualenv_python condaenv_exists conda_python use_python
#' @importFrom utils tail
.find_python <- function(envname = "r-ssurgoportal", conda = FALSE) {

  # system python path
  py_path <- Sys.which("python")

  if (nchar(py_path) == 0) {
    py_path <- Sys.which("python3")
  }

  .ssurgo_portal_debug("system python is", shQuote(normalizePath(py_path, winslash = "/"), type = "sh"))

  n <- getOption("SSURGOPortal.virtualenv_name", default = envname)
  o <- getOption("SSURGOPortal.python_path", default = py_path)

  use_reticulate <- .has_reticulate()

  # expanded for debugging
  if (nchar(n) == 0) {
    .ssurgo_portal_debug("SSURGOPortal.virtualenv_name is empty")
    o <- py_path
  }
  if (!use_reticulate) {
    .ssurgo_portal_debug("reticulate is not available")
    o <- py_path
  }
  if (!file.exists(o)) {
    .ssurgo_portal_debug("path does not exist: ", shQuote(normalizePath(o, winslash = "/"), type = "sh"))
    o <- py_path
  }

  # make sure reticulate uses the venv python if it exists
  # _and_ we can execute it in current location (not guaranteed!!)
  if (use_reticulate) {
    # TODO: detect if user is using conda? easy opt in?
    if (conda && reticulate::condaenv_exists(envname = n)) {
      cpy_path <- utils::tail(reticulate::conda_python(envname = n), 1)
      if (.python_can_run(cpy_path)) {
        o <- cpy_path
        attr(o, 'exists') <- TRUE
        attr(o, 'executable') <- TRUE
      }
    } else {
      vpy_path <- utils::tail(reticulate::virtualenv_python(envname = n), 1)
      if (.python_can_run(vpy_path)) {
        o <- vpy_path
        attr(o, 'exists') <- TRUE
        attr(o, 'executable') <- TRUE
      }
    }
  }

  .ssurgo_portal_debug("using python", shQuote(normalizePath(o, winslash = "/"), type = "sh"))

  options(SSURGOPortal.python_path = o)
  o
}


.syscall <- function(cmd) {
  res <- try(system(
    cmd,
    wait = FALSE,
    intern = TRUE,
    ignore.stdout = FALSE,
    ignore.stderr = FALSE,
    input = c("p", "\r")
  ), silent = FALSE)
  # # use message so it can be suppressMessages()'d
  # message(paste0(res, collapse = "\n"))
  res
}
