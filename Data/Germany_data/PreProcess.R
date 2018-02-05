setwd("/Users/fxleos/Downloads/Germany_data/2016")


#DA
##Price
file = read.table("DE_Day-ahead prices_201601010000_201612312359_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
P_DA = as.numeric(gsub(",", "", file$Germany.Austria.Luxembourg.Euro.MWh.))
P_DA[is.na(P_DA)]=0
##Load
file = read.table("DE_Forecasted consumption_201601010000_201612312345_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
E_DA = as.numeric(gsub(",", "", file$Total.MWh.))
E_DA = unname(tapply(E_DA,(seq_along(E_DA)-1) %/% 4, sum))

file = read.table("DE_Forecasted generation_201601010000_201612312359_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
G_forecated = as.numeric(gsub(",", "", file$Total.MWh.))
G_forecated[is.na(G_forecated)]=0
G_forecated = unname(tapply(G_forecated,(seq_along(G_forecated)-1) %/% 4, sum))


#RT
file = read.table("DE_Balancing energy_201601010000_201612312345_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
E_RT = as.numeric(gsub(",", "", file$Balancing.energy.volume.MWh.))
P_RT = as.numeric(gsub(",", "", file$Balancing.energy.price.Euro.MWh.))

E_RT = unname(tapply(E_RT,(seq_along(E_RT)-1) %/% 4, sum))
P_RT = unname(tapply(P_RT,(seq_along(P_RT)-1) %/% 4, sum))

#Primary control
file = read.table("DE_Primary control reserve_201601010000_201612312345_1.csv",sep = ";", header = TRUE,stringsAsFactors=FALSE)
P_R_PR = as.numeric(gsub(",", "", file$Prices.of.procured.balancing.reserves.Euro.MW.))
R_PR = as.numeric(gsub(",", "", file$Volume.of.procured.balancing.services.MW.))
P_R_PR[is.na(P_R_PR)]=0
R_PR[is.na(R_PR)]=0
P_R_PR = unname(tapply(P_R_PR,(seq_along(P_R_PR)-1) %/% 4, sum))
R_PR = unname(tapply(R_PR,(seq_along(R_PR)-1) %/% 4, sum))

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

R_RU[is.na(R_RU)]=0
R_PR[is.na(R_PR)]=0
R_PR[is.na(R_PR)]=0
R_PR[is.na(R_PR)]=0
R_PR[is.na(R_PR)]=0
R_PR[is.na(R_PR)]=0
R_PR[is.na(R_PR)]=0
R_PR[is.na(R_PR)]=0


R_RU = unname(tapply(R_RU,(seq_along(R_RU)-1) %/% 4, sum))
R_RD = unname(tapply(R_RD,(seq_along(R_RD)-1) %/% 4, sum))
P_R_RU = unname(tapply(P_R_RU,(seq_along(P_R_RU)-1) %/% 4, sum))
P_R_RD = unname(tapply(P_R_RD,(seq_along(P_R_RD)-1) %/% 4, sum))
E_RU = unname(tapply(R_RD,(seq_along(E_RU)-1) %/% 4, sum))
E_RD = unname(tapply(R_PR,(seq_along(E_RD)-1) %/% 4, sum))
P_E_RU = unname(tapply(R_PR,(seq_along(P_E_RU)-1) %/% 4, sum))
P_E_RD = unname(tapply(R_PR,(seq_along(P_E_RD)-1) %/% 4, sum))

sum(R_RU*P_R_RU)
sum(R_RD*P_R_RD)
sum(E_RU*P_E_RU)
sum(E_RU)

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

