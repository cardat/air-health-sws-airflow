# Default paths for admin -----------------------------------------------------------


# coesra
path_env_gen_coesra <- "~/public_share_data/ResearchData_CAR/Environment_General"
path_shared_owncloud <- "~/ownCloud/Shared/ResearchProjects_CAR/"

# local
path_shared_cloudstor_mac <- "~/cloudstor/Shared/ResearchProjects_CAR/"
path_shared_cloudstor_pc <- "~/../cloudstor/Shared/ResearchProjects_CAR/"


# Assign paths based on if running local or cloud -----------------------------------------


path_shared <- NA

if(dir.exists(path_shared_owncloud)) path_shared <- path_shared_owncloud
if(dir.exists(path_shared_cloudstor_pc)) path_shared <- path_shared_cloudstor_pc
if(dir.exists(path_shared_cloudstor_mac)) path_shared <- path_shared_cloudstor_mac

if(is.na(path_shared)) stop("Could not find Cloudstor/ownCloud shared directory:\nPlease see paths in code/paths_external.R")

path_env_general <- if(dir.exists(path_env_gen_coesra)) {
  path_env_gen_coesra
} else {
  file.path(path_shared, "Environment_General")
}

path_shared_staging <- file.path(path_shared, "CAR_staging_area")

# NOTE THESE ARE RESTRICTED ----

#### path SatPM25 ####
path_provided <- file.path(path_shared,"Satellite_PM25_LUR/SatPM25_2000_2015/data_derived/PM25_predictions_MB_2011_AUST_20200716.csv")

#path_provided_pm16 <- file.path(path_shared,"Satellite_PM25_LUR/SatPM25_2015_2018/data_provided/PM25_201518_20200724.csv")

path_provided_pm16 <- file.path(path_shared,"Satellite_PM25_LUR/SatPM25_2016/data_derived/PM25_predictions_MB_2011_AUST_2016_20200721.csv")

#### path SatNO2 ####
path_provided_no2 <- file.path(path_shared,"Satellite_NO2_LUR/SatNO2_2012_2015/data_provided/MB_NO2_update_250221.csv")
