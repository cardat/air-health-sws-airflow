# Figures -----------------------------------------------------------------



# Packages ----------------------------------------------------------------


#library(ggplot2)


# Load data ---------------------------------------------------------------


#dt_pm_ucl_weighted <- readRDS("working_temporary/pm25_vd/dt_pm_ucl_weighted.rds")


# Plot saving function ----------------------------------------------------


# plot_fn <- function(fig_name, res = 150) {
#   png(filename = paste0("figures_and_tables/",fig_name,".png"),
#       width = 1000, height = 800, res = res)
#   print(get(fig_name))
#   dev.off()
# }


# UCL pop-weighted --------------------------------------------------------

# 
# fig_time_pm_ucl <- ggplot(dt_pm_ucl_weighted, aes(x = date_year, y = pm, group = UCL_NAM, color = UCL_NAM)) +
#   geom_line() +
#   geom_point() +
#   theme_minimal() +
#   scale_x_discrete("Date (year)") +
#   scale_y_continuous(expression(PM[2.5]~'('*mu*g/m^3*')'),limits = c(0,NA)) +
#   scale_color_discrete("UCL")
# 
# plot_fn("fig_time_pm_ucl")


