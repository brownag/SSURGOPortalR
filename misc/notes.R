#### cross-platform/newer GDAL/GEOS notes
#     gdal     proj     geos
#  "3.6.2"  "9.1.1" "3.11.1"
#

# Warning 1: geometry column type in 'sapolygon.shape' is not consistent with type in gpkg_geometry_columns
# Warning 1: A geometry of type MULTIPOLYGON is inserted into layer sapolygon of geometry type POLYGON, which is not normally allowed by the GeoPackage specification, but the driver will however do it. To create a conformant GeoPackage, if using ogr2ogr, the -nlt option can be used to override the layer geometry type. This warning will no longer be emitted for this combination of layer and feature geometry type.


# loadspatialdatawithinsubprocess = TRUE needs additional handling to call the .pyz file via a selected python interpreter
