
#### cost calc inputs ####
## prepare do this with an aggregated life table, estimate the un-exposed population LE based on avoided deaths (i.e. the deaths in the exposed pop + the AN)
yy_todo
for(yy in yy_todo){
  
  #  yy = yy_todo[1]
  tbl_hia_baseline_agg <- tbl_hia_baseline[,.(deaths = sum(mort_n, na.rm = T), 
                                              population = sum(value, na.rm = T)), 
                                           by = .(date_year, age_start)]
  indata_f <- tbl_hia_baseline_agg[date_year == yy]
  # indata_f[,.(sum(deaths), sum(population))]
  
  #with(indata_f, plot(age_start, population))
  # indata_f
  
  
  demog_data <- data.frame(age = indata_f$age_start,
                           population = indata_f$population,
                           deaths = indata_f$deaths)
  # demog_data
  
  # Calculate life table
  le <- burden_le(demog_data,
                  pm_concentration = 0,
                  RR = rr)
  names(le)
  le <- as.data.frame(le["baseline"])
  le
  # TODO this is LE in the exposed population, but we actually need the estimated LE in the un-exposed!
  
  
  #### get AN 
  # names(out_master)
  an_year_agg <- out_master[,.(an = sum(an, na.rm = T)
  ), 
  by = .(date_year, est_type, baseline.age)]
  
  an_year_agg <- dcast(an_year_agg, date_year + baseline.age ~ est_type, value.var = "an")
  # an_year_agg[date_year == yy]
  
  ## actually... do we want this avg across years? NO
  # an_age_agg <- out_master[,.(an = sum(an, na.rm = T)),
  #                          by = .(date_year, est_type, baseline.age)]
  # an_age_agg
  # an_age_agg_av <- an_age_agg[,. (an = mean(an, na.rm = T)), 
  #                             by = .(baseline.age, est_type)]
  # an_age_agg_av
  # an_age_agg_av_wide <- dcast(an_age_agg_av, baseline.age ~ est_type, value.var = "an")
  
  ## NO use each yy specific within a loop
  an_age_agg_av_wide <- an_year_agg[date_year == yy]
  
  an_age_agg_av_wide$age_start <- as.numeric(substr(an_age_agg_av_wide$baseline.age, 1,2))
  an_age_agg_av_wide <- an_age_agg_av_wide[order(age_start)]
  an_age_agg_av_wide
  knitr::kable(an_age_agg_av_wide[,.(sum(est), sum(lci), sum(uci))], digits = 1)
  
  indata_f
  
  demog_data_v0 <- merge(indata_f, an_age_agg_av_wide, by = c("date_year", "age_start"))
  demog_data_v0$expected <- demog_data_v0$deaths - demog_data_v0$est
  
  demog_data_v0[,-1]
  
  demog_data_NE <- data.frame(age = demog_data_v0$age_start,
                              population = demog_data_v0$population,
                              deaths = demog_data_v0$expected)
  # do the Non-Exposed population LE
  le_NE <- burden_le(demog_data_NE,
                     pm_concentration = 0,
                     RR = rr)
  # le_NE
  # le
  # just to be clear, use the impacted (they are the same, but baseline is the term for the Exposed pop)
  le_NE <- as.data.frame(le_NE["impacted"])
  #delta_LE <- le_NE[le_NE$impacted.age == '0 - 4', "impacted.ex"] - le[le$baseline.age == '0 - 4', "baseline.ex"] 
  #delta_LE * 365
  
  # le_NE
  
  ausbodpm2p5_cost_calc_inputs <- merge(an_age_agg_av_wide, 
                                        le_NE[,c("impacted.age","impacted.ex")], 
                                        by.x = "baseline.age", by.y = "impacted.age")
  
  ausbodpm2p5_cost_calc_inputs <- merge(ausbodpm2p5_cost_calc_inputs, 
                                        le[,c("baseline.age","baseline.ex")], 
                                        by.x = "baseline.age", by.y = "baseline.age")
  
  # ausbodpm2p5_cost_calc_inputs[order(age_start)]
  if(yy == 2006){
    ausbodpm2p5_cost_calc_inputs_out <- ausbodpm2p5_cost_calc_inputs[order(age_start)]
  } else {
    ausbodpm2p5_cost_calc_inputs_out <- rbind(ausbodpm2p5_cost_calc_inputs_out, 
                                              ausbodpm2p5_cost_calc_inputs[order(age_start)])
  }
  
}
ausbodpm2p5_cost_calc_inputs_out[baseline.age == '0 - 4']
ausbodpm2p5_cost_calc_inputs_out[baseline.age == '0 - 4', .(i.ex = mean(impacted.ex), 
                                                            b.ex = mean(baseline.ex))][,
                                                                                       i.ex - b.ex] * 365
ausbodpm2p5_cost_calc_inputs_out[baseline.age == '30 - 34']
ausbodpm2p5_cost_calc_inputs_out[baseline.age == '85+']
ausbodpm2p5_cost_calc_inputs_out
# avg over years
ausbodpm2p5_cost_calc_inputs_out_av <- ausbodpm2p5_cost_calc_inputs_out[, .(i.ex = mean(impacted.ex),
                                                                            est = mean(est),
                                                                            lci = mean(lci),
                                                                            uci = mean(uci)
),
by = c("baseline.age", "age_start")]

## ok this can be used to input to the cost calculator, but question: does ex have to be calculated for est, lci and uci?
# use est now

ausbodpm2p5_cost_calc_inputs_out_av$baseline.age <- paste0("'", ausbodpm2p5_cost_calc_inputs_out_av$baseline.age)

write.csv(ausbodpm2p5_cost_calc_inputs_out_av[order(age_start)], 
          paste0("figures_and_tables/ausbodpm2p5_cost_calc_inputs_",run_label,".csv"), 
          row.names = F)

# run the xlsx sheet in "ausbodpm2p5 cost calc.xlsx"


