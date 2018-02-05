setwd("/Users/fxleos/Downloads/Germany_data/2016")
library(lubridate)

rm(list = ls())
#DA
##Price
file = read.table("DE_Day-ahead prices_201601010000_201612312359_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
P_E_DA = as.numeric(gsub(",", "", file$Germany.Austria.Luxembourg.Euro.MWh.))
##Load
file = read.table("DE_Forecasted consumption_201601010000_201612312345_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
E_DA = as.numeric(gsub(",", "", file$Total.MWh.))

file = read.table("DE_Forecasted generation_201601010000_201612312359_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
G_forecated = as.numeric(gsub(",", "", file$Total.MWh.))

#RT
file = read.table("DE_Balancing energy_201601010000_201612312345_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
E_RT = as.numeric(gsub(",", "", file$Balancing.energy.volume.MWh.))
P_E_RT = as.numeric(gsub(",", "", file$Balancing.energy.price.Euro.MWh.))


#Primary control
file = read.table("DE_Primary control reserve_201601010000_201612312345_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
P_R_PR = as.numeric(gsub(",", "", file$Prices.of.procured.balancing.reserves.Euro.MW.))
R_PR = as.numeric(gsub(",", "", file$Volume.of.procured.balancing.services.MW.))

#Secondary control
file = read.table("DE_Secondary control reserve_201601010000_201612312345_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
R_RU = as.numeric(gsub(",", "", file$Volume.of.procured.balancing.services.....MW.))
R_RD = as.numeric(gsub(",", "", file$Volume.of.procured.balancing.services.....MW..1))
P_R_RU = as.numeric(gsub(",", "", file$Price.of.procured.balancing.services.....Euro.MW.))
P_R_RD = as.numeric(gsub(",", "", file$Price.of.procured.balancing.services.....Euro.MW..1))
E_RU = as.numeric(gsub(",", "", file$Volume.of.activated.balancing.services.....MWh.))
E_RD = as.numeric(gsub(",", "", file$Volume.of.activated.balancing.services.....MWh..1))
P_E_RU = as.numeric(gsub(",", "", file$Price.of.activated.balancing.services.....Euro.MWh.))
P_E_RD = as.numeric(gsub(",", "", file$Price.of.activated.balancing.services.....Euro.MWh..1))

## Tertiary control
file = read.table("DE_Tertiary control reserve_201601010000_201612312345_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
R_TRU = as.numeric(gsub(",", "", file$Volume.of.procured.balancing.services.....MW.))
R_TRD = as.numeric(gsub(",", "", file$Volume.of.procured.balancing.services.....MW..1))
P_R_TRU = as.numeric(gsub(",", "", file$Price.of.procured.balancing.services.....Euro.MW.))
P_R_TRD = as.numeric(gsub(",", "", file$Price.of.procured.balancing.services.....Euro.MW..1))
E_TRU = as.numeric(gsub(",", "", file$Volume.of.activated.balancing.services.....MWh.))
E_TRD = as.numeric(gsub(",", "", file$Volume.of.activated.balancing.services.....MWh..1))
P_E_TRU = as.numeric(gsub(",", "", file$Price.of.activated.balancing.services.....Euro.MWh.))
P_E_TRD = as.numeric(gsub(",", "", file$Price.of.activated.balancing.services.....Euro.MWh..1))

# Generation
file = read.table("DE_Actual generation_201601010000_201612312345_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
G_bio = as.numeric(gsub(",", "", file$Biomass.MWh.))
G_wind_on = as.numeric(gsub(",", "", file$Wind.onshore.MWh.))
G_wind_off = as.numeric(gsub(",", "", file$Wind.offshore.MWh.))
G_pv = as.numeric(gsub(",", "", file$Photovoltaics.MWh.))
G_hydro = as.numeric(gsub(",", "", file$Hydropower.MWh.))
G_otherRE = as.numeric(gsub(",", "", file$Other.renewable.MWh.))
G_nuclear = as.numeric(gsub(",", "", file$Nuclear.MWh.))
G_coal_brown = as.numeric(gsub(",", "", file$Fossil.brown.coal.MWh.))
G_coal_hard = as.numeric(gsub(",", "", file$Fossil.hard.coal.MWh.))
G_gas = as.numeric(gsub(",", "", file$Fossil.gas.MWh.))
G_phes = as.numeric(gsub(",", "", file$Hydro.pumped.storage.MWh.))
G_otherCONV = as.numeric(gsub(",", "", file$Other.conventional.MWh.))

## post process
rm(list = 'file')
for (v in ls()){
  if (v != 'v' && v != 'value'){
    value = get(v)
    value[is.na(value)]=0
    assign(v, value)
  }
}
for (v in c("E_RT","E_RD", "E_RU", "E_TRD", "E_TRU")){
  value = get(v)
  price.name = paste("P",v,sep="_")
  price.value = get(price.name)
  price.value = price.value * value
  
  value = unname(tapply(value,(seq_along(value)-1) %/% 4, sum))
  price.value = unname(tapply(price.value,(seq_along(price.value)-1) %/% 4, sum))
  price.value = price.value/value
  price.value[is.na(price.value)] = 0
  assign(v,value)
  assign(price.name,price.value)
}

for (v in c("R_PR","R_RD", "R_RU", "R_TRD", "R_TRU")){
  value = get(v)
  price.name = paste("P",v,sep="_")
  price.value = get(price.name)
  price.value = price.value * value
  
  value = unname(tapply(value,(seq_along(value)-1) %/% 4, sum))
  price.value = unname(tapply(price.value,(seq_along(price.value)-1) %/% 4, sum))
  price.value = price.value/value
  value = value/4
  assign(v,value)
  assign(price.name,price.value)
}

for (v in c("E_DA", "G_gas", "G_coal_brown", "G_coal_hard", "G_bio", "G_hydro", "G_nuclear", "G_wind_on", "G_wind_off", "G_pv", "G_otherRE", "G_phes", "G_otherCONV")){
  value = get(v)
  value = unname(tapply(value,(seq_along(value)-1) %/% 4, sum))
  assign(v,value)
}


P_R_PR = P_R_PR/(7*24)  #weekly block precured
P_R_TRD = P_R_TRD/6 # 4*6 bloack precured
P_R_TRU = P_R_TRU/6 # 4*6 bloack precured
time_vector = seq(as.POSIXct("2016-01-01 00:00:00"), as.POSIXct("2016-12-31 23:59:59"), by = "hour")
index_peak = wday(time_vector) != 1 & wday(time_vector) != 7 & hour(time_vector)>=8 & hour(time_vector)<16 
P_R_RU[index_peak] = P_R_RU[index_peak]/60 # peak block
P_R_RU[!index_peak] = P_R_RU[!index_peak]/108
P_R_RD[index_peak] = P_R_RD[index_peak]/60
P_R_RD[!index_peak] = P_R_RD[!index_peak]/108
P_E_RD = -P_E_RD
E_RD = -E_RD

DataToBeWrite = data.frame(P_E_DA,E_DA, P_E_RT, E_RT, P_R_PR, R_PR, P_R_RU, P_R_RD, R_RU, R_RD, P_E_RU, P_E_RD, E_RU, E_RD)
write.csv(DataToBeWrite,file = "DE_2016_EN_REG.csv")
DataToBeWrite = data.frame(G_gas, G_coal_brown, G_coal_hard, G_bio, G_hydro, G_nuclear, G_wind_on, G_wind_off, G_pv, G_otherRE, G_phes, G_otherCONV)
write.csv(DataToBeWrite,file = "DE_2016_GEN.csv")

plot(P_R_RD,type = 'l')

DA_total_EUR = sum(P_E_DA*E_DA)
DA_total_MWh = sum(E_DA)
RT_total_EUR = sum(P_E_RT*E_RT)
RT_total_MWh = sum(E_RT)
PR_total_EUR = sum(P_R_PR*R_PR)
PR_max_MW = max(R_PR)
SR_RU_MW = max(R_RU)
SR_RD_MW = max(R_RD)
SR_RU_MWh = sum(E_RU)
SR_RD_MWh = sum(E_RD)
SR_R_RU_EUR = sum(P_R_RU*R_RU)
SR_R_RD_EUR = sum(P_R_RD*R_RD)
SR_E_RU_EUR = sum(P_E_RU*E_RU)
SR_E_RD_EUR = sum(P_E_RD*E_RD)
TR_RU_MW = max(R_TRU)
TR_RD_MW = max(R_TRD)
TR_RU_MWh = sum(E_TRU)
TR_RD_MWh = sum(E_TRD)
TR_R_RU_EUR = sum(P_R_TRU*R_TRU)
TR_R_RD_EUR = sum(P_R_TRD*R_TRD)
TR_E_RU_EUR = sum(P_E_TRU*E_TRU)
TR_E_RD_EUR = sum(P_E_TRD*E_TRD)


DataToBeWrite = data.frame(DA_total_EUR,
                           DA_total_MWh,
                           RT_total_EUR,
                           RT_total_MWh,
                           PR_total_EUR,
                           PR_max_MW,
                           SR_RU_MW,
                           SR_RD_MW,
                           SR_RU_MWh,
                           SR_RD_MWh,
                           SR_R_RU_EUR,
                           SR_R_RD_EUR,
                           SR_E_RU_EUR,
                           SR_E_RD_EUR,
                           TR_RU_MW,
                           TR_RD_MW,
                           TR_RU_MWh,
                           TR_RD_MWh,
                           TR_R_RU_EUR,
                           TR_R_RD_EUR,
                           TR_E_RU_EUR,
                           TR_E_RD_EUR)

write.csv(DataToBeWrite,file = "DE_2016_market_overview.csv")
