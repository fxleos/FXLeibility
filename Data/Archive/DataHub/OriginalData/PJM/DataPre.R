setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/Datahub/OriginalData/PJM")

Sys.setenv(TZ='UTC')
data_load = read.csv("load.csv")
load_dt = data_load$datetime_beginning_utc
load_dt = strptime(load_dt,format="%m/%d/%Y %I:%M:%S %p")
data_load$datetime = load_dt
data_load = data_load[order(data_load$datetime),]
load = data_load$hrly_da_demand_bid

data_price = read.csv("price.csv")
price_dt = data_price$datetime_beginning_utc
price_dt = strptime(price_dt,format="%m/%d/%Y %I:%M:%S %p")
data_price$datetime = price_dt
data_price = data_price[order(data_price$datetime),]
price = data_price$total_lmp_da 

load_aligned = vector(mode="numeric",length=length(data_price$datetime))
load_aligned[match(data_load$datetime,data_price$datetime)] = load
data_pjm = data.frame(datetime=data_price$datetime,price = price,load = load_aligned)

