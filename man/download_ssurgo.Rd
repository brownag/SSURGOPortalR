% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download_ssurgo.R
\name{download_ssurgo}
\alias{download_ssurgo}
\title{Get SSURGO ZIP files from Web Soil Survey 'Download Soils Data'}
\usage{
download_ssurgo(
  WHERE = NULL,
  areasymbols = NULL,
  destdir = tempdir(),
  exdir = destdir,
  include_template = FALSE,
  extract = TRUE,
  remove_zip = FALSE,
  overwrite = FALSE,
  quiet = FALSE
)
}
\arguments{
\item{WHERE}{A SQL `WHERE` clause expression used to filter records in `sacatalog` table. Alternately `WHERE` can be any spatial object supported by `SDA_spatialQuery()` for defining the target extent.}

\item{areasymbols}{Character vector of soil survey area symbols e.g. `c("CA067", "CA077")`. Used in lieu of `WHERE` argument.}

\item{destdir}{Directory to download ZIP files into. Default `tempdir()`.}

\item{exdir}{Directory to extract ZIP archives into. May be a directory that does not yet exist. Each ZIP file will extract to a folder labeled with `areasymbol` in this directory. Default: `destdir`}

\item{include_template}{Include the (possibly state-specific) MS Access template database? Default: `FALSE`}

\item{extract}{Logical. Extract ZIP files to `exdir`? Default: `TRUE`}

\item{remove_zip}{Logical. Remove ZIP files after extracting? Default: `FALSE`}

\item{overwrite}{Logical. Overwrite by re-extracting if directory already exists? Default: `FALSE`}

\item{quiet}{Logical. Passed to `curl::curl_download()`.}
}
\value{
Character. Paths to downloaded ZIP files (invisibly). May not exist if `remove_zip=TRUE`.
}
\description{
Download ZIP files containing spatial (ESRI shapefile) and tabular (TXT) files with standard SSURGO format; optionally including the corresponding SSURGO Template Database with `include_template=TRUE`.
}
\details{
To specify the Soil Survey Areas you would like to obtain data you use a `WHERE` clause for query of `sacatalog` table such as `areasymbol = 'CA067'`, `"areasymbol IN ('CA628', 'CA067')"` or  `areasymbol LIKE 'CT%'`.

Pipe-delimited TXT files are found in _/tabular/_ folder extracted from a SSURGO ZIP. The files are named for tables in the SSURGO schema. There is no header / the files do not have column names. See the _Soil Data Access Tables and Columns Report_: \url{https://sdmdataaccess.nrcs.usda.gov/documents/TablesAndColumnsReport.pdf} for details on tables, column names and metadata including the default sequence of columns used in TXT files. The function returns a `try-error` if the `WHERE`/`areasymbols` arguments result in

Several ESRI shapefiles are found in the _/spatial/_ folder extracted from a SSURGO ZIP. These have prefix `soilmu_` (mapunit), `soilsa_` (survey area), `soilsf_` (special features). There will also be a TXT file with prefix `soilsf_` describing any special features. Shapefile names then have an `a_` (polygon), `l_` (line), `p_` (point) followed by the soil survey area symbol.
}
