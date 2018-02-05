setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/Datahub/OriginalData/DE")

de1 = read.csv("DE1.csv")
de2 = read.csv("DE2.csv")

price = c(de1$price,de2$price)
load = c(de1$load,de2$load)

datetime = seq(as.POSIXct("2006-01-01 00:00:00"),as.POSIXct("2015-12-16 23:00:00"),by = "hour")

de = data.frame(datetime = datetime, price = price, load = load)

write.csv(de,"DE.csv")