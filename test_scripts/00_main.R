# 00_main.R
# aim: a simple data input example
# ivanhanigan
message("Running: 00_main.R")

library(here)
library(optparse)


# declare script input options
args_list  <- list(
  make_option(
    c('-r', '--input-raster-file'), type = 'character', default = NULL,
    help = 'Raster file path (relative to R project file)',
    dest = 'input_raster_file'
  ),
  make_option(
    c('-s', '--input-shape-file'), type = 'character', default = NULL,
    help = 'Shape file path (relative to R project file)',
    dest = 'input_shape_file'
  ),
  make_option(
    c('-o', '--output-folder'), type = 'character', default = NULL,
    help = 'Output folder path (relative to R project file)',
    dest = 'output_folder'
  ),
  make_option(
    c('-f', '--output-file'), type = 'character', default = NULL,
    help = 'Output file path (relative to R project file)',
    dest = 'output_file'
  )
)


# parsing arguments
opt_parser <- OptionParser(option_list = args_list);
opt <- parse_args(opt_parser);

error_cond <- is.null(opt$input_raster_file) | is.null(opt$input_shape_file) |
  is.null(opt$output_folder) | is.null(opt$output_file)
if (error_cond) {
  print_help(opt_parser)
  stop('Must supply inputs. Run with --help to see required inputs', call. = FALSE)
}


# define inputs and outputs here
# infile_expo <- "GlobalGWRwUni_PM25_GL_201601_201612-RH35-NoNegs_AUS_20180618.tif"
# indir_expo <- here("data_demo", "air_pollution")
infile_expo <- here(opt$input_raster_file)
# indir_spat <- here("data_demo", "spatial_boundaries")
# infile_spat <- "sa22016_case_studyV2.shp"
infile_spat <- here(opt$input_shape_file)
out_folder <- here(opt$output_folder)
out_file <- opt$output_file


# run the computations/tasks files
source(here("test_scripts", "01_load_air_pollution.R"))
source(here("test_scripts", "02_load_spatial_boundaries.R"))
source(here("test_scripts", "03_merge_air_pollution_with_boundaries.R"))
