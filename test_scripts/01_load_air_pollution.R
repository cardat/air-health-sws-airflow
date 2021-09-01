# 01_load_air_pollution.R
# aim: a simple data input example
# ivanhanigan

message("Running: 01_load_air_pollution.R")

library(rgdal)
library(raster)

indir_expo <- here("data_demo", "air_pollution")

infile_expo <- "GlobalGWRwUni_PM25_GL_201601_201612-RH35-NoNegs_AUS_20180618.tif"

r <- raster(here(indir_expo, infile_expo))
