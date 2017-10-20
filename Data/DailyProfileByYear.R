setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/")
library(lubridate)

region = "DE"
filename = paste(region,"csv",sep = ".")
df = read.csv(filename)
filename = paste(region,"YearEnd.csv",sep = "_")
YearEnd = read.csv(filename)
Ends = c(1,YearEnd$DatePoint)
l_color = rainbow(10)
for(y in 1:10){
	price_avg = vector('numeric')
	price_range = df$price[Ends[y]:Ends[y+1]]
	time_range = df$datetime[Ends[y]:Ends[y+1]]
	for (h in 0:23) {
		price_avg = c(price_avg,mean(price_range[hour(time_range) == h]))
	}
	if (y == 1){
		plot(price_avg,type="l", col = l_color[y], ylim=range(0:100),xlab = "Hour", ylab = "Price[$/MWh]")
	} else {	
		lines(price_avg,type="l", col = l_color[y])
	}
	
}
legend_text = 2006:2015
class(legend_text) = "character"
legend("topleft",a,fill = l_color)

#Load
region = "DE"
filename = paste(region,"csv",sep = ".")
df = read.csv(filename)
filename = paste(region,"YearEnd.csv",sep = "_")
YearEnd = read.csv(filename)
Ends = c(1,YearEnd$DatePoint)
l_color = rainbow(10)
for(y in 1:10){
	load_avg = vector('numeric')
	load_range = df$load[Ends[y]:Ends[y+1]]
	time_range = df$datetime[Ends[y]:Ends[y+1]]
	for (h in 0:23) {
		load_avg = c(load_avg,mean(load_range[hour(time_range) == h]))
	}
	if (y == 1){
		plot(load_avg,type="l", col = l_color[y], ylim=range(0:10000),xlab = "Hour", ylab = "Load[MW]")
	} else {	
		lines(load_avg,type="l", col = l_color[y])
	}
	
}
legend_text = 2006:2015
class(legend_text) = "character"
legend("topleft",a,fill = l_color)