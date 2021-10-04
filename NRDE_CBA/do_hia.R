# take the prepared data file and run the HIA calculations
#### load ####
##tbl_hia_baseline <- fread(paste0("working_temporary/tbl_hia_baseline_national_",run_label,".csv"))
str(tbl_hia_baseline)

#### HIF ####
# 
# rr <- 1.023
# rr_lci <- 1.008
# rr_uci <- 1.037
# rrs_todo <- c(rr, rr_lci, rr_uci)
# rrs_labels <- c("est", "lci", "uci")

#### Prep ####

poll_todo <- unique(tbl_hia_baseline$pollutant)
sa2_todo <- unique(tbl_hia_baseline$SA2_MAIN16)
yy_todo <- unique(tbl_hia_baseline$date_year)

##loop over pollutant##
for (poll in poll_todo) {
  if (poll == "no2"){
    rr <- 1.023
    rr_lci <- 1.008
    rr_uci <- 1.037
  } else if (poll == "pm25") {
    rr <- 1.062
    rr_lci <- 1.040
    rr_uci <- 1.083
  }
  
  rrs_todo <- c(rr, rr_lci, rr_uci)
  rrs_labels <- c("est", "lci", "uci")
    

#### loop over sa2/year ####
for(i in 1:length(sa2_todo)){
# i = 1
  sa2_i <- sa2_todo[i]
  
  for(yy in yy_todo){
    # yy = yy_todo[1]
    indata_f <- tbl_hia_baseline[SA2_MAIN16==sa2_i & date_year == yy & pollutant == poll]
    
    for(rr_i in 1:3){
      # rr_i = 1
      rr_use <- rrs_todo[rr_i]
    
    # Create demog data
    demog_data <- data.frame(age = indata_f$age_start,
                             population = indata_f$value,
                             deaths = indata_f$mort_n)
    #demog_data
    
    # Calculate life table
    #head(indata_f)
    
    le = burden_le(demog_data,
                   pm_concentration = indata_f$x_attrib[1],
                   RR = rr_use, unit = 10)
    le
    # Calculate yll from lifetable
    impacted_le <- le[["impacted"]][, "ex"]
    an <- burden_an(demog_data,
                    pm_concentration = indata_f$x_attrib[1],
                    RR = rr_use)
    yll <- burden_yll(an, impacted_le)
    
    out <- data.frame(date_year = yy,
                      SA2_MAIN16 = sa2_i,
                      x_attrib = indata_f$x_attrib[1], population = demog_data$population, le, an, yll,
                      est_type = rrs_labels[rr_i],
                      pollutant = poll
                      )
    
    if(rr_i == 1){
      out_rr <- out
    } else {
      out_rr <- rbind(out_rr, out)
    }
    # end loop by rr, lc, uc
    }
    
    if(yy == min(study_period)){
      out1 <- out_rr
    } else {
      out1 <- rbind(out1, out_rr)
    }
    # end loop by year
  }
  #
  # return data frame
  if(i == 1){
    out2 <- out1
  } else {
    out2 <- rbind(out2, out1)
  }
  # end loop by sa2
}
  
  if (poll == poll_todo[1]){
    out_master <- out2
  } else {
    out_master <- rbind(out_master, out2)
  }
  
# end loop by pollutant
}

saveRDS(out_master, "code/do_hia.rds")

#### summarise ####
out_master <- readRDS("code/do_hia.rds")
# print(out_master)
str(out_master)
table(out_master$est_type)

setDT(out_master)
out_master

an_sa2_year <- out_master[,.(var = sum(an)),by = .(SA2_MAIN16, date_year, est_type, pollutant)]
an_sa2_year <- dcast(an_sa2_year, SA2_MAIN16 + date_year + pollutant ~ est_type, value.var = "var")
an_sa2_year
nrow(an_sa2_year[date_year == 2016])

an_nat_year <- an_sa2_year[,.(est = sum(est, na.rm=TRUE), lci = sum(lci, na.rm=TRUE), uci = sum(uci, na.rm=TRUE)), by = .(date_year, pollutant)]

