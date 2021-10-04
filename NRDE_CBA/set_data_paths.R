# Default paths -----------------------------------------------------------


# coesra
path_env_gen_coesra <- "~/public_share_data/ResearchData_CAR/Environment_General"
path_shared_owncloud <- "~/ownCloud/Shared/"

# local
path_shared_cloudstor_mac <- "~/cloudstor/Shared/"
path_shared_cloudstor_pc <- "~/../cloudstor/Shared/"


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

# Paths -------------------------------------------------------------------
## Environment General

#### path MB shapefiles ####
indir_mb_2011 <- file.path(path_env_general, "ABS_data/ABS_meshblocks/abs_meshblocks_2011_data_provided/")
indir_mb_2016 <- file.path(path_env_general, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/")

path_mb_2011 <- list.files(indir_mb_2011,pattern = "*.shp", full.names = TRUE)
path_mb_2016 <- list.files(indir_mb_2016,pattern = "*.shp", full.names = TRUE)

#### path mb pops ####
path_2011_mb_pop <- file.path(path_env_general, "ABS_data/ABS_meshblocks/abs_meshblocks_2011_pops_data_provided/censuscounts_mb_2011_aust.csv")
path_mb_pops_2016 <- file.path(path_env_general, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv")

#### path_sa2 ####
path_sa2 <- file.path(path_env_general, "ABS_data/ABS_Census_2016/abs_sa2_2016_data_provided/1270055001_sa2_2016_aust_shape/SA2_2016_AUST.shp")

#### path pop SA2 ####
path_pop_sa2 <- file.path(path_env_general, "ABS_data/ABS_ERP/age_by_sex_2001_2016_data_derived/abs_erp_age_by_sex_2001_2016.csv")

#### path MB concordance ####
path_mb_int <- file.path(path_env_general, "ABS_data/ABS_meshblocks_concordance_mapping/data_derived/meshblocks_2011_2016_concordance_20200710.rds")

#### path_age_deaths ####
path_age_deaths <- file.path(path_env_general, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv")

#### path sa2 deaths ####
path_sa2_deaths <- file.path(path_env_general, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_derived")

# NOTE THESE ARE RESTRICTED ----

#### path SatPM25 ####
path_provided <- file.path(path_shared,"SatPM25_2000_2015/data_derived/PM25_predictions_MB_2011_AUST_20200716.csv")


path_provided_pm16 <- file.path(path_shared,"SatPM25_2015_2018/data_provided/PM25_201518_20200724.csv")

#path_provided_pm16 <- file.path(path_shared,"Satellite_PM25_LUR/SatPM25_2016/data_derived/PM25_predictions_MB_2011_AUST_2016_20200721.csv")

#### path SatNO2 ####
path_provided_no2 <- file.path(path_shared,"SatNO2_2012_2015/data_provided/MB_NO2_update_250221.csv")

