# 00_main.R
# aim: a simple data input example
# ivanhanigan
message("Running: 00_main_cloudstor.R")

library(here)
library(tools)
library(optparse)
library(cloudstoR)

options(cloudstoR.cloud_address = "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/")

# declare script input options
args_list  <- list(
  make_option(
    c('-u', '--user'), type = 'character', default = NULL,
    help = 'Cloudstor Username',
    dest = 'user'
  ),
  make_option(
    c('-p', '--password'), type = 'character', default = NULL,
    help = 'Cloudstor password',
    dest = 'password'
  ),
  make_option(
    c('-r', '--input-raster-file'), type = 'character', default = NULL,
    help = 'Path to raster file in Cloudstor',
    dest = 'input_raster_file'
  ),
  make_option(
    c('-s', '--input-shape-file'), type = 'character', default = NULL,
    help = 'Path to shape file in Cloudstor',
    dest = 'input_shape_file'
  ),
  make_option(
    c('-o', '--output-folder'), type = 'character', default = "",
    help = 'Path to output folder in Cloudstor [default %default]',
    dest = 'output_folder'
  ),
  make_option(
    c('-f', '--output-file'), type = 'character', default = NULL,
    help = 'Output file name',
    dest = 'output_file'
  )
)


# parsing arguments
opt_parser <- OptionParser(option_list = args_list);
opt <- parse_args(opt_parser);

error_cond <- is.null(opt$user) | is.null(opt$password) |
  is.null(opt$input_raster_file) | is.null(opt$input_shape_file) |
  is.null(opt$output_file)
if (error_cond) {
  print_help(opt_parser)
  stop('Must supply inputs', call. = FALSE)
}


# download input files from Cloudstor
message("Downloading data from Cloudstor")
cloudstor_shapefile_folder <- dirname(opt$input_shape_file)
cloudstor_shapefile <- file_path_sans_ext(basename(opt$input_shape_file))

# define internal files and folders
root_temp_folder <- tempdir(check = T)
out_folder <- tempfile()
out_file <- "processed"
cat("temporary output folder", out_folder, "\n")
shapefile_folder <- tempfile()
cat("temporary shape file folder", shapefile_folder, "\n")
for (myfolder in c(out_folder, shapefile_folder)) {
  dir.create(myfolder, showWarnings = F)
}
infile_spat <- file.path(shapefile_folder, basename(opt$input_shape_file))

# get list of associated shape files (assuming shape files are organised
# in a folder)
shape_files <- cloud_list(
  path = cloudstor_shapefile_folder,
  user = opt$user,
  password = opt$password
)

# download all files associated to the shape file
for (filename in shape_files) {
  # dowload shape related files only if names match
  if (file_path_sans_ext(filename) == cloudstor_shapefile) {
    cloud_get(
      path = paste0(cloudstor_shapefile_folder, "/", filename),
      dest = file.path(shapefile_folder, filename),
      user = opt$user,
      password = opt$password,
      open_file = F
    )
  }
}

# get the raster file
infile_expo <- cloud_get(
  path = opt$input_raster_file,
  dest = tempfile(),
  user = opt$user,
  password = opt$password,
  open_file = F
)


# run the computations/tasks files
source(here("test_scripts", "01_load_air_pollution.R"))
source(here("test_scripts", "02_load_spatial_boundaries.R"))
source(here("test_scripts", "03_merge_air_pollution_with_boundaries.R"))


# upload results to cloudstor
message("Uploading data to Cloudstor")
all_output_files <- list.files(out_folder)
for (filename in all_output_files) {
  print(paste(
          file_path_sans_ext(opt$output_file),
          file_ext(filename),
          sep = "."
        ))
  print(file.path(out_folder, filename))
  print(opt$output_folder)
  message("----")
  cloud_put(
    file_name = paste(
      file_path_sans_ext(opt$output_file),
      file_ext(filename),
      sep = "."
    ),
    local_file = file.path(out_folder, filename),
    path = opt$output_folder,
    user = opt$user,
    password = opt$password
  )
}