yll_sa2_year <- out_master[,.(var = sum(yll)),by = .(SA2_MAIN16, date_year, est_type, pollutant)]
yll_sa2_year <- dcast(yll_sa2_year, SA2_MAIN16 + date_year + pollutant ~ est_type, value.var = "var")
## note there are some with NA
nrow(yll_sa2_year[is.na(est)])
# 613, different from pm2.5 1766
paste(unique(yll_sa2_year[is.na(est)]$SA2_MAIN16), collapse ="','", sep = "")
# check in do_data_checking, these are sa2 with zero pop in some years


yll_nat_year <- yll_sa2_year[,.(est = sum(est, na.rm=TRUE), lci = sum(lci, na.rm=TRUE), uci = sum(uci, na.rm=TRUE)), by = .(date_year, pollutant)]

le_sa2_year <- out_master[difference.age == "0 - 4", .(SA2_MAIN16, difference.ex_diff, est_type, date_year, pollutant)]
le_sa2_year <- dcast(le_sa2_year, SA2_MAIN16 + date_year + pollutant ~ est_type, value.var = "difference.ex_diff")

# SA2 pop for life expectancy weighted average
pop_SA2_year <- out_master[,.(population = sum(population)), by = .(date_year, SA2_MAIN16, pollutant)]

le_sa2_year <- merge(le_sa2_year, pop_SA2_year, by = c("SA2_MAIN16", "date_year", "pollutant"), all.x = T)

le_nat_year <- le_sa2_year[,.(est = sum(est * population, na.rm=TRUE)/sum(population, na.rm=TRUE),
  lci = sum(lci * population, na.rm=TRUE)/sum(population, na.rm=TRUE),
  uci = sum(uci * population, na.rm=TRUE)/sum(population, na.rm=TRUE)
  ),
by = .(date_year, pollutant)
]

#### overall ####
# le_nat_year
# le_nat_av <- le_nat_year[, .(le_nat_av_est = mean(est),
#                                  le_nat_av_lci = mean(lci),
#                                  le_nat_av_uci = mean(uci)), by = "pollutant"]
# 
# yll_nat_av <- yll_nat_year[, .(yll_nat_av_est = mean(est),
#                              yll_nat_av_lci = mean(lci),
#                              yll_nat_av_uci = mean(uci)), by = "pollutant"]
# 
# an_nat_av <- an_nat_year[, .(an_nat_av_est = mean(est),
#                              an_nat_av_lci = mean(lci),
#                              an_nat_av_uci = mean(uci)), by = "pollutant"]

yll_nat_av_est = mean(yll_nat_year$est)
yll_nat_av_lci = mean(yll_nat_year$lci)
yll_nat_av_uci = mean(yll_nat_year$uci)

an_nat_av_est = mean(an_nat_year$est)
an_nat_av_lci = mean(an_nat_year$lci)
an_nat_av_uci = mean(an_nat_year$uci)

#### Add multipollutant model ####
an_sa2_year_multi <- dcast(an_sa2_year, SA2_MAIN16 + date_year ~ pollutant, value.var = c("est", "lci", "uci"))
an_sa2_year_multi[, `:=`(est_multi = est_no2*0.8+est_pm25,
                         lci_multi = lci_no2*0.8+lci_pm25,
                         uci_multi = uci_no2*0.8+uci_pm25)]
an_sa2_year <- rbind(an_sa2_year, 
                     an_sa2_year_multi[, .(SA2_MAIN16, date_year, pollutant = "multi",
                                           est = est_multi, lci = lci_multi, uci = uci_multi)])
an_sa2_year <- an_sa2_year[order(SA2_MAIN16, date_year)]

yll_sa2_year_multi <- dcast(yll_sa2_year, SA2_MAIN16 + date_year ~ pollutant, value.var = c("est", "lci", "uci"))
yll_sa2_year_multi[, `:=`(est_multi = est_no2*0.8+est_pm25,
                         lci_multi = lci_no2*0.8+lci_pm25,
                         uci_multi = uci_no2*0.8+uci_pm25)]
