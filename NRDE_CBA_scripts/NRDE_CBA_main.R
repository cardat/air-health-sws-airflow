## to run all steps for analysis, step by step.
# based on original Aus BoD PM2.5 codes by ivan hanigan and Josh Horsley
run_label <- "20210915"
st <- Sys.time()
#### functions ####
reinstall_iomlifetR <- T
if(reinstall_iomlifetR){
  if(!require(devtools)) install.packages("devtools"); library(devtools)
  install_github("richardbroome2002/iomlifetR", build_vignettes = TRUE)  
}
library(iomlifetR)

source("code/packages.R")


# Setup directories
source("code/dir_setup.R")
source('code/set_data_paths.R')
# TODO: this overwrites the prior set paths that need to change for users who are amdinistrator of cloudstor share and has to change
admin <- FALSE
if(admin){
source('code/set_data_paths_admin.R')
}



# Baseline prep ----------------------------------------------------------------
# Prep baseline SA2 pop
source("code/prep_pop_sa2.R")
tbl_pop_sa2

# Prep baseline SA2 mortality
source("code/prep_mort_ste.R")
tbl_mort_ste

# PM2.5 -----------------------------------------------------------

# Extract PM2.5 in MB
# note can take long time so only recreate if necessary
recreate_x <- TRUE
if(recreate_x){
source("code/pm25_lur/import_x_mb.R")
}
tbl_x_mb_long

cf_5th_percentile <- TRUE
if(cf_5th_percentile){
  source("code/pm25_lur/do_x_cf.R")}
tbl_x_cf_ste

cf_ratio <- FALSE
if(cf_ratio){
  source("code/pm25_lur/do_x_cf_ratio.R")}


# Summarise PM2.5 in UCL with pop > 100k
## TODO Rscript code/pm25_vd/pop_centre_exposure_weighted.R

# PM2.5 counter-factual
##source("code/pm25_lur/do_x_cf.R")

## TODO consider doing more summary stats here
# output working_temporary/pm25_lur/tbl_x_cf_ste.rds
# to be used in figures_and_tables/tab_exposure_cf.csv

# baseline_x <- TRUE
# if(baseline_x){
source("code/pm25_lur/do_x_sa2_agg.R")
#}
tbl_x_sa2_long

# adjusted_x <- FALSE
# if(adjusted_x){
#   source("code/pm25_lur/do_cf_sa2_agg.R")}

# Aggregate PM2.5 to SA2
##source("code/pm25_lur/do_x_sa2_agg.R")
## TODO need to describe areaOverlap/population weighted apportionment

# NO2 -----------------------------------------------------------

# Extract NO2 in MB
# note can take long time so only recreate if necessary
recreate_x_no2 <- TRUE
if(recreate_x_no2){
  source("code/no2_lur/import_x_mb.R")
}
tbl_x_sa2_long

# NO2 theoretical minimum risk effect level

cf_pctl <- FALSE
if(cf_pctl){
source("code/no2_lur/do_x_cf_pctl.R")}

cf_fixed <- TRUE
if(cf_fixed){
source("code/no2_lur/do_x_cf.R")}
tbl_x_cf_ste

cf_ratio <- FALSE
if(cf_ratio){
  source("code/no2_lur/do_x_cf_ratio.R")}


## TODO consider doing more summary stats here
 
# Aggregate NO2 to SA2

# baseline_x <- FALSE
# if(baseline_x){
source("code/no2_lur/do_x_sa2_agg.R")
# } else {
#  source("code/no2_lur/do_cf_sa2_agg.R")}

# adjusted_x <- TRUE
# if(adjusted_x){
head(tbl_x_sa2_long)

## TODO need to describe areaOverlap/population weighted apportionment

#### link the exposure data and cf ####
source("code/do_x_and_cf_linked.R")
tbl_x_sa2_long
tbl_x_cf_ste

# prepare joined data
# define the study period 
study_period <- 2012:2015

source("code/do_hia_prep.R")
head(tbl_hia_baseline)

choose_state <- TRUE
if(choose_state){tbl_hia_baseline <- tbl_hia_baseline[STE_CODE16 == "1", ]}

# Run HIA
source("code/do_hia.R")

tab_summary_ste_baseline <- tab_summary_ste
head(tab_summary_ste_baseline)
tab_summary_gcc_baseline <- tab_summary_gcc
head(tab_summary_gcc_baseline)

#### Run setup and HIA again with counter factual (cf) air pollution concentrations

tbl_x_ste_ratio <- readRDS("C:/Users/Timothy Chaston/cloudstor/Shared/NRDE_CBA/data_air_pollution/data_derived/scenarios_mb11_pm25_prop_20210825.rds")
#t <- tbl_x_ste_ratio[]
source("code/pm25_lur/do_cf_sa2_agg.R")
tbl_x_ste_ratio <- readRDS("C:/Users/Timothy Chaston/cloudstor/Shared/NRDE_CBA/data_air_pollution/data_derived/scenarios_mb11_pm25_prop_20210825.rds")
source("code/no2_lur/do_cf_sa2_agg.R")
source("code/do_x_and_cf_linked.R")
source("code/do_hia_prep.R")
if(choose_state){tbl_hia_baseline <- tbl_hia_baseline[STE_CODE16 == "1", ]}
source("code/do_hia.R")

tab_summary_ste_cf <- tab_summary_ste
head(tab_summary_ste_cf)
tab_summary_gcc_cf <- tab_summary_gcc
head(tab_summary_gcc_cf)

tab_summary_ste_delta <- merge(tab_summary_ste_baseline, tab_summary_ste_cf)
tab_summary_ste_delta <- tab_summary_ste_delta[,.(state, pollutant, an_est = (an_est.x - an_est.y), an_lci = (an_lci.x - an_lci.y), an_uci = (an_uci.x - an_uci.y), yll_est = (est.x - est.y), yll_lci = (lci.x - lci.y), yll_uci = (uci.x - uci.y))]
tab_summary_ste_delta

tab_summary_gcc_delta <- merge(tab_summary_gcc_baseline, tab_summary_gcc_cf, by = "state", "pollutant")
tab_summary_gcc_delta <- tab_summary_gcc_delta[,.(state = state.x, pollutant, an_est = (an_est.x - an_est.y), an_lci = (an_lci.x - an_lci.y), an_uci = (an_uci.x - an_uci.y), yll_est = (est.x - est.y), yll_lci = (lci.x - lci.y), yll_uci = (uci.x - uci.y))]
tab_summary_gcc_delta

#dir("figures_and_tables", pattern = "tab") 
#if(write.csv(tab_summary_ste[zone %in% c("G", "A") & date_year == 2015][order(pollutant, state)]
#           , "figures_and_tables/tab_summary_gcc.csv", row.names = F)

# Render report and populate figures_and_tables directory
# source("code/prep_figures.R")
# TODO this is for all the reporting and summaries 
ed <- Sys.time()
ed -  st
