# 02_load_spatial_boundaries.R
# aim: a simple data input example
# ivanhanigan

message("Running: 02_load_spatial_boundaries.R")


shp_study_region <- readOGR(infile_spat)