yll_sa2_year <- rbind(yll_sa2_year, 
                     yll_sa2_year_multi[, .(SA2_MAIN16, date_year, pollutant = "multi",
                                           est = est_multi, lci = lci_multi, uci = uci_multi)])
yll_sa2_year <- yll_sa2_year[order(SA2_MAIN16, date_year)]

le_sa2_year_multi <- dcast(le_sa2_year, SA2_MAIN16 + date_year + population ~ pollutant, value.var = c("est", "lci", "uci"))
le_sa2_year_multi[, `:=`(est_multi = est_no2*0.8+est_pm25,
                         lci_multi = lci_no2*0.8+lci_pm25,
                         uci_multi = uci_no2*0.8+uci_pm25)]
le_sa2_year <- rbind(le_sa2_year, 
                     le_sa2_year_multi[, .(SA2_MAIN16, date_year, pollutant = "multi",
                                           est = est_multi, lci = lci_multi, uci = uci_multi,
                                           population)])
le_sa2_year <- le_sa2_year[order(SA2_MAIN16, date_year)]

#### by state ####
names(an_sa2_year)
an_sa2_year$ste <- substr(an_sa2_year$SA2_MAIN16, 1, 1)
an_sa2_year$state <- car::recode(an_sa2_year$ste, recodes = "1='NSW and ACT';2='VIC';3='QLD';4='SA';5='WA';6='TAS'; 7='NT';8='NSW and ACT'")

an_state_year <- an_sa2_year[,.(est = sum(est, na.rm=TRUE), lci = sum(lci, na.rm=TRUE), uci = sum(uci, na.rm=TRUE)), by = .(state, date_year, pollutant)]
an_state_year

an_state_av_est = an_state_year[,.(est = mean(est), lci = mean(lci), uci = mean(uci)), by = .(state, pollutant)]

# yll
names(yll_sa2_year)
yll_sa2_year$ste <- substr(yll_sa2_year$SA2_MAIN16, 1, 1)
yll_sa2_year$state <- car::recode(yll_sa2_year$ste, recodes = "1='NSW and ACT';2='VIC';3='QLD';4='SA';5='WA';6='TAS'; 7='NT';8='NSW and ACT'")

yll_state_year <- yll_sa2_year[,.(est = sum(est, na.rm=TRUE), lci = sum(lci, na.rm=TRUE), uci = sum(uci, na.rm=TRUE)), by = .(state, date_year, pollutant)]
yll_state_year

yll_state_av_est = yll_state_year[,.(est = mean(est), lci = mean(lci), uci = mean(uci)), by = .(state, pollutant)]

names(an_state_av_est) <- sub("^(est|lci|uci)$", "an_\\1", names(an_state_av_est))
tab_summary_ste <- merge(an_state_av_est, yll_state_av_est)[order(pollutant, state)]

tab_summary_ste[8,"state"] <- "National"
tab_summary_ste[8,"an_est"] <- an_nat_av_est
tab_summary_ste[8,"an_lci"] <- an_nat_av_lci
tab_summary_ste[8,"an_uci"] <- an_nat_av_uci
tab_summary_ste[8,"est"] <- yll_nat_av_est
tab_summary_ste[8,"lci"] <- yll_nat_av_lci
tab_summary_ste[8,"uci"] <- yll_nat_av_uci

tab_summary_ste
dir("figures_and_tables", pattern = "tab")
write.csv(tab_summary_ste, "figures_and_tables/tab_summary_ste.csv", row.names = F)

#### by GCC ####
names(an_sa2_year)
an_sa2_year_saved <- an_sa2_year
an_sa2_year <- an_sa2_year_saved
an_sa2_year$SA2_MAIN16 <- as.numeric(an_sa2_year$SA2_MAIN16)

