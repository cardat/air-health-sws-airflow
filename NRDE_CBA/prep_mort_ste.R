# Prep age-specific SA2 mortality -----------------------------------------


# Import ABS stat CSV -----------------------------------------------------

age_deaths_import <- fread(path_age_deaths)

# Mort rate by state ------------------------------------------------------
# select age groups only
ages_keep <- unique(age_deaths_import$Age)
#ages_keep
#paste(ages_keep[1:21], sep = "", collapse = "', '")
ages_keep <- c('0 - 4', '5 - 9', '10 - 14', '15 - 19', '20 - 24', '25 - 29', '30 - 34', '35 - 39', '40 - 44', '45 - 49', '50 - 54', '55 - 59', '60 - 64', '65 - 69', '70 - 74', '75 - 79', '80 - 84', '85 - 89', '90 - 94', '95 - 99', '100 and over')
#   # Keep only persons, state, and age groups
#   # Move Population/deaths/rate to wide format
#   # Relabel age groups

names(age_deaths_import)
age_deaths_import[,.N, .(ASGS_2011)]
#ASGS_2011 is state/territory
tbl_mort_ste <- age_deaths_import[Sex == "Persons"
                                 & ASGS_2011 != 0
                                 & Age %in% ages_keep,
                                 .(Measure, Age, Time, Value, ASGS_2011)]
tbl_mort_ste[,.(.N), by = "Age"]
tbl_mort_ste[,.(.N), by = .(Measure)]
"
                   Measure     N
1:              Population 10736
2:                  Deaths 10824
3: Age-specific death rate 10734
"

tbl_mort_ste <- dcast(tbl_mort_ste, Age + Time + ASGS_2011 ~ Measure, 
                      value.var = "Value")
tbl_mort_ste[ASGS_2011 == 1]
#age_deaths_import[Age == '0 - 4' & TIME %in% c(2006, 2010)
#                  & Sex == 'Persons' & ASGS_2011 == 1]
## age_start is the youngest age in years for all people in the age group

tbl_mort_ste$age_start <- car::recode(tbl_mort_ste$Age, "
                               '0 - 4' = 0;
                               '5 - 9' = 5;
                               '10 - 14' = 10;
                               '15 - 19' = 15;
                               '20 - 24' = 20;
                               '25 - 29' = 25;
                               '30 - 34'  = 30;
                               '35 - 39'  = 35;
                               '40 - 44'  = 40;
                               '45 - 49'  = 45;
                               '50 - 54'  = 50;
                               '55 - 59'  = 55;
                               '60 - 64'  = 60;
                               '65 - 69'  = 65;
                               '70 - 74'   = 70;
                               '75 - 79'   = 75;
                               '80 - 84'   = 80;
                               '85 - 89'  = 85;
                               '90 - 94'  = 85;
                               '95 - 99'  = 85;
                               '100 and over' = 85")
str(tbl_mort_ste)
tbl_mort_ste[,.N, by = c("Age", "age_start")][order(age_start)]
tbl_mort_ste$age_start <- as.integer(as.character(tbl_mort_ste$age_start))

# Truncate 85+ within each year
tbl_mort_ste <- tbl_mort_ste[,.(Population = sum(Population),
                                 Deaths = sum(Deaths)),
                              by = .(Time, ASGS_2011, age_start)]

## QC checks
tbl_mort_ste[order(Time, ASGS_2011, age_start)]
tbl_mort_ste[Time == 2006 & ASGS_2011 == 1][order(age_start)]
tbl_mort_ste[age_start >= 55, sum(Deaths), by = "Time"]

qc <- tbl_mort_ste[, .(pop = sum(Population),
                 deaths = sum(Deaths)), 
             by = "Time"]
qc
"
    Time      pop deaths
 1: 2006 20448587 134453
 2: 2007 20825108 139688
 3: 2008 21246516 142474
 4: 2009 21688777 141276
 5: 2010 22028695 142746
 6: 2011 22336907 146746
 7: 2012 22739439 148916
 8: 2013 23142944 148205
 9: 2014 23501232 153861
10: 2015 23847913 157156
11: 2016 24206201 149766
"
# TODO why is 2016 down a bit?

# Save --------------------------------------------------------------------


saveRDS(tbl_mort_ste, "working_temporary/tbl_mort_ste.rds")


