setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/PJM_data/2016")
file_gen = read.csv("gen_by_fuel.csv")
index_gen = file_gen$fuel_type == "Nuclear"

gen_wind = file_gen$mw[index_gen]
gen_wind_p = file_gen$fuel_percentage_of_total[index_gen]
gen_time = file_gen$datetime_beginning_utc[index_gen]
gen_time = strptime(gen_time,format="%m/%d/%Y %I:%M:%S %p")

#plot(metered_load[1:500],gen_wind_p[1:500])
#plot(gen_wind_p)
#load_test = gen_wind_p[1:500]
#plot(load_test,price_test)

for (i in 1:(length(gen_time)-1)){
  if ((gen_time[i+1] - gen_time[i]) != gen_time[2]-gen_time[1]){
    print(i)
    print(gen_time[i])
  }
}

# from no.792 there are nine points missing

###

index_gen = file_gen$fuel_type == "Coal"
gen_coal = file_gen$mw[index_gen]
gen_coal_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Gas"
gen_gas = file_gen$mw[index_gen]
gen_gas_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Hydro"
gen_hydro = file_gen$mw[index_gen]
gen_hydro_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Multiple Fuels"
gen_multi = file_gen$mw[index_gen]
gen_multi_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Nuclear"
gen_nuclear = file_gen$mw[index_gen]
gen_nuclear_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Oil"
gen_oil = file_gen$mw[index_gen]
gen_oil_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Other"
gen_other = file_gen$mw[index_gen]
gen_other_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Other Renewables"
gen_otherRE = file_gen$mw[index_gen]
gen_otherRE_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Solar"
gen_solar = file_gen$mw[index_gen]
gen_solar_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Storage"
gen_storage = file_gen$mw[index_gen]
gen_storage_p = file_gen$fuel_percentage_of_total[index_gen]

index_gen = file_gen$fuel_type == "Wind"
gen_wind = file_gen$mw[index_gen]
gen_wind_p = file_gen$fuel_percentage_of_total[index_gen]

for (v in c("gen_coal", "gen_gas", "gen_hydro", "gen_multi", "gen_nuclear", "gen_oil", "gen_otherRE", "gen_solar", "gen_storage", "gen_solar", "gen_wind")){
  value = get(v)
  value = c(value[1:792],0,0,0,0,0,0,0,0,0,value[793:8775])
  assign(v,value)
}

DataToBeWrite = data.frame(gen_coal, gen_gas, gen_hydro, gen_multi, gen_nuclear, gen_oil, gen_other, gen_otherRE, gen_solar, gen_storage, gen_solar, gen_wind)
write.csv(DataToBeWrite,file = "PJM_2016_GEN.csv")