indsa2 <- readOGR(path_sa2)
str(indsa2@data)
# this also has the GCCs in it
table(indsa2@data[,c("SA2_MAIN16", "GCC_CODE16")]$GCC_CODE16)
indsa2@data$SA2_MAIN16 <- as.numeric(indsa2@data$SA2_MAIN16)
an_sa2_year <- merge(an_sa2_year, indsa2@data[,c("SA2_MAIN16", "GCC_CODE16")],
                     by = "SA2_MAIN16")
head(an_sa2_year)
an_sa2_year$ste <- an_sa2_year$GCC_CODE16
an_sa2_year$state <- an_sa2_year$ste#car::recode(an_sa2_year$ste, recodes = "1='NSW and ACT';2='VIC';3='QLD';4='SA';5='WA';6='TAS'; 7='NT';8='NSW and ACT'")

an_state_year <- an_sa2_year[,.(est = sum(est, na.rm=TRUE), lci = sum(lci, na.rm=TRUE), uci = sum(uci, na.rm=TRUE)), by = .(state, date_year, pollutant)]
an_state_year

an_state_av_est <- an_state_year[,.(est = mean(est), lci = mean(lci), uci = mean(uci)), by = .(state, date_year, pollutant)]

an_state_av_est[date_year == 2015]

# yll
# names(yll_sa2_year)
# yll_sa2_year$ste <- substr(yll_sa2_year$SA2_MAIN16, 1, 1)
# yll_sa2_year$state <- car::recode(yll_sa2_year$ste, recodes = "1='NSW and ACT';2='VIC';3='QLD';4='SA';5='WA';6='TAS'; 7='NT';8='NSW and ACT'")
yll_sa2_year_saved <- yll_sa2_year
yll_sa2_year$SA2_MAIN16 <- as.numeric(yll_sa2_year$SA2_MAIN16)
yll_sa2_year <- merge(yll_sa2_year, indsa2@data[,c("SA2_MAIN16", "GCC_CODE16")],
                      by = "SA2_MAIN16")
head(yll_sa2_year)
yll_sa2_year$ste <- yll_sa2_year$GCC_CODE16
yll_sa2_year$state <- yll_sa2_year$ste#car::recode(an_sa2_year$ste, recodes = "1='NSW and ACT';2='VIC';3='QLD';4='SA';5='WA';6='TAS'; 7='NT';8='NSW and ACT'")

yll_state_year <- yll_sa2_year[,.(est = sum(est, na.rm=TRUE), lci = sum(lci, na.rm=TRUE), uci = sum(uci, na.rm=TRUE)), by = .(GCC_CODE16, date_year, pollutant)]
yll_state_year

yll_state_av_est = yll_state_year[,.(est = mean(est), lci = mean(lci), uci = mean(uci)), by = .(GCC_CODE16, date_year, pollutant)]

names(an_state_av_est)[4:6] <- paste0("an_", names(an_state_av_est)[4:6])
tab_summary_gcc <- cbind(an_state_av_est, yll_state_av_est[, .(est, lci, uci)])[rev(order(an_est))]
tab_summary_gcc[8,"state"] <- "National"

tab_summary_gcc[8,"an_est"] <- an_nat_av_est
tab_summary_gcc[8,"an_lci"] <- an_nat_av_lci
tab_summary_gcc[8,"an_uci"] <- an_nat_av_uci
tab_summary_gcc[8,"est"] <- yll_nat_av_est
tab_summary_gcc[8,"lci"] <- yll_nat_av_lci
tab_summary_gcc[8,"uci"] <- yll_nat_av_uci

tab_summary_gcc$zone <- substr(tab_summary_gcc$state, 2,2)

tab_summary_gcc <- tab_summary_gcc[zone %in% c("G", "A") & date_year == 2015][order(pollutant, state)]
#dir("figures_and_tables", pattern = "tab")
# write.csv(tab_summary_gcc[zone %in% c("G", "A") & date_year == 2015][order(pollutant, state)]
#           , "figures_and_tables/tab_summary_gcc.csv", row.names = F)



