# Prep age-specific SA2 pop -----------------------------------------------


# Load pop data -----------------------------------------------------------

pop_sa2_2001_2016_import <- fread(path_pop_sa2)

# Prep --------------------------------------------------------------------
#setDT(pop_sa2_2001_2016_import)
names(pop_sa2_2001_2016_import)
pop_sa2_2001_2016_import
tbl_pop_sa2 <- pop_sa2_2001_2016_import[REGIONTYPE == "SA2" 
                                        & Sex == "Persons" 
                                        & Age != "All ages",
                                        .(SA2_MAINCODE_2016 = ASGS_2016,
                                          value = Value,
                                          Age = Age,
                                          date_year = Time)]

# QC check
#tbl_pop_sa2[, .(pop = sum(value)), by = "date_year"]
"
    date_year      pop
 1:      2001 19274701
 2:      2002 19495210
 3:      2003 19720737
 4:      2004 19932722
 5:      2005 20176844
 6:      2006 20450966
 7:      2007 20827622
 8:      2008 21249199
 9:      2009 21691653
10:      2010 22031750
11:      2011 22340024
12:      2012 22742475
13:      2013 23145901
14:      2014 23504138
15:      2015 23850784
16:      2016 24210809
"
#tbl_pop_sa2[SA2_MAINCODE_2016 == "102011028", sum(value), by = "date_year"]
#ok
#tbl_pop_sa2[SA2_MAINCODE_2016 == "119011355", sum(value), by = "date_year"]
# this one has years with no population, prior to growth...

#### age cats recode ####
tbl_pop_sa2$age_start <- car::recode(tbl_pop_sa2$Age, "'0 - 4' = 0;
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
           '85 and over'  = 85")
#str(tbl_pop_sa2)
#tbl_pop_sa2[,.N, by = c("Age", "age_start")]

# some formatting
tbl_pop_sa2$SA2_MAIN16 <- as.character(tbl_pop_sa2$SA2_MAINCODE_2016)
tbl_pop_sa2$age_start <- as.integer(tbl_pop_sa2$age_start)
tbl_pop_sa2

# Save --------------------------------------------------------------------


saveRDS(tbl_pop_sa2, "working_temporary/tbl_pop_sa2.rds")


