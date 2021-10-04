# Run HIA -----------------------------------------------------------------


# Load data ---------------------------------------------------------------


tbl_pop_sa2 <- readRDS("working_temporary/tbl_pop_sa2.rds")
tbl_mort_ste <- readRDS("working_temporary/tbl_mort_ste.rds")
tbl_x_sa2_long <- readRDS("working_temporary/tbl_x_sa2_long.rds")
tbl_x_cf_ste <- readRDS("working_temporary/tbl_x_cf_ste.rds") 
str(tbl_x_cf_ste)
tbl_x_cf_ste$STE_CODE16 <- tbl_x_cf_ste$STE_CODE11
tbl_x_cf_ste$STE_CODE11 <- NULL
# tbl_sa2 <- readOGR(path.expand(dirname(path_sa2)))
# str(tbl_sa2@data)
# tbl_sa2@data$SA2_MAIN16 <- as.character(tbl_sa2@data$SA2_MAIN16)


# Aggregate baseline data ------------------------------------------------


setDT(tbl_pop_sa2)
str(tbl_pop_sa2)
tbl_hia_baseline <- tbl_pop_sa2[, 
                                STE_CODE16 := substr(SA2_MAIN16, 1, 1)][]

tbl_hia_baseline <- tbl_hia_baseline[date_year %in% c(study_period)]
head(tbl_hia_baseline[order(SA2_MAIN16, Age, date_year)],25)

# Mortality, at state level, by age and smoothed by 3 year rolling mean centered
setDT(tbl_mort_ste)
str(tbl_mort_ste)
tbl_mort_ste$STE_CODE16 <- as.character(tbl_mort_ste$ASGS_2011)
tbl_mort_ste$date_year <- tbl_mort_ste$Time
tbl_mort_ste$rate_mort <- tbl_mort_ste$Deaths / tbl_mort_ste$Population
tbl_mort_ste[,rate_mort_rollmean_3 := zoo::rollapply(rate_mort, 3, function(x) mean(x, na.rm=TRUE), align = "center", partial=TRUE), by = .(ASGS_2011, age_start)]
tbl_mort_ste[ASGS_2011 ==1 & age_start == 0]
tbl_mort_ste[ASGS_2011 ==2 & Time == 2006]

#### total deaths per year ####
tbl_mort_ste[,.(deaths = sum(Deaths), pop = sum(Population)), by = "date_year"]
# TODO why 2016 seems low?
tbl_hia_baselineV2 <- left_join(tbl_hia_baseline, tbl_mort_ste, by = c("STE_CODE16","age_start","date_year")) 
head(tbl_hia_baselineV2)
setDT(tbl_hia_baselineV2)
qc <- tbl_hia_baselineV2[SA2_MAIN16=='102011028', .(SA2_pop = sum(value)), 
                       by = .(SA2_MAIN16, date_year, Time)]
qc
#with(qc, plot(date_year, SA2_pop))



tbl_hia_baselineV2[,mort_n := value * rate_mort_rollmean_3][]
tbl_hia_baselineV2
head(tbl_hia_baselineV2[SA2_MAIN16=='102011028'],25)
qc <- tbl_hia_baselineV2[SA2_MAIN16=='102011028' & age_start == 0]
qc
#with(qc, plot(Time, rate_mort))
#with(qc, lines(Time, rate_mort_rollmean_3))
#with(qc, plot(Time, mort_n, "l"))

#### Exposure ####
str(tbl_x_sa2_long)
tbl_hia_baselineV3 <- left_join(tbl_hia_baselineV2, tbl_x_sa2_long, by = c("SA2_MAIN16", "date_year"))
setDT(tbl_hia_baselineV3)
tbl_hia_baselineV3
tbl_hia_baselineV3[SA2_MAIN16=='102011028' & age_start == 0]
tbl_hia_baselineV3[SA2_MAIN16=='102011028' & age_start == 45]
summary(tbl_hia_baselineV3$x)
min(tbl_hia_baselineV3$x_no2, na.rm = T)
qc <- tbl_hia_baselineV3[x_no2 == 0,]
nrow(qc)
qc
# there should be none



# Counter-factual
#### cf by state ####
str(tbl_x_cf_ste)
tbl_hia_baselineV4 <- left_join(tbl_hia_baselineV3, tbl_x_cf_ste, by = c("STE_CODE16", "date_year")) 

