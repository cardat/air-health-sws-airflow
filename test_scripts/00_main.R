# 00_main.R
# aim: a simple data input example
# ivanhanigan

library(here)

message("Running: 00_main.R")

source(here("test_scripts", "01_load_air_pollution.R"))
source(here("test_scripts", "02_load_spatial_boundaries.R"))
source(here("test_scripts", "03_merge_air_pollution_with_boundaries.R"))
