# Aggregate PM2.5 to SA2 --------------------------------------------------


# Load and prep data ------------------------------------------------------

tbl_x_mb <- readRDS("working_temporary/pm25_lur/tbl_pm25_sat_mb_lng.rds")
tbl_x_mb
tbl_x_mb[MB_CODE11 == "10032890000"][order(variable, date_year)]

## I want all 2011 MBs on 2016 SA2s
# these are the base analytic units
indsa2 <- readOGR(path_sa2)
str(indsa2@data)
# this also has the GCCs in it

## use Josh's big st_intersect result, first check they are the same
tbl_mb_int <- readRDS(path_mb_int)

setDT(tbl_mb_int)
names(tbl_mb_int)
tbl_mb_int_mb11_sa216 <- tbl_mb_int[,.(int_area = max(int_area)),.(MB_CODE11)]
tbl_mb_int[MB_CODE11 == '80044770000']

tbl_mb_int_mb11_sa216[MB_CODE11 == '80044770000']
qc <- merge(tbl_mb_int_mb11_sa216, tbl_mb_int, by = c("MB_CODE11", "int_area"))
qc[MB_CODE11 == '80044770000',.(MB_CODE11, SA2_MAIN16, int_area)]
qc2 <- qc[,.(MB_CODE11, SA2_MAIN16, int_area)]
qc2[SA2_MAIN16 == "119011355"]

#### Aggregate ####


# names(tbl_mb_int)

head(tbl_mb_int[,.(MB_CODE11, SA2_MAIN16, int_area)])
qc3 <- merge(qc2, tbl_mb_int[,.(MB_CODE11, SA2_MAIN16, int_area)], 
             by = c("MB_CODE11", "SA2_MAIN16", "int_area"))
head(qc3)
nrow(qc3)
# 347359

tbl_mb_concordance <- qc3[,.N, by = .(MB_CODE11, SA2_MAIN16)]
str(tbl_mb_concordance)
tbl_mb_concordance
str(tbl_x_mb)
table(tbl_x_mb$date_year)

tbl_mb_concordance[SA2_MAIN16 == "119011355"]
tbl_x_mb[MB_CODE11 == "10032890000"][order(variable, date_year)]
tbl_x_mb[value==0]

## need pops
mb_pops_2011 <- fread(path_2011_mb_pop)
str(mb_pops_2011)
mb_pops_2011$MB_CODE11 <- mb_pops_2011$Mesh_Block_ID
tbl_x_mbV2 <- merge(tbl_x_mb, mb_pops_2011, by = "MB_CODE11", all.x = T)
nrow(tbl_mb_concordance) 
nrow(tbl_x_mbV2)
head(tbl_x_mbV2)
tbl_x_mbV2[MB_CODE11 == "10032890000"][order(variable, date_year)]


tbl_x_sa2_long <- merge(tbl_mb_concordance, tbl_x_mbV2, by = "MB_CODE11", all.y = T)
## TODO check if there is mismatch here
qc <- tbl_x_sa2_long[is.na(SA2_MAIN16), .N, by = "MB_CODE11"]
qc

tbl_x_sa2_long[SA2_MAIN16 == "119011355"]
tbl_x_sa2_long[SA2_MAIN16 == "108031161"]
tbl_x_sa2_long[value==0]

# TODO QC why zeros or NAs, and make a map
qc <- tbl_x_sa2_long[is.na(value),.N,by="MB_CODE11"]
qc

mb_sp <- readOGR(indir_mb_2011, "MB_2011_NSW")
mb_sp2 <- mb_sp
str(mb_sp2@data)
setDF(qc)
head(qc)
nrow(qc)
nrow(mb_sp2@data)

mb_sp2@data <- left_join(mb_sp2@data, qc, by = "MB_CODE11")
mb_sp2 <- mb_sp2[!is.na(mb_sp2@data$N),]
#plot(mb_sp2)
nrow(mb_sp2@data)
dir("working_temporary/qc_missing_shape")
#writeOGR(mb_sp2, "working_temporary/qc_missing_shape","NEW_qc_mb_missing_shapefile_1_V2", driver = "ESRI Shapefile")
##  places in national parks. 
## lets make them equal the min
## TODO check why this is not 5th percentile (this is direct from import_x_mb, the do_x_cf is where the 5th was done)
min(tbl_x_sa2_long$value,na.rm = T)
tbl_x_sa2_long[is.na(tbl_x_sa2_long$value),"value"] <- 0.0002169406

tbl_x_sa2_long <- tbl_x_sa2_long[,
                                 .(x = sum(value * Persons_Usually_Resident, na.rm = T)/
                                     sum(Persons_Usually_Resident, na.rm = T),
                                   nMB = .N,
                                   pop = sum(Persons_Usually_Resident, na.rm = T)),
                                 by = .(SA2_MAIN16,  
                                        date_year)]
tbl_x_sa2_long[x==0]
# no more zeros
# check one problematic one that was missing in the final data merged in do_hia
tbl_x_sa2_long[SA2_MAIN16 == 801101139]
# empty
tbl_mb_concordance[SA2_MAIN16 == 801101139]
# missing!
tbl_mb_concordance[MB_CODE11 == 80055600000]
#sa2_16 = 801101135, it is in Wright, which is in ACT that only existed since 2012
#merge(tbl_mb_concordance, tbl_x_mbV2, by = "MB_CODE11")

tbl_x_sa2_long[,sum(pop), by = "date_year"][order(date_year)]

# TODO check the proper total population here
# 21455705 NEW
str(tbl_x_sa2_long)

# Save --------------------------------------------------------------------


saveRDS(tbl_x_sa2_long[,c("SA2_MAIN16", "date_year",  "x")], "working_temporary/pm25_lur/tbl_x_sa2_long.rds")


## QC

nrow(tbl_x_sa2_long)
table(substr(tbl_x_sa2_long$SA2_MAIN16, 1, 1))
tbl_x_sa2_long[SA2_MAIN16 == '109011172']
tbl_x_sa2_long[SA2_MAIN16 == '102011028']
tbl_x_sa2_long[SA2_MAIN16 == "119011355"]