setDT(tbl_hia_baselineV4)
tbl_hia_baselineV4
summary(tbl_hia_baselineV4$x_no2)
min(tbl_hia_baselineV4$x_no2, na.rm = T)

tbl_hia_baselineV4[,min(V1_no2, na.rm = T), by = c("STE_CODE16", "date_year")]
# note that the state == 9 is missing x data, this is fine



#### adjust 'x' so none lower than 5th centile by state ####
# store the one that has no NAs
tbl_hia_baselineV4$pm25_lk_no_na <- tbl_hia_baselineV4$x_no2
length(unique(tbl_hia_baselineV4$SA2_MAIN16))


## V1 is the state based 5th centile (MB), x is the average PM2.5 within SA2s (from within the MBs
str(tbl_hia_baselineV4)
tbl_hia_baselineV4[x_no2 < V1_no2,]
## if the sa2 pm2.5 is below the 5th centile (MB) then set it to this TMREL
## TODO this might be better to fix in sa2_agg script?
tbl_hia_baselineV5 <- tbl_hia_baselineV4[, x_adjusted_pm25 := ifelse(x_pm25 < V1_pm25, V1_pm25, x_pm25)][]
tbl_hia_baselineV5[ , x_adjusted_no2 := ifelse(x_no2 < V1_no2, V1_no2, x_no2)]
# calculate delta X (if the SA2 level is at the TMREL / 5thMB then there is zero anthropogenic)
tbl_hia_baselineV5 <- tbl_hia_baselineV5[,x_attrib_pm25 := (x_adjusted_pm25 - V1_pm25)][]
tbl_hia_baselineV5[,x_attrib_no2 := (x_adjusted_no2 - V1_no2)]
tbl_hia_baselineV5

#### fig 2 pop weighted pm and no2 ####
str(tbl_hia_baselineV5)
toplot_v1 <- tbl_hia_baselineV5[,
                             .(pop = sum(value, na.rm = T)),
                             by = .(SA2_MAIN16, date_year)]
toplot_v1[SA2_MAIN16 == 101021007]
tbl_hia_baselineV5$ASGS_2011v2 <- car::recode(tbl_hia_baselineV5$ASGS_2011, recodes = "c(1,8) = 'NSW and ACT'; 2 = 'VIC'; 3='QLD'; 4 = 'SA'; 5 = 'WA'; 6 = 'TAS';7='NT'")
toplot_v2 <- tbl_hia_baselineV5[,
                                .N,
                                by = .(ASGS_2011v2, SA2_MAIN16, date_year, x_pm25, x_no2)]
toplot_v2
nrow(toplot_v2); nrow(toplot_v1)
toplot_v3 <- merge(toplot_v2, toplot_v1, by = c("SA2_MAIN16", "date_year"))
toplot_v3

toplot_v4 <- toplot_v3[,.(pm25 = sum(pop * x_pm25, na.rm = T)/sum(pop, na.rm = T), no2 = sum(pop * x_no2, na.rm = T)/sum(pop, na.rm = T),
                          pop = sum(pop)
                          ),
                       by = .(ASGS_2011v2, date_year)]

toplot_v4
toplot_v4 <- toplot_v4[!is.na(ASGS_2011v2)]
qc_ste_wide_no2 <- dcast(toplot_v4[,.(ASGS_2011v2, date_year, no2)], date_year ~ ASGS_2011v2)
qc_ste_wide_no2

qc_ste_wide_pm25 <- dcast(toplot_v4[,.(ASGS_2011v2, date_year, pm25)], date_year ~ ASGS_2011v2)
qc_ste_wide_pm25

stelabels <-  names(qc_ste_wide_no2)[-1]
# v1 missing g in ylab
#png("Fig2v2.png", res = 150, height = 950, width = 1400)
# with(toplot_v4[ASGS_2011v2 == stelabels[1]], plot(date_year, no2, type = 'l',
#                                                   lwd = 1.5, xlab = "Year",ylim = c(0,10),
#                                                   xlim = c(2012,2015),
#                                                   ylab = expression(paste("Population weighted NO"[2], " (", mu, "g/m"^3, ")"))))
# for(i in 2:length(stelabels)){
#   #i = 6
#   ste_lab <- stelabels[i]
#   with(toplot_v4[ASGS_2011v2 == ste_lab], lines(date_year, no2, type = 'l',
#                                                     lwd = 1.5, col = i)
#   )
# }
# legend("bottomright", legend = stelabels, lwd = 1.5, col = 1:length(stelabels))
# dev.off()

