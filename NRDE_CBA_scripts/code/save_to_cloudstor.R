library(here)
library(tools)
library(cloudstoR)


options(cloudstoR.cloud_address = "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/")

message("\n########################\nUpload to Cloudstor\n########################\n")

CLOUDSTOR_USER <- opt$user
CLOUDSTOR_PASSWORD <- opt$password
CLOUDSTOR_OUTPUT_PATH <- opt$output_folder

all_output_files <- list.files("figures_and_tables")
for (filename in all_output_files) {
  # check if is a file
  if (grepl(".", filename, fixed = TRUE)) {
    message("Uploading")
    print(filename)
    message("from location")
    print(file.path("figures_and_tables", filename))
    message("to")
    print(CLOUDSTOR_OUTPUT_PATH)
    cloud_put(
      file_name = filename,
      local_file = file.path("figures_and_tables", filename),
      path = CLOUDSTOR_OUTPUT_PATH,
      user = CLOUDSTOR_USER,
      password = CLOUDSTOR_PASSWORD
    )
  }
}
