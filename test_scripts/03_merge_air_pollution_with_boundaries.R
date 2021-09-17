# 03_merge_air_pollution_with_boundaries.R
# aim: a simple data input example
# ivanhanigan

message("Running: 03_merge_air_pollution_with_boundaries.R")

tbl_exposures <- raster::extract(r, shp_study_region, fun = mean)

shp_output <- shp_study_region
shp_output@data <- cbind(shp_output@data, tbl_exposures)

writeOGR(
  shp_output,
  out_folder,
  out_file,
  driver = "ESRI Shapefile",
  overwrite_layer = TRUE,
  verbose = TRUE
)
