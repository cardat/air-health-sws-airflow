# Import PM2.5 ----------------------------------------------------

#### import 2000 - 2015 ####
#path_provided
#dir(dirname(path_provided))
tbl_x_mb_import <- fread(path_provided, colClasses = c("MBCODE11" = "character"))
setnames(tbl_x_mb_import, "MBCODE11", "MB_CODE11")
##tbl_x_mb_import$MB_CODE11 <- NULL
# str(tbl_x_mb_import[,1:4])
# t(tbl_x_mb_import[MBCODE11 == "10032890000"])
# str(tbl_x_mb_import)
tbl_x_mb_import
qc <- tbl_x_mb_import[,.N, by = .(MB_CODE11)][N>1][order(N)]
qc
qc[,.N, by = .(substr(MB_CODE11,1,1))]
## no duplicates. good

#paste(names(tbl_x_mb_import), sep = '', collapse = "', '")
tbl_x_mb_import <- tbl_x_mb_import[,c('MB_CODE11', 'SAT2000', 'SAT2001', 'SAT2002', 'SAT2003', 'SAT2004', 'SAT2005', 'SAT2006', 'SAT2007', 'SAT2008', 'SAT2009', 'SAT2010', 'SAT2011', 'SAT2012', 'SAT2013', 'SAT2014', 'SAT2015', 'SATW2000', 'SATW2001', 'SATW2002', 'SATW2003', 'SATW2004', 'SATW2005', 'SATW2006', 'SATW2007', 'SATW2008', 'SATW2009', 'SATW2010', 'SATW2011', 'SATW2012', 'SATW2013', 'SATW2014', 'SATW2015', 'NSATW2000', 'NSATW2001', 'NSATW2002', 'NSATW2003', 'NSATW2004', 'NSATW2005', 'NSATW2006', 'NSATW2007', 'NSATW2008', 'NSATW2009', 'NSATW2010', 'NSATW2011', 'NSATW2012', 'NSATW2013', 'NSATW2014', 'NSATW2015', 'NOSAT')]


#### import 2016 ####
tbl_x_mb_import16 <- fread(path_provided_pm16, colClasses = c("MB_CODE11" = "character"))


# str(tbl_x_mb_import16[,1:4])
# t(tbl_x_mb_import16[MBCODE11 == "10032890000"])
# str(tbl_x_mb_import16)
tbl_x_mb_import16
qc <- tbl_x_mb_import16[,.N, by = .(MB_CODE11)][N>1][order(N)]
qc
qc[,.N, by = .(substr(MB_CODE11,1,1))]
## no duplicates. good

tbl_x_mb_import16 <- tbl_x_mb_import16[,c('MB_CODE11')]
nrow(tbl_x_mb_import)
nrow(tbl_x_mb_import16)

tbl_x_mb_import <- merge(tbl_x_mb_import, tbl_x_mb_import16, by = c("MB_CODE11"), all.x = T)

#### convert ####

tbl_x_mb_long <- melt(tbl_x_mb_import, id.vars = "MB_CODE11")

#tbl_x_mb_long[MBCODE11 == "10032890000"]

#tbl_x_mb_long[,.N,"variable"]
tbl_x_mb_long <- tbl_x_mb_long[variable != "NOSAT"]

## need to do some work on the labels
namedf <- data.frame(tbl_x_mb_long$variable, tbl_x_mb_long$variable)
x <- as.character(namedf[,2])
namedf$date_year <- substr(x, nchar(x)-3, nchar(x))
x <- as.character(namedf[,1])
namedf$variable <- substr(x, 1, nchar(x)-4)
head(namedf)
tail(namedf)
table(namedf$date_year, namedf$variable)
# this shows that we only have SAT PM model data for 2016 (which is fine, it is the best model Luke made)
"
        NSATW    SAT   SATW
  2000 347443 347443 347443
  2001 347443 347443 347443
  2002 347443 347443 347443
  2003 347443 347443 347443
  2004 347443 347443 347443
  2005 347443 347443 347443
  2006 347443 347443 347443
  2007 347443 347443 347443
  2008 347443 347443 347443
  2009 347443 347443 347443
  2010 347443 347443 347443
  2011 347443 347443 347443
  2012 347443 347443 347443
  2013 347443 347443 347443
  2014 347443 347443 347443
  2015 347443 347443 347443
  2016      0 347443      0
"

#class(tbl_x_mb_long)

tbl_x_mb_long <- cbind(tbl_x_mb_long, namedf[,c("variable", "date_year")])
names(tbl_x_mb_long) <- c("MB_CODE11","variable","value", "type", "date_year")

#### select the primary exposure variable ####
# we will use the SAT model estimates
tbl_x_mb_long <- tbl_x_mb_long[type == "SAT"]
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


saveRDS(tbl_x_mb_import, "working_temporary/pm25_lur/tbl_pm25_sat_mb.rds")
saveRDS(tbl_x_mb_long, "working_temporary/pm25_lur/tbl_pm25_sat_mb_lng.rds")

