#This script is to fix the error in NSW data
setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/")
library(lubridate)
Sys.setenv(TZ='Australia/Sydney')

region = "NSW"
filename = paste(region,"csv",sep = ".")
data_file = read.csv(filename)

newdt = seq.POSIXt(as.POSIXct(data_file$datetime[1]), as.POSIXct(data_file$datetime[length(data_file$datetime)]), by = "30 min")

data_nsw_n = data.frame(datetime=newdt,price = data_file$price, load=data_file$load)
          