tbl_hia_baselineV5

tbl_pm25 <- tbl_hia_baselineV5[, .(SA2_MAINCODE_2016, value, Age, date_year, age_start, SA2_MAIN16, STE_CODE16, Time, ASGS_2011, Population, Deaths, rate_mort, rate_mort_rollmean_3, mort_n, x_pm25, x_no2, V1 = V1_pm25, pm25_lk_no_na, x_adjusted = x_adjusted_pm25, x_attrib = x_attrib_pm25, ASGS_2011v2, pollutant = "pm25")]

tbl_no2 <- tbl_hia_baselineV5[, .(SA2_MAINCODE_2016, value, Age, date_year, age_start, SA2_MAIN16, STE_CODE16, Time, ASGS_2011, Population, Deaths, rate_mort, rate_mort_rollmean_3, mort_n, x_pm25, x_no2, V1 = V1_no2, pm25_lk_no_na, x_adjusted = x_adjusted_no2, x_attrib = x_attrib_no2, ASGS_2011v2, pollutant = "no2")]

tbl_hia_baselineV6 <- rbind(tbl_pm25, tbl_no2)

tbl_hia_baseline <- tbl_hia_baselineV6


# Check counter-factual ---------------------------------------------------


tbl_hia_baseline[is.na(x_attrib), .N]
tbl_hia_baseline[is.na(x_attrib), ]
tbl_hia_baseline[SA2_MAIN16 == '102011028' & Time == 2015]
tbl_hia_baseline[SA2_MAIN16 == '102011028' & Time == 2016]
table(tbl_hia_baseline$Time)
tbl_hia_baseline[is.na(x_attrib),]# & Time != 2016,]
## TODO when value = 0 then x is NaN?  what to do here
tbl_hia_baseline[SA2_MAINCODE_2016 == "118011342" & Time == 2015]
#SA2_MAINCODE_2016
# for some manual checking

dir("data_provided")
#### w syd case study? ####
# TODO 
# sa2_todo <- readOGR("data_provided", "sa22016_case_studyV2")
# #plot(sa2_todo, add = T, col = 'red')
# str(sa2_todo@data)
# sa2todolist <- as.character(sa2_todo@data$SA2_MAIN16)
# class(tbl_hia_baseline$SA2_MAIN16)
# write.csv(tbl_hia_baseline[Time != 2016 & SA2_MAIN16 %in% sa2todolist,
#                            c('SA2_MAIN16',
#                            'date_year',
#                            'age_start',
#                            'value',
#                            'mort_n',
#                            'V1',
#                            'x_adjusted',
#                            'x_attrib')][
#                              order(SA2_MAIN16,
#                              date_year,
#                              age_start)]
#           , "working_temporary/tbl_hia_baseline_qc_20200427.csv", row.names = F)
## and also send Tim the whole thing, on 2020-05-26 remove the filter Time != 2016


