packages <- c(
  "tidyverse",
  "dplyr",
  "here",
  "rgdal",
  "raster",
  "cloudstoR",
  "purr",
  "optparse"
)

installed <- installed.packages()[, "Package"]
old_pkgs <- old.packages()[, "Package"]

for (package in packages) {
  if (package %in% installed && package %in% old_pkgs) {
    cat("Updating", package, "...\n\n")
    install.packages(package)
  } else if (!package %in% installed) {
    cat("Installing", package, "...\n\n")
    install.packages(package)
  } else {
    cat("Nothing to update or install for", package, "\n")
  }
}
