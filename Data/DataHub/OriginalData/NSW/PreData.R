setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/Datahub/OriginalData/NSW")

Sys.setenv(TZ='Australia/Sydney')
year = 2007:2016
month = c ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')
i = 0
for (y in year){
	for (m in month){
		filename = paste("PRICE_AND_DEMAND_", y, m, "_NSW1.csv", sep="", collapse = NULL)
		data_file = read.csv(filename)
		data_dt = data_file$SETTLEMENTDATE
		data_dt = strptime(data_dt,format="%Y/%m/%d %H:%M:%S")
		if (i == 0){
			datetime = data_dt
			price = data_file$RRP
			load = data_file$TOTALDEMAND
		}else{
			datetime = c(datetime,data_dt)
			price = c(price,data_file$RRP)
			load = c(load,data_file$TOTALDEMAND)
		}
		i = i +1

	}
	
}

data_nsw = data.frame(datetime=datetime,price = price, load=load)