# #### cf by climzone ####
# # Counter-factual
# str(tbl_x_cf_climzn)
# names(tbl_x_cf_climzn) <- c("climzn", "date_year", "V1_climzn")
# names(tbl_hia_baseline)
# names(tbl_sa2_to_climzn)
# tbl_hia_baseline_joind <- merge(tbl_hia_baseline, tbl_sa2_to_climzn[,c("SA2_MAIN16","climzn")], by = "SA2_MAIN16", all.x = T)
# tbl_hia_baseline_joind
# tbl_hia_baselineV4p1 <- left_join(tbl_hia_baseline_joind, tbl_x_cf_climzn, by = c("climzn", "date_year"), all.x = T) 
# 
# setDT(tbl_hia_baselineV4p1)
# tbl_hia_baselineV4p1
# tbl_hia_baselineV4p1[, .(x_adjusted, x)]
# with(tbl_hia_baselineV4p1[x_adjusted != x], plot(x_adjusted, x, xlim = c(0,6)))
# dev.off()
# summary(tbl_hia_baselineV4p1$x)
# summary(tbl_hia_baselineV4p1$x_adjusted)
# min(tbl_hia_baselineV4p1$x, na.rm = T)
# min(tbl_hia_baselineV4p1$x_adjusted, na.rm = T)
# 
# tbl_hia_baselineV4p1[,min(V1_climzn, na.rm = T), by = c("climzn", "date_year")]
# # note that there is a NA climzn missing x data
# 
# 
# 
# #### adjust 'x' so none lower than 5th centile by state ####
# # store the one that has no NAs
# #tbl_hia_baselineV4p1$pm25_lk_no_na <- tbl_hia_baselineV4p1$x
# length(unique(tbl_hia_baselineV4p1$SA2_MAIN16))
# # 2310
# # not 2292
# 
# ## V1 is the state based 5th centile (MB), x is the average PM2.5 within SA2s (from within the MBs
# str(tbl_hia_baselineV4p1)
# tbl_hia_baselineV4p1[x < V1_climzn,]
# ## TODO if the sa2 pm2.5 is below the 5th centile (MB) then set it to this TMREL (should this change?)
# tbl_hia_baselineV5p1 <- tbl_hia_baselineV4p1[,x_adjusted_climzn := ifelse(x < V1_climzn, V1_climzn, x)][]
# # calculate delta X (if the SA2 level is at the TMREL / 5thMB then there is zero anthropogenic)
# tbl_hia_baselineV5p1 <- tbl_hia_baselineV5p1[,x_attrib_climzn := (x_adjusted_climzn - V1_climzn)][]
# tbl_hia_baselineV5p1
# with(tbl_hia_baselineV5p1[x_adjusted_climzn != x_adjusted], plot(x_adjusted_climzn, x_adjusted, xlim = c(0,6)))
# with(tbl_hia_baselineV5p1, plot(x_adjusted_climzn, x_adjusted))
# 
# #### fig 2 pop weighted pm clim ####
# str(tbl_hia_baselineV5p1)
# toplot_v1 <- tbl_hia_baselineV5p1[,
#                                 .(pop = sum(value, na.rm = T)),
#                                 by = .(SA2_MAIN16, date_year)]
# toplot_v1[SA2_MAIN16 == 101021007]
# toplot_v2 <- tbl_hia_baselineV5p1[,
#                                 .N,
#                                 by = .(climzn, SA2_MAIN16, date_year, x)]
# toplot_v2
# nrow(toplot_v2); nrow(toplot_v1)
# toplot_v3 <- merge(toplot_v2, toplot_v1, by = c("SA2_MAIN16", "date_year"))
# toplot_v3
# 
# toplot_v4 <- toplot_v3[,.(pm25 = sum(pop * x, na.rm = T)/sum(pop, na.rm = T),
#                           pop = sum(pop)
# ),
# by = .(climzn, date_year)]
# 
# toplot_v4
# toplot_v4 <- toplot_v4[!is.na(climzn)]
# qc_ste_wide <- dcast(toplot_v4[,.(climzn, date_year, pm25)], date_year ~ climzn)
# qc_ste_wide
# 
# stelabels <-  names(qc_ste_wide)[-1]
# png("Fig2_climzn.png", res = 150, height = 950, width = 1400)
# with(toplot_v4[climzn == stelabels[1]], plot(date_year, pm25, type = 'l',
#                                                   lwd = 1.5, xlab = "Year",ylim = c(0,12),
#                                                   xlim = c(2006,2016),
#                                                   ylab = expression(paste("Population weighted PM"[2.5], " (", mu, "g/m"^3, ")"))))
# for(i in 2:length(stelabels)){
#   #i = 6
#   ste_lab <- stelabels[i]
#   with(toplot_v4[climzn == ste_lab], lines(date_year, pm25, type = 'l',
#                                                 lwd = 1.5, col = i)
#   )
# }
# legend("bottomright", legend = stelabels, lwd = 1.5, col = 1:length(stelabels))
# dev.off()
# 
# #  select(-STE_CODE16)
# tbl_hia_baselineV5p1
# str(tbl_hia_baselineV5p1)
# #### merge ste and climzone ####
# 
# tbl_hia_baseline_OUT2 <- tbl_hia_baselineV5p1
# 
# # qc 
# summary(tbl_hia_baseline_OUT2$pm25_lk_no_na)
# # why NAs?
# tbl_hia_baseline_OUT2[is.na(pm25_lk_no_na), .N, by = .(SA2_MAIN16, date_year)]
# tbl_hia_baseline_OUT2[SA2_MAIN16 == 103031075 & Time == 2015]
# # is it because pops (value) is 0?
# summary(tbl_hia_baseline_OUT2$value)
# tocheck <- unique(tbl_hia_baseline_OUT2[is.na(pm25_lk_no_na) & value >0,.(SA2_MAIN16, date_year, age_start, value, pm25_lk_no_na)]$SA2_MAIN16)
# paste(tocheck, sep = "", collapse = "', '")
# sum(tbl_hia_baseline_OUT2[is.na(pm25_lk_no_na) & value >0,.(SA2_MAIN16, date_year, age_start, value, pm25_lk_no_na)]$value)
# 41093
# length(unique(tbl_hia_baseline_OUT2$SA2_MAIN16))
# 
# ## so is this a problem? looks like a bunch of unpopulationed areas in QGIS
# qc <- tbl_hia_baseline_OUT2[is.na(pm25_lk_no_na) & value >0,.(SA2_MAIN16, date_year, age_start, value, pm25_lk_no_na)]
# qc[date_year == 2016,.(pop = sum(value)), by = .(SA2_MAIN16)]
# "
#     SA2_MAIN16  pop
#  1:  118011342    3
#  2:  205021080    3
#  3:  206041127    3
#  4:  310021279    3
#  5:  504031055    8
#  6:  505031106    7
#  7:  506011111   14
#  8:  506021120    7
#  9:  511031281    6
# 10:  801011018  145
# 11:  801041118  669
# 12:  801041120   99
# 13:  801051126    3
# 14:  801051128    3
# 15:  801101134    8
# 16:  801101139 2865
# 17:  901011001 1903
# 18:  901021002  546
# 19:  901031003  403
# 20:  901041004 1756
# "
# # 801101139 is Wright in ACT
# qc[SA2_MAIN16 == 801101139,.(pop = sum(value)), by = .(SA2_MAIN16, date_year)]
# tbl_hia_baseline_OUT2[SA2_MAIN16 == 801101139,.(pop = sum(value)), by = .(SA2_MAIN16, date_year)]
# 
# "
#     SA2_MAIN16 date_year  pop
#  1:  801101139      2006    0
#  2:  801101139      2007    0
#  3:  801101139      2008    0
#  4:  801101139      2009    0
#  5:  801101139      2010    0
#  6:  801101139      2011    0
#  7:  801101139      2012   22
#  8:  801101139      2013  200
#  9:  801101139      2014 1062
# 10:  801101139      2015 2121
# 11:  801101139      2016 2865
# "
# 
# tbl_hia_baseline_OUT2[,.(V1=mean(V1,na.rm=T),V1_climzn=mean(V1_climzn,na.rm=T),
#                          x_adjusted=mean(x_adjusted,na.rm=T),
#                          x_adjusted_climzn=mean(x_adjusted_climzn,na.rm=T),
#                          x_attrib=mean(x_attrib,na.rm=T),
#                          x_attrib_climzn=mean(x_attrib_climzn,na.rm=T),
#                          pm25_lk_no_na = mean(pm25_lk_no_na,na.rm=T),
#                          x = mean(x,na.rm=T)
#                          ), 
#                       by = c("date_year")]
# 
# 


# total deaths
#ASGS_2011 Population Deaths
# SNIP
"
                             'climzn',
                             'V1_climzn',
                             'x_adjusted_climzn',
                             'x_attrib_climzn'
"
#### write csv for tim ####
#names(tbl_hia_baseline_OUT2)
names(tbl_hia_baseline)
write.csv(tbl_hia_baseline[ ,
                           c('SA2_MAIN16',
                             'date_year',
                             'age_start',
                             'value',
                             'mort_n',
                             "V1",
                             "x_adjusted",
                             "x_attrib",
                             "pollutant"
                            
)][
                               order(SA2_MAIN16,
                                     date_year,
                                     age_start)]
          , paste0("working_temporary/tbl_hia_baseline_national_",run_label,".csv"), row.names = F)        


