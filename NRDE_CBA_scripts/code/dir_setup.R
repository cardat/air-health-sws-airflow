# Setup directories -------------------------------------------------------


message("\n########################\nCreate directories - Starting\n########################\n")


# Create ------------------------------------------------------------------


dir_work <- list("working_temporary", "working_temporary/no2_lur", "working_temporary/pm25_lur",
                 "figures_and_tables", "figures_and_tables/pm25_vd")

lapply(dir_work, function(x) if(!dir.exists(x)) dir.create(x) )


# Confirm -----------------------------------------------------------------


message("\n########################\nCompleted\n########################")