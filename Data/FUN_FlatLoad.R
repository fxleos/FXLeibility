library(lubridate)
load.flat = function (load,time,by){
	time = as.Date(time)
	i_start = 1
	i_end = 1
	weekday = 0
	if (by == "day"){
		thedate = time[1]
		for (i in 1:length(time)){
			if (thedate != time[i]){
				i_end = i - 1
				load[i_start:i_end]=mean(load[i_start:i_end])
				i_start = i
				thedate = time[i]
			}
			if (i == length(time)){
				i_end = i
				load[i_start:i_end]=mean(load[i_start:i_end])
			}
		}	
	}else if (by == "week"){
		thedate = time[1]
		for (i in 1:length(time)){
			if (thedate != time[i]){
				weekday = weekday + 1
				if (weekday == 8 ){
					i_end = i - 1
					load[i_start:i_end]=mean(load[i_start:i_end])
					i_start = i
					weekday = 1
				}
				thedate = time[i]
			}
			if(i == length(time)){
				i_end = i
				load[i_start:i_end]=mean(load[i_start:i_end])
			}
		}
	}else if (by == "month"){
		time = month(time)
		thedate = time[1]
		for (i in 1:length(time)){
			if (thedate != time[i]){
				i_end = i -1
				load[i_start:i_end]=mean(load[i_start:i_end])
				i_start = i
				thedate = time[i]
			}
			if (i == length(time)){
				i_end = i
				load[i_start:i_end]=mean(load[i_start:i_end])
			}
		}
	}else if (by == "year"){
		time = year(time)
		thedate = time [1]
		for (i in 1:length(time)){
			if (thedate !=time[i]){
				i_end = i - 1
				load[i_start:i_end]=mean(load[i_start:i_end])
				i_start = i
				thedate = time[i]
				print(i)
			}
			if (i == length(time)){
				i_end = i
				load[i_start:i_end]=mean(load[i_start:i_end])
			}
		}
	}
	return(load)
}