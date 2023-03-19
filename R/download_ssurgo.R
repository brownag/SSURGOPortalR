#' Get SSURGO ZIP files from Web Soil Survey 'Download Soils Data'
#'
#' Download ZIP files containing spatial (ESRI shapefile) and tabular (TXT) files with standard SSURGO format; optionally including the corresponding SSURGO Template Database with `include_template=TRUE`.
#'
#' To specify the Soil Survey Areas you would like to obtain data you use a `WHERE` clause for query of `sacatalog` table such as `areasymbol = 'CA067'`, `"areasymbol IN ('CA628', 'CA067')"` or  `areasymbol LIKE 'CT%'`.
#'
#' @param WHERE A SQL `WHERE` clause expression used to filter records in `sacatalog` table. Alternately `WHERE` can be any spatial object supported by `SDA_spatialQuery()` for defining the target extent.
#' @param areasymbols Character vector of soil survey area symbols e.g. `c("CA067", "CA077")`. Used in lieu of `WHERE` argument.
#' @param destdir Directory to download ZIP files into. Default `tempdir()`.
#' @param exdir Directory to extract ZIP archives into. May be a directory that does not yet exist. Each ZIP file will extract to a folder labeled with `areasymbol` in this directory. Default: `destdir`
#' @param include_template Include the (possibly state-specific) MS Access template database? Default: `FALSE`
#' @param extract Logical. Extract ZIP files to `exdir`? Default: `TRUE`
#' @param remove_zip Logical. Remove ZIP files after extracting? Default: `FALSE`
#' @param overwrite Logical. Overwrite by re-extracting if directory already exists? Default: `FALSE`
#' @param quiet Logical. Passed to `curl::curl_download()`.
#' @export
#'
#' @details Pipe-delimited TXT files are found in _/tabular/_ folder extracted from a SSURGO ZIP. The files are named for tables in the SSURGO schema. There is no header / the files do not have column names. See the _Soil Data Access Tables and Columns Report_: \url{https://sdmdataaccess.nrcs.usda.gov/documents/TablesAndColumnsReport.pdf} for details on tables, column names and metadata including the default sequence of columns used in TXT files. The function returns a `try-error` if the `WHERE`/`areasymbols` arguments result in
#'
#' Several ESRI shapefiles are found in the _/spatial/_ folder extracted from a SSURGO ZIP. These have prefix `soilmu_` (mapunit), `soilsa_` (survey area), `soilsf_` (special features). There will also be a TXT file with prefix `soilsf_` describing any special features. Shapefile names then have an `a_` (polygon), `l_` (line), `p_` (point) followed by the soil survey area symbol.
#'
#' @return Character. Paths to downloaded ZIP files (invisibly). May not exist if `remove_zip=TRUE`.
download_ssurgo <- function(WHERE = NULL,
                            areasymbols = NULL,
                            destdir = tempdir(),
                            exdir = destdir,
                            include_template = FALSE,
                            extract = TRUE,
                            remove_zip = FALSE,
                            overwrite = FALSE,
                            quiet = FALSE) {

  if (!requireNamespace("soilDB")) {
    stop("package 'soilDB' is required to query the Soil Survey Area catalog", call. = FALSE)
  }

  try(soilDB::downloadSSURGO(
    WHERE = WHERE,
    areasymbols = areasymbols,
    destdir = destdir,
    exdir = exdir,
    include_template = include_template,
    extract = extract,
    remove_zip = remove_zip,
    overwrite = overwrite,
    quiet = quiet
  ), silent = quiet)
}
