# Packages ----------------------------------------------------------------

message("\n########################\nPackage Install - Starting\n########################\n")


pkg_req <- c(
  "car",
  "data.table",
  "readr",
  "rgdal",
  "dplyr",
  "rgeos",
  "zoo",
  "tidyr",
  "openxlsx",
  "sf"
  )

# Exit if all packages present
#if(all(pkg_req %in% installed.packages()[,"Package"])) q()

# Ask to install if some packages missing ---------------------------------

# readLine only works in an interactive session - returns "" by default
# user_input <- readline("Some packages required packages are not installed. Install Y/n?")

# if(tolower(user_input)!="y") message("No packages were installed"); q()


for(pkg_i in pkg_req){
  #pkg_i = pkg_req[1]
  if(!(pkg_i %in% installed.packages()[,"Package"])) install.packages(pkg_i)
}

a <- lapply(pkg_req, library, character.only = TRUE)


message("\n########################\nCompleted\n########################")
