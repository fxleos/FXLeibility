bp = barplot(forplot,names.arg = forplot_names, ylab = "Relative Cost", col = "grey", main = "Total Electricity Cost with Infinite Flexibility",cex.names = 0.4,cex.axis = 0.5)
text(bp,forplot-0.1,labels = round(forplot,digits = 3), cex = 0.5)
#Original
plot(as.Date(df$datetime),P_o,type = "l",ylim = range(0:15000),col = "black",xlab = "Time [Year]", ylab = "Price [AUD/MWh]")
par(new = TRUE)
plot(L_o,type = "l",ylim = range(0:15000),col = 4, axes=FALSE,bty="n",xlab="",ylab="")
axis(side=4,at = pretty(range(0:15000)))
legend("topright",c("Price","Load"), fill = c(1,4), cex = 0.7)
mtext("Load [MW]",side = 4)

#price
plot(as.Date(df$datetime),P_o,type = "l",ylim = range(-50:100),col = "black",xlab = "Time [Year]", ylab = "Price [AUD/MWh]")
par(new = TRUE)
plot(P_r,type = "l",ylim = range(-50:100),col = 2, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(P_f_d,type = "l",ylim = range(-50:100),col = 3, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(P_f_w,type = "l",ylim = range(-50:100),col = 4, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(P_f_m,type = "l",ylim = range(-50:100),col = 5, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(P_f_y,type = "l",ylim = range(-50:100),col = 6, axes=FALSE,bty="n",xlab="",ylab="")
legend("bottomright",c("Original","Regressed","Flexibile-Day","Flexibile-Week","Flexibile-Month","Flexibile-Year"), fill = 1:6, cex = 0.7)

#load
plot(as.Date(df$datetime),L_o,type = "l",ylim = range(0:20000),col = "black",xlab = "Time [Year]", ylab = "Load [MW]")
par(new = TRUE)
plot(L_f_d,type = "l",ylim = range(0:20000),col = 3, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(L_f_w,type = "l",ylim = range(0:20000),col = 4, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(L_f_m,type = "l",ylim = range(0:20000),col = 5, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(L_f_y,type = "l",ylim = range(0:20000),col = 6, axes=FALSE,bty="n",xlab="",ylab="")
legend("topright",c("Original","Flexibile-Day","Flexibile-Week","Flexibile-Month","Flexibile-Year"), fill = c(1,3:6), cex = 0.5)

#barplot
barplot(forplot,names.arg = forplot_names, ylab = "Relative Cost", col = "grey", main = "Total Electricity Cost with Infinite Flexibility",cex.names = 0.4,cex.axis = 0.5)
sum(P_r*L_o)

# Evolution yearly
cost_o = vector("numeric")
cost_r = vector("numeric")
cost_y = vector("numeric")
cost_m = vector("numeric")
cost_w = vector("numeric")
cost_d = vector("numeric")
for (y in 2: 11){
  cost_o = c(cost_o,sum(P_o[(yEnds[y-1]+1):yEnds[y]]*L_o[(yEnds[y-1]+1):yEnds[y]]))
  cost_r = c(cost_r,sum(P_r[(yEnds[y-1]+1):yEnds[y]]*L_o[(yEnds[y-1]+1):yEnds[y]]))
  cost_d = c(cost_d,sum(P_f_d[(yEnds[y-1]+1):yEnds[y]]*L_f_d[(yEnds[y-1]+1):yEnds[y]]))
  cost_w = c(cost_w,sum(P_f_w[(yEnds[y-1]+1):yEnds[y]]*L_f_w[(yEnds[y-1]+1):yEnds[y]]))
  cost_m = c(cost_m,sum(P_f_m[(yEnds[y-1]+1):yEnds[y]]*L_f_m[(yEnds[y-1]+1):yEnds[y]]))
  cost_y = c(cost_y,sum(P_f_y[(yEnds[y-1]+1):yEnds[y]]*L_f_y[(yEnds[y-1]+1):yEnds[y]]))
}
Years = 2007:2016
plot(Years,1- cost_d/cost_r,type = "l",ylim = c(-0.05,0.5),col = 3,xlab = "Time [Year]", ylab = "Relative reduced cost")
par(new = TRUE)
plot(Years,1- cost_w/cost_r,type = "l",ylim = c(-0.05,0.5),col = 4, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(Years,1- cost_m/cost_r,type = "l",ylim = c(-0.05,0.5),col = 5, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(Years,1- cost_y/cost_r,type = "l",ylim = c(-0.05,0.5),col = 6, axes=FALSE,bty="n",xlab="",ylab="")



# Value of flexibility for the arbitragers
#sum(((Ra*L_f_d)^2/2+Rb*L_f_d) - ((Ra*L_o)^2/2+Rb*L_o))
revenue_y = vector("numeric")
revenue_m = vector("numeric")
revenue_w = vector("numeric")
revenue_d = vector("numeric")
for (y in 2: 11){
  revenue_d = c(revenue_d, -sum((Ra[(yEnds[y-1]+1):yEnds[y]]*(L_f_d[(yEnds[y-1]+1):yEnds[y]])^2/2+Rb[(yEnds[y-1]+1):yEnds[y]]*L_f_d[(yEnds[y-1]+1):yEnds[y]]) - (Ra[(yEnds[y-1]+1):yEnds[y]]*(L_o[(yEnds[y-1]+1):yEnds[y]])^2/2+Rb[(yEnds[y-1]+1):yEnds[y]]*L_o[(yEnds[y-1]+1):yEnds[y]])))
  revenue_w = c(revenue_w, -sum((Ra[(yEnds[y-1]+1):yEnds[y]]*(L_f_w[(yEnds[y-1]+1):yEnds[y]])^2/2+Rb[(yEnds[y-1]+1):yEnds[y]]*L_f_w[(yEnds[y-1]+1):yEnds[y]]) - (Ra[(yEnds[y-1]+1):yEnds[y]]*(L_o[(yEnds[y-1]+1):yEnds[y]])^2/2+Rb[(yEnds[y-1]+1):yEnds[y]]*L_o[(yEnds[y-1]+1):yEnds[y]])))
  revenue_m = c(revenue_m, -sum((Ra[(yEnds[y-1]+1):yEnds[y]]*(L_f_m[(yEnds[y-1]+1):yEnds[y]])^2/2+Rb[(yEnds[y-1]+1):yEnds[y]]*L_f_m[(yEnds[y-1]+1):yEnds[y]]) - (Ra[(yEnds[y-1]+1):yEnds[y]]*(L_o[(yEnds[y-1]+1):yEnds[y]])^2/2+Rb[(yEnds[y-1]+1):yEnds[y]]*L_o[(yEnds[y-1]+1):yEnds[y]])))
  revenue_y = c(revenue_y, -sum((Ra[(yEnds[y-1]+1):yEnds[y]]*(L_f_y[(yEnds[y-1]+1):yEnds[y]])^2/2+Rb[(yEnds[y-1]+1):yEnds[y]]*L_f_y[(yEnds[y-1]+1):yEnds[y]]) - (Ra[(yEnds[y-1]+1):yEnds[y]]*(L_o[(yEnds[y-1]+1):yEnds[y]])^2/2+Rb[(yEnds[y-1]+1):yEnds[y]]*L_o[(yEnds[y-1]+1):yEnds[y]])))
}
barplot(revenue_d,names.arg = 2007:2016, ylab = "Revenue", col = "grey", main = "Total Revenue with Daily Flexibility",cex.names = 0.4,cex.axis = 0.5)
plot(revenue_d,names.arg = 2007:2016, ylab = "Revenue", col = 3, main = "Total Revenue with Daily Flexibility",cex.names = 0.4,cex.axis = 0.5, type = "l")

plot(Years,revenue_d/1000000,type = "l",ylim = c(0,600),col = 3,xlab = "Time [Year]", ylab = "Revenue of Arbitrage [million AUD]")
par(new = TRUE)
plot(Years,revenue_w/1000000,type = "l",ylim = c(0,600),col = 4, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(Years,revenue_m/1000000,type = "l",ylim = c(0,600),col = 5, axes=FALSE,bty="n",xlab="",ylab="")
par(new = TRUE)
plot(Years,revenue_y/1000000,type = "l",ylim = c(0,600),col = 6, axes=FALSE,bty="n",xlab="",ylab="")
legend("topright",c("Flexibile-Day","Flexibile-Week","Flexibile-Month","Flexibile-Year"), fill = c(3:6), cex = 0.5)
