# Set counter-factual --------------------------------------------
# following COMEAP we use 5th percentile 


tbl_x_mb <- readRDS("working_temporary/pm25_lur/tbl_pm25_sat_mb_lng.rds")
str(tbl_x_mb)

x <- tbl_x_mb[, quantile(value, na.rm = T, probs = 0.05)]

temporal_extent <- 2012:2015
tbl_x_cf_ste <- data.table(STE_CODE11 = rep(1:9, length(temporal_extent)), 
                           date_year = temporal_extent, V1 = x)
tbl_x_cf_ste[order(STE_CODE11, date_year)]

saveRDS(tbl_x_cf_ste, "working_temporary/no2_lur/tbl_x_cf_ste.rds")
