# SSURGOPortal 0.0.2

* `install_ssurgo_portal()` gains `src` argument to specify URL source of .PYZ for install

* .PYZ files are now automatically patched to remove Python version limit

  * On Python versions other than 3.9 and 3.10 the user is responsible for installing the necessary dependencies: `gdal`, `bottle`, and `jsonschema`. I.e. `python -m pip install gdal bottle jsonschema`
  
  * Note that some pre-compiled wheel files are available for Windows (https://www.lfd.uci.edu/~gohlke/pythonlibs/) which can help if you encounter issues building `gdal`.

# SSURGOPortal 0.0.1

* Initial R package paired with alpha release of "SSURGO Portal"

* Added experimental patches for use of "SSURGO Portal" on macOS and Linux.
