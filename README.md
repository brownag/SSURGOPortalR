
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SSURGOPortal

<!-- badges: start -->

[![R-CMD-check](https://github.com/brownag/SSURGOPortalR/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/brownag/SSURGOPortalR/actions/workflows/R-CMD-check.yml)
<!-- badges: end -->

The goal of SSURGOPortal is to provide a simple R interface to the
‘SSURGO Portal’ Python tools. Providing an R wrapper around the SSURGO
Portal API allows users to automate many of the operations they might
normally achieve through the graphical user interface.

## Installation

You can install the development version of {SSURGOPortal} like so:

``` r
remotes::install_github("brownag/SSURGOPortalR")
```

## Example

This is example shows how to install the .PYZ file to a standard
location:

``` r
library(SSURGOPortal)
```

``` r
install_ssurgo_portal()
```

The above installation routine places the SSURGO Portal file in a
platform-specific folder: `ssurgo_portal_dir("data")`

To verify everything is set up and working, we can send the
`"getstatus"` command, like so:

``` r
ssurgo_portal("getstatus")
#> $status
#> [1] TRUE
#> 
#> $message
#> [1] "It\"s alive! runmode=RunMode.DATA_LOADER, isPyz=True, __file__=C:\\Users\\Andrew.G.Brown\\AppData\\Roaming\\R\\data\\R\\SSURGOPortal\\SSURGOPortal.pyz\\dlcore\\dlutilities.py, currentPath=C:\\Users\\Andrew.G.Brown\\AppData\\Roaming\\R\\data\\R\\SSURGOPortal"
#> 
#> $elapsedseconds
#> [1] 0
```

See the documentation for `ssurgo_portal()` (`?ssurgo_portal`) for other
available commands and more examples.

In general, a command is structured as JSON with a specific request name
and various other parameters. This JSON string is passed via the
terminal to the .pyz file and Python interpreter.

We can inspect the commands that are generated using `command_only=TRUE`

For example, here is a sample `"copytemplate"` request to create a new
GeoPackage database called `"test.gpkg"` from a template:

``` r
ssurgo_portal("copytemplate", 
              templatename = "GeoPackage", 
              folder = "sample_gpkg", 
              filename = "test", 
              overwrite = TRUE, 
              command_only = TRUE)
#> [1] "cmd /c echo {\"request\":\"copytemplatefile\",\"templatename\":\"GeoPackage\",\"folder\":\"sample_gpkg\",\"filename\":\"test\",\"overwrite\":true} | \"C:\\PROGRA~1\\PYTHON~1\\python.exe\" \"C:\\Users\\Andrew.G.Brown\\AppData\\Roaming/R/data/R/SSURGOPortal/SSURGOPortal.pyz\" @"
```

Now after inspecting the command, we can actually run it:

``` r
ssurgo_portal("copytemplate", 
              templatename = "GeoPackage", 
              folder = "sample_gpkg", 
              filename = "test", 
              overwrite = TRUE)
#> $status
#> [1] TRUE
#> 
#> $message
#> [1] "Copied templates/geopackage.gpkg to sample_gpkg\\test.gpkg"
#> 
#> $elapsedseconds
#> [1] 0
```

## Download and Import Data

Using the {soilDB} package SSURGO data for input into template databases
can easily be downloaded. For example here we specify a generic `WHERE`
clause used against the `sacatalog` table in Soil Data Access.

``` r
td <- file.path(tempdir(), "ssurgo_test")

download_ssurgo("areasymbol LIKE 'RI%'", exdir = td)
```

In this instance the wildcard only returns a single survey, `"RI600"`,
but this pattern could be used in other areas to download multiple
surveys within a state (without explicitly knowing their `areasymbol`).

After downloading and extracting soil survey area data to a temporary
directory, we can “pretest” them as candidates for import into the
template.

``` r
ssurgo_portal(
  "pretestimportcandidates",
  database = "sample_gpkg/test.gpkg",
  root = td,
  istabularonly = FALSE
)
```

If everything looks good, we can go ahead with the import. For this we
use the `"importcandidates"` request.

``` r
ssurgo_portal(
  "importcandidates",
  database = "sample_gpkg/test.gpkg",
  root = td,
  istabularonly = FALSE,
  skippretest = TRUE,
  subfolders = c("RI600"),
  loadinspatialorder = FALSE,
  loadspatialdatawithinsubprocess = FALSE,
  dissolvemupolygon = FALSE
)
```

## Python Versions Supported

There are built in routines and binaries for running the tool on Windows
with Python 3.9 or 3.10. If using a different version of Python you will
need to be sure the required modules are installed prior to running
`ssurgo_portal()`.

## Python Dependencies

To prepare your Python system or virtual environment, run
`python -m pip install bottle gdal jsonschema` (or similar) to make sure
that the required modules are already installed before invoking the
SSURGO Portal tools.

## Cross-platform Support

This package applies patches to attempt to make the .PYZ contents
minimally compatible with Linux and macOS. This feature is experimental
and intended to provide feedback for future development. If these
patches are not included the initialization routine will be triggered on
non-Windows platforms.

This routine only installs the bundled Windows wheel (.whl) files; it
should be expected to fail on all other platforms and Python versions
other than 3.9 and 3.10.

If you encounter other problems on non-Windows platforms, file an issue
in the [issue
tracker](https://github.com/brownag/SSSURGOPortalR/issues).
