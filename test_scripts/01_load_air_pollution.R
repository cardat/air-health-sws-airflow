# 01_load_air_pollution.R
# aim: a simple data input example
# ivanhanigan

message("Running: 01_load_air_pollution.R")

library(rgdal)
library(raster)

r <- raster(infile_expo)
