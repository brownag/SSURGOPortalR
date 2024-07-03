# SSURGOPortal 0.0.5

* Add error handling for cases when a virtual environment cannot be used. Also, add instructions to README to indicate how to disable the default virtual environment behavior on USDA machines that lack administrative priveliges/ability to execute arbitrary python binaries.

# SSURGOPortal 0.0.4

* Added `create_ssurgo_venv()` and added support for using custom virtual environment python executables to run the SSURGOPortal .pyz. Uses {reticulate} to manage installation of Python, creation of virtual environments, installation of dependencies, etc.

# SSURGOPortal 0.0.3

* `install_ssurgo_portal()`: Updated to Web Soil Survey as source URL for beta version of SSURGO Portal .PYZ file  <https://websoilsurvey.sc.egov.usda.gov/DSD/Download/SsurgoPortal/SSURGO_Portal.zip>

# SSURGOPortal 0.0.2

* `install_ssurgo_portal()` gains `src` argument to specify URL source of .PYZ for install

* .PYZ files are now automatically patched to remove Python version limit

  * On Python versions other than 3.9 and 3.10 the user is responsible for installing the necessary dependencies: `gdal`, `bottle`, and `jsonschema`. I.e. `python -m pip install gdal bottle jsonschema`
  
  * Note that some pre-compiled wheel files are available for Windows (https://www.lfd.uci.edu/~gohlke/pythonlibs/) which can help if you encounter issues building `gdal`.

# SSURGOPortal 0.0.1

* Initial R package paired with alpha release of "SSURGO Portal"

* Added experimental patches for use of "SSURGO Portal" on macOS and Linux.
