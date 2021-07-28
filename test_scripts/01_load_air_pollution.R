# 01_load_air_pollution.R
# aim: a simple data input example
# ivanhanigan


if(!require("rgdal")) install.packages("rgdal"); library(rgdal)

if(!require("raster")) install.packages("raster"); library(raster)

indir_expo <- "data_demo/air_pollution"

infile_expo <- "GlobalGWRwUni_PM25_GL_201601_201612-RH35-NoNegs_AUS_20180618.tif"

r <- raster(file.path(indir_expo, infile_expo))
