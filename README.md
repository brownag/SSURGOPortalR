
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SSURGOPortal

<!-- badges: start -->
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
              folder = "test", 
              filename = "test.gpkg", 
              overwrite = TRUE, 
              command_only = TRUE)
#> [1] "cmd /c echo {\"request\":\"copytemplatefile\",\"templatename\":\"GeoPackage\",\"folder\":\"test\",\"filename\":\"test.gpkg\",\"overwrite\":true} | '/home/andrew/.virtualenvs/r-reticulate/bin/python' '/home/andrew/.local/share/R/SSURGOPortal/SSURGOPortal.pyz' @"
```
