library(hydroTSM)

region = "DE"
filename = paste(region,"csv",sep = ".")
df = read.csv(filename)
filename = paste(region,"YearEnd.csv",sep = "_")
YearEnd = read.csv(filename)
Ends = c(1,YearEnd$DatePoint)
l_color = rainbow(10)


for(y in 1:10){
	if(y==1){
		fdc(df$load[Ends[y]:Ends[y+1]],col=l_color[y],ylim=range(0:50000),xlab = "% Time load above", ylab = "Load [MW]", main = NULL,thr.shw=FALSE)
	}
	fdc(df$load[Ends[y]:Ends[y+1]],col=l_color[y],new = FALSE,ylim=range(0:50000),thr.shw=FALSE)
}

legend_text = 2006:2015
class(legend_text) = "character"
legend("topright",legend_text,fill = l_color)