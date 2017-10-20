setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/")
region = "PJM"
filename = paste(region,"csv",sep = ".")
Raw = read.csv(filename)
filename = paste(region,"FlatLoad.csv",sep = "_")
Flat = read.csv(filename)
filename = paste(region,"YearEnd.csv",sep = "_")

plot(as.Date(Raw$datetime),Raw$load,type="l",col = "black",xlab = "Time [year]", ylab = "Load [MW]")
lines(as.Date(Raw$datetime),Flat$daily,type="l",col = "red")
lines(as.Date(Raw$datetime),Flat$weekly,type="l",col = "yellow")
lines(as.Date(Raw$datetime),Flat$monthly,type="l",col = "blue")
lines(as.Date(Raw$datetime),Flat$yearly,type="l",col = "green")
legend("topright",c("Original Load","Daily-flexibility","Weekly-flexibility","Monthly-flexibility", "Yearly-flexibility"),fill=c("black","red","yellow","blue","green"))