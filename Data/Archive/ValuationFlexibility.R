setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/")

region = "NSW"
filename = paste(region,"csv",sep = ".")
Raw = read.csv(filename)
filename = paste(region,"FlatLoad.csv",sep = "_")
Flat = read.csv(filename)
filename = paste(region,"YearEnd.csv",sep = "_")
YearEnd = read.csv(filename)
filename = paste(region,"YearEnd.csv",sep = "_")
YearEnd = read.csv(filename)
filename = paste(region,"MonthEnd.csv",sep = "_")
MonthEnd = read.csv(filename)

Ends = YearEnd$DatePoint
#Ends = MonthEnd$MonthEnd
RawCost = Raw$price * Raw$load
FlatCostDay = Raw$price * Flat$daily
FlatCostWeek = Raw$price * Flat$weekly
FlatCostMonth = Raw$price * Flat$monthly
FlatCostYear = Raw$price * Flat$yearly

RawCostBY = c(sum(RawCost[1:Ends[1]-1]))
FlatCostDayBY = c(sum(FlatCostDay[1:Ends[1]-1]))
FlatCostWeekBY = c(sum(FlatCostWeek[1:Ends[1]-1]))
FlatCostMonthBY = c(sum(FlatCostMonth[1:Ends[1]-1]))
FlatCostYearBY = c(sum(FlatCostYear[1:Ends[1]-1]))
for (i in 2:length(Ends)){
	RawCostBY = c(RawCostBY,sum(RawCost[Ends[i-1]:Ends[i]-1]))
	FlatCostDayBY = c(FlatCostDayBY,sum(FlatCostDay[Ends[i-1]:Ends[i]-1]))
	FlatCostWeekBY = c(FlatCostWeekBY,sum(FlatCostWeek[Ends[i-1]:Ends[i]-1]))
	FlatCostMonthBY = c(FlatCostMonthBY,sum(FlatCostMonth[Ends[i-1]:Ends[i]-1]))
	FlatCostYearBY = c(FlatCostYearBY,sum(FlatCostYear[Ends[i-1]:Ends[i]-1]))
}


if (region == "NSW"){
	Years = 2007:2016
	Time = Years
	value = (RawCostBY - FlatCostYearBY)/2000000
	plot(Time, value, type = "l", col = "green",xlab = "Time [Year]", ylab ="Saving [mAUD]",ylim=range(0:700))
	value = (RawCostBY - FlatCostDayBY)/2000000
	lines(Time, value, type = "l", col = "red")
	value = (RawCostBY - FlatCostWeekBY)/2000000
	lines(Time, value, type = "l", col = "yellow")
	value = (RawCostBY - FlatCostMonthBY)/2000000
	lines(Time, value, type = "l", col = "blue")
	Months = seq.Date(as.Date("2007-01-01"), as.Date("2017-12-31"), by = "month")
}else if (region == "PJM"){
	Years = 2007:2016
	Time = Years
	value = (RawCostBY - FlatCostYearBY)/2000000
	plot(Time, value, type = "l", col = "green",xlab = "Time [Year]", ylab ="Saving [mUSD]",ylim=range(0:1800))
	value = (RawCostBY - FlatCostDayBY)/2000000
	lines(Time, value, type = "l", col = "red")
	value = (RawCostBY - FlatCostWeekBY)/2000000
	lines(Time, value, type = "l", col = "yellow")
	value = (RawCostBY - FlatCostMonthBY)/2000000
	lines(Time, value, type = "l", col = "blue")
	Months = seq.Date(as.Date("2007-01-01"), as.Date("2017-01-01"), by = "month")
	
}

legend("topright",c("Daily-flexibility","Weekly-flexibility","Monthly-flexibility", "Yearly-flexibility"),fill=c("red","yellow","blue","green"))
