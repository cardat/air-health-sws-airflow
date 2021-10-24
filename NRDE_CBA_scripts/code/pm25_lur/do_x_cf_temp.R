# Set counter-factual --------------------------------------------
# following COMEAP we use 5ug/m3 (ppb*1.88)

temporal_extent <- 2012:2015
tbl_x_cf_ste <- data.table(STE_CODE11 = rep(1:9, length(temporal_extent)), 
                           date_year = temporal_extent, V1 = 0)
tbl_x_cf_ste[order(STE_CODE11, date_year)]

saveRDS(tbl_x_cf_ste, "working_temporary/pm25_lur/tbl_pm25_sat_mb_lng.rds")

# Use case scenarios: reductions in pollutant concentrations 

do_x_cf_ratio <- TRUE
if(do_x_cf_ratio){
  tbl_x_ste_ratio <- readRDS("C:/Users/Timothy Chaston/cloudstor/Shared/NRDE_CBA/data_air_pollution/data_derived/scenarios_mb11_pm25_prop_20210825.rds")
  tbl_x_ste_ratio$MB_CODE11 <- as.character(tbl_x_ste_ratio$MB_CODE11)
  tbl_x_ste_ratio <- tbl_x_ste_ratio[, c("s51_n", "MB_CODE11")]
  
  tbl_x_mb <- readRDS("working_temporary/pm25_lur/tbl_no2_sat_mb_lng.rds")
  tbl_x_mb$STE_CODE11 <- substr(tbl_x_mb$MB_CODE11,1,1)
  tbl_x_mb_adj <- merge(tbl_x_mb, tbl_x_ste_ratio, by = "MB_CODE11", allow.cartesian=TRUE)
  setnames(tbl_x_mb_adj, "value", "raw")
  tbl_x_mb_adj <- tbl_x_mb_adj[, value_adj := (raw*s51_n)]
  #tbl_x_mb[, value := ifelse(tbl_x_mb$value < 0, "0", tbl_x_mb$value)]
  tbl_x_mb_adj$value_adj <- as.numeric(tbl_x_mb_adj$value_adj)
  
  
  #qc5 <- tbl_x_mb_adj[, mean(raw, na.rm=T), by = .(STE_CODE11)]
  #setnames(qc5, "V1", "meanr")
  #qc6 <- tbl_x_mb_adj[, mean(value_adj, na.rm=T), by = .(STE_CODE11)]
  #ratio <- cbind(qc5, qc6)
  #ratio[, (ratio = V1/meanr)] 
  #fwrite(ratio, "working_temporary/concentration_summary.csv")
  
  tbl_x_mb_adj <- tbl_x_mb_adj[, value := (raw-value_adj)]
  tbl_x_mb_adj$value <- as.numeric(tbl_x_mb_adj$value)
  tbl_x_mb_adj <- tbl_x_mb_adj[ , c("MB_CODE11", "variable", "value", "type", "date_year")]
  saveRDS(tbl_x_mb_adj, "working_temporary/pm25_lur/tbl_pm25_sat_mb_lng.rds")
}


# alternately this script can set the cf as the 5th percentile wihtin the state (except ACT which is within NSW)
# for NO2 it is better to use the TMREL of 5ug/m3

