setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/PJM_data/2016")


Sys.setenv(TZ='UTC')
rm(list = ls())
# DA
## load
file_da_demand = read.csv("hrl_dmd_bids.csv")
E_DA = file_da_demand$hrly_da_demand_bid
E_DA_time = file_da_demand$datetime_beginning_utc
E_DA_time = strptime(E_DA_time,format="%m/%d/%Y %I:%M:%S %p")
## price
file_P_E_DA = read.csv("da_hrl_lmps.csv")
P_E_DA = file_P_E_DA$total_lmp_da
P_E_DA_time = file_P_E_DA$datetime_beginning_utc
P_E_DA_time = strptime(P_E_DA_time,format="%m/%d/%Y %I:%M:%S %p")


## time issure
length_correct = length(P_E_DA)
E_DA = numeric(length_correct)
for (i in 1:length_correct){
  if (E_DA_time[i] != P_E_DA_time[i]){
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
P_E_RT = file_rt_price$total_lmp_rt


# file_price = read.csv("rt_da_monthly_lmps.csv")


# Ancillary Service market result
file_reg = read.csv("reg_market_results.csv")
reg_time = file_reg$datetime_beginning_utc
reg_time = strptime(reg_time,format="%m/%d/%Y %I:%M:%S %p")
R_REG_d = file_reg$regd_procure
R_REG_a = file_reg$rega_procure
R_REG_total = file_reg$total_mw
Performance = file_reg$rto_perfscore
MilleageA = file_reg$rega_hourly
MilleageD = file_reg$regd_hourly
R_REG_d[is.na(R_REG_d)] = 0
R_REG_a[is.na(R_REG_a)] = 0
R_REG_total[is.na(R_REG_total)] = 0
Performance[is.na(Performance)] = 0
MilleageA[is.na(MilleageA)] = 0
MilleageD[is.na(MilleageD)] = 0

file_reg2 = read.csv("reg_zone_prelim_bill.csv")
P_RMCCP = file_reg2$rmccp
P_RMCCP[is.na(P_RMCCP)] = 0
P_RMPCP = file_reg2$rmpcp
P_RMPCP[is.na(P_RMPCP)] = 0
LostOp_USD = file_reg2$total_pjm_loc_credit
LostOp_USD[is.na(LostOp_USD)] = 0
P_R_REG_d = (P_RMCCP + P_RMPCP * MilleageD) * Performance
P_R_REG_a = (P_RMCCP + P_RMPCP * MilleageA) * Performance

## Area control
file_error = read.csv("2016-ace-ten-minute-data-ferc-784.csv")

E_REG = -unname(tapply(file_error$value,(seq_along(file_error$value)-1) %/% 6, sum))/6
delta_REG = E_REG/(R_REG_total)
delta_REG[is.na(delta_REG)]=0
delta_REG_p = numeric(length(delta_REG))
delta_REG_n = delta_REG_p
delta_REG_p[delta_REG >= 0] = delta_REG[delta_REG >= 0]
delta_REG_n[delta_REG < 0] = - delta_REG[delta_REG < 0]


CorrectTime <- function(x, time_x, time_benchmark){
  length_correct = length(time_benchmark)
  y = numeric(length_correct)
  for (i in 1: length_correct){
    if (time_x[i] != time_benchmark[i]){
      y[1:(i-1)] = x[1:(i-1)]
      y[i]=0
      y[(i+1):length_correct] = x[i:length(x)]
      break
    }
  }
  return(y)
}


## Extract synchronized reserve in PJM RTO region
file_as = read.csv('reserve_market_results.csv')
index_sr = file_as$locale == "PJM_RTO" & file_as$service == "SR"

as_time = file_as$datetime_beginning_utc
as_time= strptime(as_time,format="%m/%d/%Y %I:%M:%S %p")
R_SR_total = file_as$total_mw[index_sr]
R_SR_tier1 = file_as$tier1_mw[index_sr]
R_SR_dsm = file_as$dsr_as_mw[index_sr]
R_SR_total[is.na(R_SR_total)] = 0
R_SR_tier1[is.na(R_SR_tier1)] = 0
R_SR_dsm[is.na(R_SR_dsm)] = 0
P_R_SR = file_as$mcp[index_sr]
P_R_SR[is.na(P_R_SR)] = 0
# Time issue
sr_time = as_time[index_sr]
index_sr_time = !logical(length(sr_time))
for (i in 2:length(sr_time)){
  if (sr_time[i-1] == sr_time[i]){
    index_sr_time[i]=FALSE
  }
}
sr_time = sr_time[index_sr_time]
R_SR_tier1 = R_SR_tier1[index_sr_time]
R_SR_dsm = R_SR_dsm[index_sr_time]
R_SR_total = R_SR_total[index_sr_time]
P_R_SR= P_R_SR[index_sr_time]

R_SR_tier1 = CorrectTime(R_SR_tier1, reg_time, P_E_DA_time)
R_SR_dsm = CorrectTime(R_SR_dsm, reg_time, P_E_DA_time)
R_SR_total = CorrectTime(R_SR_total, reg_time, P_E_DA_time)
P_R_SR = CorrectTime(P_R_SR, reg_time, P_E_DA_time)
R_SR_tier2 = R_SR_total - R_SR_tier1

file = read.csv('sync_reserve_prelim_bill.csv')
zone = file$subzone
LostOp_SR_USD = file$total_subz_lost_opp_cred_clrd[as.character(zone) == "PJM Mid Atlantic Dominion (MAD)"]

## Extract primary reserve in PJM RTO region
index_pr = file_as$locale == "PJM_RTO" & file_as$service == "PR"

R_NSR = file_as$total_mw[index_pr]
R_NSR_nsr = file_as$tier1_mw[index_pr]
R_NSR[is.na(R_NSR)] = 0
R_NSR_nsr[is.na(R_NSR_nsr)] = 0
P_R_NSR = file_as$mcp[index_pr]
P_R_NSR[is.na(P_R_NSR)] = 0
# Time issue
pr_time = as_time[index_pr]
index_pr_time = !logical(length(pr_time))
for (i in 2:length(pr_time)){
  if (pr_time[i-1] == pr_time[i]){
    index_pr_time[i]=FALSE
  }
}
pr_time = pr_time[index_pr_time]
R_NSR = R_NSR[index_pr_time]
R_NSR_nsr = R_NSR_nsr[index_pr_time]
P_R_NSR = P_R_NSR[index_pr_time]

R_NSR = CorrectTime(R_NSR, reg_time, P_E_DA_time)
R_NSR_nsr = CorrectTime(R_NSR_nsr, reg_time, P_E_DA_time)
P_R_NSR = CorrectTime(P_R_NSR, reg_time, P_E_DA_time)



# Generation


# Output
DataToBeWrite = data.frame(P_E_DA,E_DA, P_E_RT, E_RT_total, P_R_REG_a, P_R_REG_d, R_REG_a, R_REG_d, delta_REG_p, delta_REG_n)
write.csv(DataToBeWrite,file = "PJM_2016_EN_REG.csv")

#DataToBeWrite = data.frame(G_gas, G_coal_brown, G_coal_hard, G_bio, G_hydro, G_nuclear, G_wind_on, G_wind_off, G_pv, G_otherRE, G_phes, G_otherCONV)
#write.csv(DataToBeWrite,file = "DE_2016_GEN.csv")


DA_total_USD = sum(P_E_DA*E_DA)
DA_total_MWh = sum(E_DA)
RT_total_USD = sum(P_E_RT[E_RT_total>=0]*E_RT_total[E_RT_total>=0]) - sum(P_E_RT[E_RT_total<0]*E_RT_total[E_RT_total<0])
RT_total_MWh = sum(E_RT_total)
REG_d_USD = sum(P_R_REG_d*R_REG_d)
REG_a_USD = sum(P_R_REG_a*R_REG_a)
REG_d_MW = max(R_REG_d)
REG_a_MW = max(R_REG_a)
REG_E_USD = sum(E_REG*P_E_RT)
REG_MWh = sum(E_REG)
REG_LO_USD = sum(LostOp_USD)
SR_R_USD = sum(P_R_SR*R_SR_tier2)
SR_MW = max(R_SR_total)
SR_2_MW = max(R_SR_tier2)
SR_LO_USD = sum(LostOp_SR_USD)
NSR_R_USD = sum(P_R_NSR*R_NSR)
NSR_MW = max(R_NSR)


DataToBeWrite = data.frame(DA_total_USD,
                           DA_total_MWh,
                           RT_total_USD,
                           RT_total_MWh,
                           REG_d_USD,
                           REG_a_USD,
                           REG_d_MW,
                           REG_a_MW,
                           REG_E_USD,
                           REG_MWh,
                           REG_LO_USD,
                           SR_R_USD,
                           SR_MW,
                           SR_2_MW,
                           SR_LO_USD,
                           NSR_R_USD,
                           NSR_MW)

write.csv(DataToBeWrite,file = "PJM_2016_market_overview.csv")

