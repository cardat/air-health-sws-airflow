# Import NO2 ----------------------------------------------------

#### import 2012 - 2015 ####
#path_provided
#dir(dirname(path_provided))
tbl_x_mb_import <- fread(path_provided_no2, colClasses = c("MB_CODE11" = "character"))
tbl_x_mb_import$MBCODE11 <- tbl_x_mb_import$MB_CODE11
tbl_x_mb_import$MB_CODE11 <- NULL

# str(tbl_x_mb_import[,1:4])
# t(tbl_x_mb_import[MBCODE11 == "10032890000"])
# str(tbl_x_mb_import)
tbl_x_mb_import
qc <- tbl_x_mb_import[,.N, by = .(MBCODE11)][N>1][order(N)]
qc
qc[,.N, by = .(substr(MBCODE11,1,1))]
## no duplicates. good

#paste(names(tbl_x_mb_import), sep = '', collapse = "', '")
tbl_x_mb_import <- tbl_x_mb_import[,c('MBCODE11', 'PRED_NO2_2012_PPB', 'PRED_NO2_2013_PPB', 'PRED_NO2_2014_PPB', 'PRED_NO2_2015_PPB')]


# #### import 2016 ####
# tbl_x_mb_import16 <- fread(path_provided_pm16, colClasses = c("MBCODE11" = "character"))
# 
# # str(tbl_x_mb_import16[,1:4])
# # t(tbl_x_mb_import16[MBCODE11 == "10032890000"])
# # str(tbl_x_mb_import16)
# tbl_x_mb_import16
# qc <- tbl_x_mb_import16[,.N, by = .(MBCODE11)][N>1][order(N)]
# qc
# qc[,.N, by = .(substr(MBCODE11,1,1))]
# ## no duplicates. good
# 
# tbl_x_mb_import16 <- tbl_x_mb_import16[,c('MBCODE11','SAT2016')]
# nrow(tbl_x_mb_import)
# nrow(tbl_x_mb_import16)
# 
# tbl_x_mb_import <- merge(tbl_x_mb_import, tbl_x_mb_import16, by = c("MBCODE11"), all.x = T)

#### convert ####

tbl_x_mb_long <- melt(tbl_x_mb_import, id.vars = "MBCODE11")

#tbl_x_mb_long[MBCODE11 == "10032890000"]

#tbl_x_mb_long[,.N,"variable"]
#tbl_x_mb_long <- tbl_x_mb_long[variable != "NOSAT"]

## need to do some work on the labels
namedf <- data.frame(tbl_x_mb_long$variable, tbl_x_mb_long$variable)
x <- as.character(namedf[,2])
namedf$date_year <- substr(x, nchar(x)-7, nchar(x))
namedf$date_year <- gsub("_PPB", "", namedf$date_year)
x <- as.character(namedf[,1])
x <- gsub("PRED_", "", x)
namedf$variable <- substr(x, 1, 3)
head(namedf)
tail(namedf)
table(namedf$date_year, namedf$variable)

#class(tbl_x_mb_long)

tbl_x_mb_long <- cbind(tbl_x_mb_long, namedf[,c("variable", "date_year")])
names(tbl_x_mb_long) <- c("MB_CODE11","variable","value", "type", "date_year")

#### select the primary exposure variable ####
# we will use the SAT model estimates
#tbl_x_mb_long <- tbl_x_mb_long[type == "SAT"]
str(tbl_x_mb_long)

## some reformats
tbl_x_mb_long$value <- as.numeric(tbl_x_mb_long$value)
tbl_x_mb_long
tbl_x_mb_long$date_year <- as.integer(as.character(tbl_x_mb_long$date_year))
tbl_x_mb_long$MB_CODE11 <- as.character(tbl_x_mb_long$MB_CODE11)
str(tbl_x_mb_long)
# check the MBs with long codes that can be incorrectly shown as scientific notation
tbl_x_mb_long[MB_CODE11 == "10032890000"]
# Check ok?
# yes


# Export ------------------------------------------------------------------


saveRDS(tbl_x_mb_import, "working_temporary/no2_lur/tbl_no2_sat_mb.rds")
saveRDS(tbl_x_mb_long, "working_temporary/no2_lur/tbl_no2_sat_mb_lng.rds")