do_5th_pct <- FALSE
if(do_5th_pct){
  tbl_x_mb <- readRDS("working_temporary/pm25_lur/tbl_no2_sat_mb_lng.rds")
  str(tbl_x_mb)
  
  # lowest MB by state ------------------------------------------------------
  
  #tbl_x_mb$STE_CODE11 <- substr(tbl_x_mb$MB_CODE11,1,1)
  tbl_x_cf_ste <- tbl_x_mb[,mean(value, na.rm = T), by = .(STE_CODE11, date_year)]
  tbl_x_cf_ste[order(STE_CODE11, date_year)]
  ## any zeros?
  #plot(density(tbl_x_mb$value, na.rm = T))
  nrow(tbl_x_mb[value == 0,])
  0
  # any NAs
  nrow(tbl_x_mb[value == 0 | is.na(value),])
  11832
  (11832/nrow(tbl_x_mb))*100
  # less than 1%
  
  qc <- tbl_x_mb[value == 0 | is.na(value),.N, by = "MB_CODE11"]
  qc
  qc <- tbl_x_mb[value == 0 & date_year == 2015,]
  qc <- tbl_x_mb[value == 0,]
  nrow(qc)
  # TODO no exact zeros, but there are NAs
  
  #### QC ####
  tbl_x_mb[,.N,by = "STE_CODE11"][order(STE_CODE11)]
  tbl_x_mb[,.N,by = c("MB_CODE11","STE_CODE11", "date_year")][N>1]
  # for(i in 1:9){
  # #  i = 8
  # path_mb <- path_mb_2011[i]
  # shpmb <- readOGR(dirname(path_mb), gsub("\\.shp", "",basename(path_mb)))
  # #class(shpmb)
  # #str(shpmb@data)
  # shpmb@data$MB_CODE11 <- as.character(shpmb@data$MB_CODE11)
  # #plot(shpmb)
  # str(qc)
  # qcout <- shpmb
  # qcout@data <- left_join(shpmb@data, qc, by = "MB_CODE11")
  # #head(qcout@data[!is.na(qcout@data$N),])
  # #plot(qcout[!is.na(qcout@data$N),], col = "yellow", add = F)
  # writeOGR(qcout[!is.na(qcout@data$N),], "working_temporary/qc_missing_shape", sprintf("qc_mb_missing_shapefile_%s", i), driver = "ESRI Shapefile", overwrite_layer = T)
  # }
  # 
  # # check in QGIS
  # 'looks like very remote? national parks? are they missing predictors?  
  # just set to the lowest (non-zero & non-missing) in each state'
  
  #### TODO set the NAs vals to ?? min? 5th pctile? ####
  tbl_x_mb$valueV2 <- tbl_x_mb$value
  tbl_x_mb[valueV2 == 0,"valueV2"] <- NA
  
  # get min MB value per state and year
  #tbl_x_cf_ste <- tbl_x_mb[,min(value, na.rm = T), by = .(STE_CODE11, date_year)]
  dcast(tbl_x_cf_ste[order(STE_CODE11, date_year)], date_year ~ STE_CODE11)
  
  # QC this has unrealistic values (0.01???)
  # ste_i = 2
  # yy = 2015
  # plot(density(tbl_x_mb[date_year == yy & STE_CODE11 == ste_i,]$value, na.rm = T))
  # x <- quantile(tbl_x_mb[date_year == yy & STE_CODE11 == ste_i,]$value, na.rm = T, probs = 0.05)
  # x
  # segments(x,0,x,1, col = "red")
  
  # let's set the limit of data density at fifth percentile by state (and year? no)
  ## and leave ACT inside the NSW
  ste <- tbl_x_mb[,.N,by = "STE_CODE11"][order(STE_CODE11)][,1]
  ste
  for(yy in 2012:2015){
    #  yy = 2012
    for(i in 1:8){
      #  i = 8
      if(i == 8){
        # ACT is inside the NSW
        ste_i <- ste[i]
        ste_i_touse <- 1
      } else {
        ste_i <- ste[i]
        ste_i_touse <- ste_i
      }
      
      x <- quantile(tbl_x_mb[date_year == yy & STE_CODE11 == ste_i_touse,]$valueV2, na.rm = T, probs = 0.05)
      # notice filter by ste_i rather than ste_i_touse which is going to select 8 for ACT, but use cf from NSW
      tbl_x_mb[date_year == yy & STE_CODE11 == as.integer(ste_i) & valueV2 < as.numeric(x),"valueV2"] <- as.numeric(x)
      # ## check one year/state/territory
      # x2 <- tbl_x_mb[date_year == yy & STE_CODE11 == ste_i_touse]#[valueV2 > 0 ,]
      # summary(x2$valueV2)
      # plot(density(x2$valueV2, na.rm = T))
      # lines(density(x2$value, na.rm = T), col = 'blue')
      # quantile(x2$valueV2, probs = c(0.001, 0.01, 0.02, 0.05), na.rm = T)
      # x <- quantile(x2$valueV2, na.rm = T, probs = 0.05)
      # x
      # segments(x,0,x,1, col = "red")
      
    }
    
    tbl_x_cf_ste <- tbl_x_mb[,mean(valueV2, na.rm = T), by = .(MB_CODE11, date_year)]
    qc2 <- dcast(tbl_x_cf_ste[order(STE_CODE11, date_year)], date_year ~ STE_CODE11)
    knitr::kable(qc2, digits = 2)
    min(qc2[,-1])
  }
  
  
  
  ## QC
  # ste_i = 2
  # yy = 2015
  # x2 <- tbl_x_mb[date_year == yy & STE_CODE11 == ste_i][value > 0 ,]
  # summary(x2$value)
  # plot(density(x2$valueV2, na.rm = T))
  # lines(density(x2$value, na.rm = T), col = "blue")
  # quantile(x2$valueV2, probs = c(0.001, 0.01, 0.02, 0.05))
  # x <- quantile(x2$valueV2, na.rm = T, probs = 0.05)
  # x
  # segments(x,0,x,1, col = "red")
  
  ## TODO make some maps to show where these MBs are in each state
  
  # Save --------------------------------------------------------------------
  
  
  saveRDS(tbl_x_cf_ste, "working_temporary/no2_lur/tbl_x_cf_ste.rds")
  
}
