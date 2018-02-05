setwd("/Users/fxleos/Downloads/PJM_data/2016")
file_gen = read.csv("gen_by_fuel.csv")
index_gen = file_gen$fuel_type == "Nuclear"

gen_wind = file_gen$mw[index_gen]
gen_wind_p = file_gen$fuel_percentage_of_total[index_gen]
gen_time = file_gen$datetime_beginning_utc[index_gen]
gen_time = strptime(gen_time,format="%m/%d/%Y %I:%M:%S %p")

plot(metered_load[1:500],gen_wind_p[1:500])
plot(gen_wind_p)
load_test = gen_wind_p[1:500]
plot(load_test,price_test)

for (i in 793:length(gen_time)){
  if (gen_time[i] != da_load_time[i+9]){
    print(i-1)
    print(gen_time[i-1])
    print(da_load_time[i+8])
    print(i)
    print(gen_time[i])
    print(da_load_time[i+9])
    print(i+1)
    print(gen_time[i+1])
    print(da_load_time[i+10])
    break
  }
}
gen_time[793]
da_load_time[802]
