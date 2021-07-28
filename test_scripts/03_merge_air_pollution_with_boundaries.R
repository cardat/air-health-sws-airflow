# 03_merge_air_pollution_with_boundaries.R
# aim: a simple data input example
# ivanhanigan


tbl_exposures <- raster::extract(r, shp_study_region, fun = mean)

shp_output <- shp_study_region
shp_output@data <- cbind(shp_output@data, tbl_exposures)

writeOGR(shp_output, "data_derived", "shp_output", driver = "ESRI Shapefile", overwrite_layer = TRUE)
