
source('~/Documents/MasterThesis/FXLeibility/FXLeibility/Data/FUN_FlatLoad.R', chdir = TRUE)

region = "PJM"
filename = paste(region,"csv",sep = ".")
Raw = read.csv(filename)

daily = load.flat(Raw$load,Raw$datetime,"day")
weekly = load.flat(Raw$load,Raw$datetime,"week")
monthly = load.flat(Raw$load,Raw$datetime,"month")
yearly = load.flat(Raw$load,Raw$datetime,"year")

newdt = data.frame(datetime = Raw$datetime,daily = daily, weekly = weekly, monthly = monthly, yearly = yearly)

filename = paste(region,"FlatLoad.csv",sep = "_")
write.csv(newdt,filename)