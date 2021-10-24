
dir("working_temporary/pm25_lur/")
tbl_x_sa2_long_pm <- readRDS("working_temporary/pm25_lur/tbl_x_sa2_long.rds")
tbl_x_cf_ste_pm <- readRDS("working_temporary/pm25_lur/tbl_x_cf_ste.rds") 


tbl_x_sa2_long_no <- readRDS("working_temporary/no2_lur/tbl_x_sa2_long.rds")
tbl_x_cf_ste_no <- readRDS("working_temporary/no2_lur/tbl_x_cf_ste.rds") 

str(tbl_x_sa2_long_pm)
tbl_x_sa2_long_pm$x_pm25 <- tbl_x_sa2_long_pm$x
tbl_x_sa2_long_pm$x <- NULL  

str(tbl_x_sa2_long_no)
tbl_x_sa2_long_no$x_no2 <- tbl_x_sa2_long_no$x
tbl_x_sa2_long_no$x <- NULL  

tbl_x_sa2_long <- merge(tbl_x_sa2_long_pm, tbl_x_sa2_long_no, by = c("SA2_MAIN16", "date_year"))



str(tbl_x_cf_ste_no)
tbl_x_cf_ste_no$STE_CODE11 <- as.character(tbl_x_cf_ste_no$STE_CODE11)
tbl_x_cf_ste_no$V1_no2 <- tbl_x_cf_ste_no$V1
tbl_x_cf_ste_no$V1 <- NULL

tbl_x_cf_ste_pm$V1_pm25 <- tbl_x_cf_ste_pm$V1
tbl_x_cf_ste_pm$V1 <- NULL

tbl_x_cf_ste <- merge(tbl_x_cf_ste_pm, tbl_x_cf_ste_no, by = c("STE_CODE11", "date_year"))

#### Remove NAs and QC ####
head(tbl_x_sa2_long)
tbl_x_sa2_long_pm[SA2_MAIN16 == 506021120,]
# this is 'Kewdale Commercial'
sum(tbl_pop_sa2[SA2_MAIN16 == 506021120,"value"])
20
# so I think this is missing data due to lack of population?

# remove the NAs
tbl_x_sa2_long <- tbl_x_sa2_long[!is.na(tbl_x_sa2_long$SA2_MAIN16)]


summary(tbl_x_sa2_long)
foo <- tbl_x_sa2_long[,.(pm25 = mean(x_pm25, na.rm = T),
                         no2 = mean(x_no2, na.rm = T)
                         ), by = .(SA2_MAIN16)]

shp_sa2 <- readOGR(path_sa2)
qc_x_shp <- shp_sa2
names(qc_x_shp@data)
qc_x_shp@data <- left_join(qc_x_shp@data, foo, by = "SA2_MAIN16")

# writeOGR(qc_x_shp, "working_temporary", "qc_x_shp", driver = "ESRI Shapefile")

#### check and convert units ####
# par(mfrow = c(3,1))
# hist(tbl_x_sa2_long$x_pm25, xlab = "ug/m3")
# hist(tbl_x_sa2_long$x_no2, xlab = "ppb")
tbl_x_sa2_long$x_no2_ppb <- tbl_x_sa2_long$x_no2
tbl_x_sa2_long$x_no2 <- tbl_x_sa2_long$x_no2 * 1.88
# following WHO https://uk-air.defra.gov.uk/assets/documents/reports/cat06/0502160851_Conversion_Factors_Between_ppb_and.pdf
#hist(tbl_x_sa2_long$x_no2, xlab = "ug/m3")
tbl_x_sa2_long <- tbl_x_sa2_long[,.(SA2_MAIN16, date_year, x_pm25, x_no2)]

## now do the cf
tbl_x_cf_ste
tbl_x_cf_ste$V1_no2_ppb <- tbl_x_cf_ste$V1_no2
tbl_x_cf_ste$V1_no2 <- tbl_x_cf_ste$V1_no2 * 1.88
tbl_x_cf_ste <- tbl_x_cf_ste[,.(STE_CODE11, date_year, V1_pm25, V1_no2)]

#### write results ####

saveRDS(tbl_x_sa2_long, "working_temporary/tbl_x_sa2_long.rds")
saveRDS(tbl_x_cf_ste, "working_temporary/tbl_x_cf_ste.rds") 
