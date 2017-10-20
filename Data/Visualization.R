setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/")

region = "PJM_daily"
filename = paste(region,"csv",sep = ".")
data_file = read.csv(filename)


plot(as.Date(data_file$datetime),data_file$price_avg,type="l",col="blue",xlab="Time[Year]",ylab="Price[$/MWh]",ylim=range(0:200))
lines(as.Date(data_file$datetime),data_file$price_dev,type="l",col="red")
par(new=TRUE)
plot(as.Date(data_file$datetime),data_file$price_par,type="l", col = "yellow",axes=FALSE,bty="n",xlab="",ylab="")
axis(side=4,at = pretty(range(0:4)))
legend("topleft",c("Average Daily Price","Standard Deviation","Peak to Average Ratio"),fill=c("blue","red","yellow"))
mtext("Ratio",side = 4)


#plot load
plot(as.Date(data_file$datetime),data_file$load_avg,type="l",col="blue",xlab="Time[Year]",ylab="Load[MW]")
lines(as.Date(data_file$datetime),data_file$load_dev,type="l",col="red")
par(new=TRUE)
plot(as.Date(data_file$datetime),data_file$load_par,type="l", col = "yellow",axes=FALSE,bty="n",xlab="",ylab="")
axis(side=4,at = pretty(range(0:5)))
legend("topleft",c("Average Daily Load","Standard Deviation","Peak to Average Ratio"),fill=c("blue","red","yellow"))
mtext("Ratio",side = 4)









plot(as.Date(data_file$datetime),data_file$price,type="l",col="black",xlab="Time[Year]",ylab="Price[$/MWh]")
par(new=TRUE)
plot(as.Date(data_file$datetime),data_file$load,type="l", col = "blue",axes=FALSE,bty="n",xlab="",ylab="")
axis(side=4,at = pretty(range(data_file$load)))
mtext("Load[MW]",side = 4)
legend("topleft",c("Price","Load"),fill=c("black","blue"))



#DE
region = "DE_daily"
filename = paste(region,"csv",sep = ".")
data_file = read.csv(filename)
plot(as.Date(data_file$datetime),data_file$price_avg,type="l",col="blue",xlab="Time[Year]",ylab="Price[€/MWh]",ylim=range(-50:250))
lines(as.Date(data_file$datetime),data_file$price_dev,type="l",col="red")
par(new=TRUE)
plot(as.Date(data_file$datetime),data_file$price_par,type="l", col = "yellow",axes=FALSE,bty="n",xlab="",ylab="")
axis(side=4,at = pretty(range(data_file$price_par)))
legend("bottomleft",c("Average Daily Price","Standard Deviation","Peak to Average Ratio"),fill=c("blue","red","yellow"))
mtext("Ratio",side = 4)