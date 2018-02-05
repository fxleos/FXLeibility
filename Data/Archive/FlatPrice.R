setwd("/Users/fxleos/Documents/MasterThesis/FXLeibility/FXLeibility/Data/")
library(lubridate)

region = "NSW"
filename = paste(region,"csv",sep = ".")
df = read.csv(filename)
filename = paste(region,"YearEnd.csv",sep = "_")
YearEnd = read.csv(filename)
yEnds = c(0,YearEnd$DatePoint)
filename = paste(region,"MonthEnd.csv",sep = "_")
MonthEnd = read.csv(filename)
mEnds = c(0,MonthEnd$MonthEnd)

P_o = df$price
L_o = df$load
Ra = vector("numeric")
Rb = vector("numeric")

# by(df[,1:2],df[,"datetime", function(x) coef(lm(~), data = x)])
for(m in 2:length(mEnds)){
  t = df$datetime[(mEnds[m-1]+1):mEnds[m]]
  P_o_m = P_o[(mEnds[m-1]+1):mEnds[m]]
  L_o_m = L_o[(mEnds[m-1]+1):mEnds[m]]
  Ra_m = numeric(length(t))
  Rb_m = Ra_m
  for (h in 0:23){
    index = hour(t) ==  h
    if(cor(P_o_m[index],L_o_m[index])>0.5){
      # if the correlation for that hour is strong enough
      R = lm(P_o_m[index]~L_o_m[index])
      Ra_m[index] = coef(R)[[2]]
      Rb_m[index] = coef(R)[[1]]
    }else {
      # otherwise, try to incorporate the previous and next hour
      index = hour(t) ==  h | hour(t) ==  ((h+23)%%24) | hour(t) ==  ((h+25)%%24)
      if(cor(P_o_m[index],L_o_m[index])>0.5){
        R = lm(P_o_m[index]~L_o_m[index])
        index = hour(t) ==  h
        Ra_m[index] = coef(R)[[2]]
        Rb_m[index] = coef(R)[[1]]
      } else{
        # if it still doesn't work, then just use the regression from previous hour
        index = hour(t) ==  h
        Ra_m[index] = coef(R)[[2]]
        Rb_m[index] = coef(R)[[1]]
      }
    }
    
  }
  Ra = c(Ra,Ra_m)
  Rb = c(Rb,Rb_m)

}

# Get regressed price
P_r = numeric(length(P_o))
for (i in 1:length(L_o)){
  P_r[i] = L_o[i] * Ra[i] + Rb[i]
}

# Get price and load with infinite flexibility
P_f_y = numeric(length(P_o))
L_f_y = P_f_y
P_f_m = P_f_y
L_f_m = P_f_y
P_f_w = P_f_y
L_f_w = P_f_y
P_f_d = P_f_y
L_f_d = P_f_y

time = as.Date(df$datetime)

# Duration - Day
i_start = 1
i_end = 1
thedate = time[1]
for (i in 1:length(time)){
  if (thedate != time[i]){
    i_end = i - 1
    P_f_d[i_start:i_end] = (sum(L_o[i_start:i_end])+sum(Rb[i_start:i_end]/Ra[i_start:i_end]))/(sum(1/Ra[i_start:i_end]))
    i_start = i
    thedate = time[i]
  }
  if (i == length(time)){
    i_end = i
    P_f_d[i_start:i_end] = (sum(L_o[i_start:i_end])+sum(Rb[i_start:i_end]/Ra[i_start:i_end]))/(sum(1/Ra[i_start:i_end]))
  }
  
}
L_f_d = (P_f_d - Rb)/Ra
# Duration - Week
i_start = 1
i_end = 1
weekday = 1
thedate = time[1]
for (i in 1:length(time)){
  if (thedate != time[i]){
    weekday = weekday + 1
    if (weekday == 8){
      i_end = i - 1
      P_f_w[i_start:i_end] = (sum(L_o[i_start:i_end])+sum(Rb[i_start:i_end]/Ra[i_start:i_end]))/(sum(1/Ra[i_start:i_end]))
      i_start = i
      weekday = 1
    }
    thedate = time[i]
  }
  if (i == length(time)){
    i_end = i
    P_f_w[i_start:i_end] = (sum(L_o[i_start:i_end])+sum(Rb[i_start:i_end]/Ra[i_start:i_end]))/(sum(1/Ra[i_start:i_end]))
  }
}
L_f_w = (P_f_w - Rb)/Ra
# Duration - Month
for(m in 2:length(mEnds)){
  P_f_m[(mEnds[m-1]+1):mEnds[m]] = (sum(L_o[(mEnds[m-1]+1):mEnds[m]])+sum(Rb[(mEnds[m-1]+1):mEnds[m]]/Ra[(mEnds[m-1]+1):mEnds[m]]))/(sum(1/Ra[(mEnds[m-1]+1):mEnds[m]]))
}
L_f_m = (P_f_m - Rb)/Ra
# Duration - Year
for(y in 2:length(yEnds)){
  P_f_y[(yEnds[y-1]+1):yEnds[y]] = (sum(L_o[(yEnds[y-1]+1):yEnds[y]])+sum(Rb[(yEnds[y-1]+1):yEnds[y]]/Ra[(yEnds[y-1]+1):yEnds[y]]))/(sum(1/Ra[(yEnds[y-1]+1):yEnds[y]]))
}
L_f_y = (P_f_y - Rb)/Ra

# Define the flexibility characters
t_interval = 1
if(region == "NSW"){
  t_interval = 0.5
}

rate_d =L_f_d - L_0
rate_w = L_f_w - L_0
rate_m = L_f_m - L_0
rate_y = L_f_y - L_0
c_d = numeric(length(rate_d))
c_w = c_d
c_m = c_d
c_y = c_d
c_d[1] = rate_d[1]*t_interval
c_w[1] = rate_w[1]*t_interval
c_m[1] = rate_m[1]*t_interval
c_y[1] = rate_y[1]*t_interval
for ( i in 2:length(time)){
  c_d[i] = c_d[i-1] + rate_d[i]*t_interval
  c_w[i] = c_w[i-1] + rate_w[i]*t_interval
  c_m[i] = c_m[i-1] + rate_m[i]*t_interval
  c_y[i] = c_y[i-1] + rate_y[i]*t_interval
}
df.new = data.frame(datetime = df$datetime, P_o = P_o, L_o = L_o, P_r = P_r, Ra, Rb, P_f_d = P_f_d, P_f_w = P_f_w, P_f_m=P_f_m, P_f_y= P_f_y, L_f_d = L_f_d, L_f_w = L_f_w, L_f_m=L_f_m, L_f_y= L_f_y, rate_d, rate_w, rate_m, rate_y, c_d, c_w, c_m, c_y)

filename = paste(region,"FlatPrice.csv",sep = "_")
write.csv(df.new,filename)
