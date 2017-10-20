setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/")
library(lubridate)

region = "PJM"
filename = paste(region,"csv",sep = ".")
data_file = read.csv(filename)

datetime = integer(0)
class(datetime)="Date"
price_avg = vector('numeric')
price_dev = vector('numeric')
price_par = vector('numeric')
load_avg = vector('numeric')
load_dev = vector('numeric')
load_par = vector('numeric')


i_range = 1: length(data_file$datetime)
i_start = 1
i_end = 1
thedate = date(data_file$datetime[i_start])

for (i in i_range){
	if (thedate != date(data_file$datetime[i])){
		i_end = i -1
		datetime = c(datetime,thedate)
		price_avg = c(price_avg,mean(data_file$price[i_start:i_end]))
		price_dev = c(price_dev,sd(data_file$price[i_start:i_end]))
		price_par = c(price_par,max(data_file$price[i_start:i_end])/mean(data_file$price[i_start:i_end]))
		load_avg = c(load_avg,mean(data_file$load[i_start:i_end]))
		load_dev = c(load_dev,sd(data_file$load[i_start:i_end]))
		load_par = c(load_par,max(data_file$load[i_start:i_end])/mean(data_file$load[i_start:i_end]))
		thedate = date(data_file$datetime[i])
		i_start = i
	}
	
}
PJM_daily = data.frame(datetime=datetime,price_avg = price_avg, price_dev = price_dev, price_par = price_par, load_avg = load_avg, load_dev = load_dev, load_par = load_par)




