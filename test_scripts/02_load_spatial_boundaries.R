# 02_load_spatial_boundaries.R
# aim: a simple data input example
# ivanhanigan

message("Running: 02_load_spatial_boundaries.R")

indir_spat <- here("data_demo", "spatial_boundaries")

infile_spat <- "sa22016_case_studyV2.shp"

shp_study_region <- readOGR(file.path(indir_spat, infile_spat))
