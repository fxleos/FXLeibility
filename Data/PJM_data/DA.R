setwd("/Users/fxleos/Downloads/PJM_data/2016")


Sys.setenv(TZ='UTC')
rm(list = ls())
# DA
## load
file_da_demand = read.csv("hrl_dmd_bids.csv")
E_DA = file_da_demand$hrly_da_demand_bid
E_DA_time = file_da_demand$datetime_beginning_utc
E_DA_time = strptime(E_DA_time,format="%m/%d/%Y %I:%M:%S %p")
## price
file_P_DA = read.csv("da_hrl_lmps.csv")
P_DA = file_P_DA$total_lmp_da
P_DA_time = file_P_DA$datetime_beginning_utc
P_DA_time = strptime(P_DA_time,format="%m/%d/%Y %I:%M:%S %p")


## time issure
length_correct = length(P_DA)
E_DA = numeric(length_correct)
for (i in 1:length_correct){
  if (E_DA_time[i] != P_DA_time[i]){
    break
  }
}
E_DA[1:(i-2)] = file_da_demand$hrly_da_demand_bid[1:(i-2)]
E_DA[(i-1):(i)] = file_da_demand$hrly_da_demand_bid[i-1]/2
E_DA[(i+1):length_correct] = file_da_demand$hrly_da_demand_bid[i:(length_correct-1)]


# RT
## Load
file_metered_load = read.csv("hourly_loads.csv")
metered_load = file_metered_load$load
E_RT_total = metered_load - E_DA
E_RT_total[is.na(E_RT_total)] = 0
metered_load = E_RT_total+E_DA

# Price
file_rt_price = read.csv("rt_hrl_lmps.csv")
P_RT = file_rt_price$total_lmp_rt


# file_price = read.csv("rt_da_monthly_lmps.csv")

