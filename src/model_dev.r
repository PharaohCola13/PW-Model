#### Precipitable Water Model
## Spencer Riley / Vicki Kelsey
## To get a list of arguments run Rscript model.r --help
####
## Necessary Libraries for the script to run, for installation run install.sh
library(argparse); library(plotrix); library(crayon)

## Custom Colors for cmd line features
red 		<- make_style("red1")
orange 		<- make_style("orange")
yellow 		<- make_style("gold2")
green 		<- make_style("lawngreen")
cloudblue 	<- make_style("lightskyblue")

## Used for argument parsing run Rscript model.r --help
parser <- ArgumentParser()
parser$add_argument("--save", action="store_true", default=FALSE,
	help="Saves plots")
parser$add_argument("--set", type="character", default=FALSE,
	help="Select plot sets: [m]ain/[p]lots_galore/[o]ther")
parser$add_argument("--poster", action="store_true", default=FALSE,
	help="Produces poster plots")
parser$add_argument("--dev", action="store_true", default=FALSE,
	help="Development plots")
parser$add_argument("-d", "--data", action="store_true", default=FALSE,
	help="Produces two columned datset including mean temp and PW")
parser$add_argument("-o", "--overcast", action="store_true", default=FALSE,
	help="Shows time series data for days with overcast condition. (Used with --set m or --set p)")
parser$add_argument("-w", "--warning", action="store_true", default=FALSE,
	help="Shows warnings associated with the script")
parser$add_argument("-i", "--instrument", action="store_true", default=FALSE,
	help="Prints out sensor data stored in instruments.txt")
parser$add_argument("-ml", action="store_true", default=FALSE,
	help="Builds dataset for machine learning things")
args <- parser$parse_args()

## Command Prompt "Start of Program" with Warning box and stuff
if(args$warning){
	cat(bold(red("-----------------------------------------------------------------\n")))
	cat(bold(red("| \t\t\t!!!! Warning !!!!\t\t\t|\n")))
	cat(bold(red("| "), orange("!!! Do not resize the plotting windows, they will break !!!"), red(" |\n")))
	cat(bold(red("| "), orange("!!! To close the window, follow the cmd line directions !!!"), red(" |\n")))
	cat(bold(red("| "), orange("!!! If the window is blank, please re-run the script.   !!!"), red(" |\n")))
	cat(bold(red("| "), yellow("!!! For more information, please read the documentation !!!", red("\t|\n"))))
	cat(bold(red("-----------------------------------------------------------------\n")))
	quit()
}else{
	cat(bold(cloudblue("-----------------------------------------------------------------\n")))
	cat(bold(cloudblue("|\t\t   Precipitable Water Model   \t\t\t|\n")))
	cat(bold(cloudblue("-----------------------------------------------------------------\n")))
	cat(bold(cyan("\t\t>>>>>>>>> Program Start <<<<<<<<\n\n")))
}
## Command Prompt "End of Program"
quit_it <- function(){
	cat(bold(cyan("\n\t\t>>>>>>> Program Complete <<<<<<<\n"))); quit()
}

## Imports data from master_data.csv and imports sensor information from instruments.txt
fname       <- read.csv(file="../data/master_data.csv", sep=",")
sensor 		<- suppressWarnings(read.csv(file="../data/instruments.txt", sep=","))
recent 		<- t(fname[1])[length(t(fname[1]))]

#col_sky 	<- str_detect(fname[0,], "Date")
#print(col_sky)
#print(fname[0,])

## Pulls sensor labels and colors from instruments.txt
sensor_name 	<- list(); sensor_color 	<- unlist(list())
for(i in 1:length(sensor[, 1])){
	var 			<- assign(paste("Thermo", i, sep=""), sensor[i, 1])
	sensor_name 	<- append(sensor_name, toString(var))
	sensor_color 	<- append(sensor_color, toString(sensor[i, 3]))
}

## Filters out data with overcast condition
overcast_filter <- function(){
# Initializes the lists to store values
	date_clear	<- pw_l1t1 	    <- pw_l1t2 	    <- pw_l2t1 	    <- list()
	pw_l2t2	    <- list()

	date_over	<- pw_l1t1o 	<- pw_l1t2o     <- pw_l2t1o 	<- list()
	pw_l2t2o	<- list()

	snsr_gro	<- snsr_sky	<- 	snsr_groo	<- snsr_skyo 	<- list()
	# Divides the data based on condition (Overcast/Clear Skies)
	for (j in 1:length(t(fname[2]))){
		if (!"overcast" %in% fname[j,2]){
			date_clear  <- append(date_clear, as.Date(fname[j, 1], "%m/%d/%Y"))
			pw_l1t1 	<- append(pw_l1t1, fname[j, 4])
			pw_l1t2 	<- append(pw_l1t2, fname[j, 5])
			pw_l2t1 	<- append(pw_l2t1, fname[j, 6])
			pw_l2t2 	<- append(pw_l2t2, fname[j, 7])
			for (k in 1:length(sensor_name)){
				snsr_gro[[ paste("snsr_gro",k,sep="") ]] 	<- append(x=snsr_gro[[ paste("snsr_gro",k,sep="") ]], values=fname[j, k+14])
				snsr_sky[[ paste("snsr_sky",k,sep="") ]] 	<- append(x=snsr_sky[[ paste("snsr_sky",k,sep="") ]], values=fname[j, k+10])
			}
		}else{
			date_over   <- append(date_over, as.Date(fname[j, 1], "%m/%d/%Y"))
			pw_l1t1o 	<- append(pw_l1t1o, fname[j, 4])
			pw_l1t2o 	<- append(pw_l1t2o, fname[j, 5])
			pw_l2t1o 	<- append(pw_l2t1o, fname[j, 6])
			pw_l2t2o 	<- append(pw_l2t2o, fname[j, 7])
			for (k in 1:length(sensor_name)){
				snsr_groo[[ paste("snsr_groo",k,sep="") ]] 	<- append(x=snsr_groo[[ paste("snsr_groo",k,sep="") ]], values=fname[j, k+14])
				snsr_skyo[[ paste("snsr_skyo",k,sep="") ]] 	<- append(x=snsr_skyo[[ paste("snsr_skyo",k,sep="") ]], values=fname[j, k+10])
			}
		}
	}
	output <- list(clear_date=date_clear, "pw_l1t1"=pw_l1t1, "pw_l1t2"=pw_l1t2, "pw_l2t1"=pw_l2t1, "pw_l2t2"=pw_l2t2,
                    "date_over"=date_over, "pw_l1t1o"=pw_l1t1o, "pw_l1t2o"=pw_l1t2o, "pw_l2t1o"=pw_l2t1o, "pw_l2t2o"=pw_l2t2o)
	output1 <- list()
	for(k in 1:length(sensor_name)){
		output1 <- append(x=output1, values=list("snsr_gro"=snsr_gro[[ paste("snsr_gro",k,sep="") ]]))
	}
    for(k in 1:length(sensor_name)){
		output1 <- append(x=output1, values=list("snsr_sky"=snsr_sky[[ paste("snsr_sky",k,sep="") ]]))
	}
	for(k in 1:length(sensor_name)){
        output1 <- append(x=output1, values=list("snsr_skyo"=snsr_skyo[[ paste("snsr_skyo",k,sep="") ]]))
	}
	for(k in 1:length(sensor_name)){
        output1 <- append(x=output1, values=list("snsr_groo"=snsr_groo[[ paste("snsr_groo",k,sep="") ]]))

    }
	output2 <- c(output, output1)
	return(output2)
}
## Pushes returned values to the variable overcast
overcast 	<- overcast_filter()
## Pulls returned values into variables (filtered)
clear_date  <- overcast$clear_date    						# Date

pw_l1t1    	<- as.numeric(array(t(overcast$pw_l1t1)))       # PW for ABQ @ 12Z
pw_l1t2		<- as.numeric(array(t(overcast$pw_l1t2)))       # PW for ABQ @ 00Z
pw_l2t1    	<- as.numeric(array(t(overcast$pw_l2t1)))    	# PW for EPZ @ 12Z
pw_l2t2    	<- as.numeric(array(t(overcast$pw_l2t2)))    	# PW for EPZ @ 00Z
snsr_del 	<- snsr_sky <- snsr_gro <- list()
for (k in 1:length(sensor_name)){
	snsr_sky[[ paste("snsr_sky",k,sep="") ]] <- as.numeric(unlist(overcast[13+k]))
	snsr_gro[[ paste("snsr_gro",k,sep="") ]] <- as.numeric(unlist(overcast[10+k]))
	snsr_del[[ paste("snsr_del",k,sep="") ]] <- as.numeric(unlist(overcast[10+k])) - as.numeric(unlist(overcast[13+k]))
}
l1_avg 	<- (as.numeric(pw_l1t1) + as.numeric(pw_l1t2))/2 # ABQ average
l2_avg 	<- (as.numeric(pw_l2t1) + as.numeric(pw_l2t2))/2 # EPZ average
avg 	<- (l1_avg + l2_avg)/2 								# Super Average
## Pulls returned values into variables (overcast)
over_date  <- overcast$over_date    							# Date

pw_l1t1o     <- as.numeric(array(t(overcast$pw_l1t1o)))        # PW for ABQ @ 12Z
pw_l1t2o	 <- as.numeric(array(t(overcast$pw_l1t2o)))           # PW for ABQ @ 00Z
pw_l2t1o     <- as.numeric(array(t(overcast$pw_l2t1o)))    	# PW for EPZ @ 12Z
pw_l2t2o     <- as.numeric(array(t(overcast$pw_l2t2o)))    	# PW for EPZ @ 00Z
snsr_delo 	<- snsr_skyo <- snsr_groo <- list()
for (k in 1:length(sensor_name)){
	snsr_skyo[[ paste("snsr_skyo",k,sep="") ]] <- as.numeric(unlist(overcast[16+k]))
	snsr_groo[[ paste("snsr_groo",k,sep="") ]] <- as.numeric(unlist(overcast[19+k]))
	snsr_delo[[ paste("snsr_delo",k,sep="") ]] <- as.numeric(unlist(overcast[19+k])) - as.numeric(unlist(overcast[16+k]))
}

l1_avgo 	<- (as.numeric(pw_l1t1o) + as.numeric(pw_l1t2o))/2 # ABQ average
l2_avgo 	<- (as.numeric(pw_l2t1o) + as.numeric(pw_l2t2o))/2 # EPZ average
avgo 		<- (l1_avg + l2_avg)/2 								# Super Average

## A function that will produce popups through the X11 framework
show 			<- function(..., overcast){
# Pulls the input arguments
	args <- list(...)
# Creates a new plotting window for each variable in args
	for (i in args){
		X11(type="cairo", width=6, height=6, pointsize=12)
		i("show", overcast)
	}
	continue_input()
}
## A general function that will save plots (works with the show function above)
save 			<- function(func, name){
	pdf(name);func;invisible(dev.off())
}
## Creates legend for the PW that is used for the pdf plots
legend_plot		<- function(filter, show){
	if(!show){
		legend("topright", inset=c(-0.21, 0),
				legend=c(sensor_name),
				col=c(sensor_color),
				pch=c(16,16, 16))
	}else{
		legend("topright", inset=c(-0.265, 0),
				legend=c(sensor_name),
				col=c(sensor_color),
				pch=c(16,16, 16))
	}
}
## Allows the plots to stay open
continue_input 	<- function(){
	cat(bold(yellow("Slam Enter to Continue:\n>> "))); x <- readLines(con="stdin", 1)
}
## Function includes all of the stuff to generate the exponential regression mode with intervals
exp_regression 	<- function(x,y){
# creates a uniform sequence of numbers that fit within the limits of x
	xmin 	<- min(x, na.rm=TRUE)
	xmax 	<- max(x, na.rm=TRUE)
	newx 	<- seq(xmin, xmax, length.out=length(x))
# Non-linear model (exponential)
	model.0 <- lm(log(y, base=exp(1))~x, data=data.frame(x,log(y, base=exp(1))))
	start 	<- list(a=coef(model.0)[1], b=coef(model.0)[2])
	model 	<- nls(y~a+b*x, data=data.frame(x=x, y=log(y, base=exp(1))), start=start)
# Intervals
	confint <- predict(model.0, newdata=data.frame(x=newx), interval='confidence')
	predint <- predict(model.0, newdata=data.frame(x=newx), interval='prediction')
# Function outputs
	output 	<- list("x"=x, "y"=y, "newx"=newx, "model.0"=model.0, "xmin"=xmin, "xmax"=xmax,
					"model"=model, "confint"=confint, "predint"=predint)
	return (output)
}

### Plot functions
## Air Temperature plot
main1 	<- function(legend, overcast=args$overcast){
	xmin <- min(clear_date, na.rm=TRUE)
	xmax <- max(clear_date, na.rm=TRUE)
	par(mar=c(5.1, 5.1, 5.1, 5.3), xpd=TRUE)
	if(overcast){
		ymax 		<- max(as.numeric(unlist(snsr_skyo)), na.rm=TRUE)
		ymin 		<- min(as.numeric(unlist(snsr_skyo)), na.rm=TRUE)
		range_index <- snsr_skyo
		title 		<- "Air Temperature Time Series\nCondition: Overcast"
		date 		<- over_date
	}else{
		ymax 		<- max(as.numeric(unlist(snsr_sky)),na.rm=TRUE)
		ymin 		<- min(as.numeric(unlist(snsr_sky)),na.rm=TRUE)
		range_index <- snsr_sky
		title 		<- "Air Temperature Time Series\nCondition: Clear Sky"
		date 		<- clear_date
	}
	plot(date, t(unlist(range_index[1])), xlab="Date", ylab="Temperature [C]",
			main=title, pch=16, xlim=c(xmin, xmax), ylim=c(ymin, ymax), col=c(toString(sensor[1,3])))

	for(j in 2:length(range_index)){
		points(date, t(unlist(snsr_sky[j])), pch=16, col=c(toString(sensor[j, 3])))
	}
	if (legend == "save"){
		legend_plot(overcast, FALSE)
	}else if(legend == "show"){
		legend_plot(overcast, TRUE)
	}
}
## Ground Temperature plot
main2 	<- function(legend, overcast=args$overcast){
# Margin Configuration
	par(mar=c(5.1, 5.1, 5.1, 5.3), xpd=TRUE)
	xmin 	<- min(clear_date, na.rm=TRUE)
	xmax 	<- max(clear_date, na.rm=TRUE)
	if(overcast){
		ymax  		<- max(as.numeric(unlist(snsr_groo)),na.rm=TRUE)
		ymin  		<- min(as.numeric(unlist(snsr_groo)),na.rm=TRUE)
		range_index <- snsr_groo
		title 		<- "Ground Temperature Time Series\nCondition: Overcast"
		date 		<- over_date
	}else{
		ymax  		<- max(as.numeric(unlist(snsr_gro)),na.rm=TRUE)
		ymin  		<- min(as.numeric(unlist(snsr_gro)),na.rm=TRUE)
		range_index <- snsr_gro
		title 		<- "Ground Temperature Time Series\nCondition: Clear Sky"
		date 		<- clear_date
	}
	plot(date, t(unlist(range_index[1])), xlab="Date", ylab="Temperature [C]",
		 main=title, pch=16,
		xlim=c(xmin, xmax), ylim=c(ymin, ymax), col=c(toString(sensor[1,3])))

	for(j in 2:length(range_index)){
		points(date, t(unlist(range_index[j])), pch=16, col=c(toString(sensor[j, 3])))
	}
	# Legend configuration
	if (legend == "save"){
		legend_plot(overcast, FALSE)
	}else if(legend == "show"){
		legend_plot(overcast, TRUE)
	}
}
## Delta T plot
main3 	<- function(legend, overcast=args$overcast){
# Margin Configuration
	par(mar=c(5.1, 5.1, 5.1, 5.3), xpd=TRUE)
# Limits of the x-direction
	xmin <- min(clear_date, na.rm=TRUE)
	xmax <- max(clear_date, na.rm=TRUE)
	if(overcast){
		ymax 		<- max(as.numeric(unlist(snsr_delo)), na.rm=TRUE)
		ymin 		<- min(as.numeric(unlist(snsr_delo)), na.rm=TRUE)
		range_index <- snsr_delo
		title 		<- "Change in Temperature between Air and Ground Time Series\nCondition: Overcast"
		date 		<- over_date
	}else{
		ymax 		<- max(as.numeric(unlist(snsr_del)), na.rm=TRUE)
		ymin 		<- min(as.numeric(unlist(snsr_del)), na.rm=TRUE)
		range_index <- snsr_del
		title 		<- "Change in Temperature between Air and Ground Time Series\nCondition: Clear Sky"
		date 		<- clear_date
	}
	plot(date,  t(unlist(range_index[1])), xlab="Date", ylab="Temperature [C]",
		 xlim=c(xmin, xmax), ylim=c(ymin, ymax),col=c(toString(sensor[1, 3])), main=title, pch=16)
	for(j in 2:length(range_index)){
		points(date, t(unlist(range_index[j])), pch=16, col=c(toString(sensor[j, 3])))
	}
	if (legend == "save"){
		legend_plot(overcast, FALSE)
	}else if(legend == "show"){
		legend_plot(overcast, TRUE)
	}
}

## Individual Location plots
plots1 	<- function(..., overcast=args$overcast){
	if(!overcast){
		xmax 	<- max(as.numeric(unlist(snsr_sky)), na.rm=TRUE)
		xmin 	<- min(as.numeric(unlist(snsr_sky)), na.rm=TRUE)
		ymax	<- max(pw_l1t1, pw_l1t2,pw_l2t1, pw_l2t2, na.rm=TRUE)
		ymin	<- min(pw_l1t1, pw_l1t2,pw_l2t1, pw_l2t2, na.rm=TRUE)
		x 		<- Reduce("+", snsr_sky)/length(snsr_sky)
		y 		<- pw_l1t1; y1 <- pw_l1t2; y2 <- pw_l2t1; y3 <- pw_l2t2
		title	<- "Correlation between PW and Temperature\nCondition: Clear Sky"
	}else{
		xmax 	<- max(as.numeric(unlist(snsr_skyo)), na.rm=TRUE)
		xmin 	<- min(as.numeric(unlist(snsr_skyo)), na.rm=TRUE)
		ymax	<- max(pw_l1t1o, pw_l1t2o, pw_l2t1o, pw_l2t2o, na.rm=TRUE)
		ymin	<- min(pw_l1t1o, pw_l1t2o, pw_l2t1o, pw_l2t2o, na.rm=TRUE)
		x 		<- Reduce("+", snsr_skyo)/length(snsr_skyo)
		y 		<- pw_l1t1o; y1 <- pw_l1t2o; y2 <- pw_l2t1o; y3 <- pw_l2t2o
		title 	<- "Correlation between PW and Temperature\nCondition: Overcast"
	}
	print(t(x))
	plot(x, y, col=c("red"), pch=16, xlim=c(xmin, xmax), ylim=c(ymin, ymax),
			xlab="Zenith Sky Temperature [C]", ylab="PW [mm]", main=title)
	points(x, y1, col=c("blue"), pch=16)
	points(x, y2, col=c("green"), pch=16)
	points(x, y3, col=c("violet"), pch=16)

	legend("topleft", legend=c("ABQ 12Z", "ABQ 00Z", "EPZ 12Z", "EPZ 00Z"),
			col=c("red", "blue", "green", "violet"), pch=c(16,16))
}
## Locational Average Plots
plots2 	<- function(..., overcast=args$overcast){
	if(!overcast){
		xmax 	<- max(as.numeric(unlist(snsr_sky)), na.rm=TRUE)
		xmin 	<- min(as.numeric(unlist(snsr_sky)), na.rm=TRUE)
		ymax	<- max(l1_avg, l2_avg, na.rm=TRUE)
		ymin	<- min(l1_avg, l2_avg, na.rm=TRUE)
		x 		<- Reduce("+", snsr_sky)/length(snsr_sky)
		y 		<- l1_avg; y1 <- l2_avg
		title 	<- "Correlation between Locational Mean PW and Temperature\nCondition: Clear Sky"
	}else{
		xmax 	<- max(as.numeric(unlist(snsr_skyo)), na.rm=TRUE)
		xmin 	<- min(as.numeric(unlist(snsr_skyo)), na.rm=TRUE)
		ymax	<- max(l1_avgo, l2_avgo, na.rm=TRUE)
		ymin	<- min(l1_avgo, l2_avgo, na.rm=TRUE)
		x 		<- Reduce("+", snsr_skyo)/length(snsr_skyo)
		y 		<- l1_avgo; y1 <- l2_avgo
		title 	<- "Correlation between Locational Mean PW and Temperature\nCondition: Overcast"
	}
	plot(x,y, col=c("gold2"), pch=16, xlim = c(xmin, xmax), ylim=c(ymin, ymax),
			xlab = "Zenith Sky Temperature [C]", ylab="PW [mm]", main = title)
	points(x,y1, col=c("dodgerblue"), pch=16)

	legend("topleft", legend=c("ABQ", "EPZ"), col=c("gold2", "dodgerblue"), pch=c(16))
}
## Super Average Plot with Exponential Fit
plots3 	<- function(..., overcast=args$overcast){
	if(!overcast){
		exp_reg <- exp_regression(Reduce("+", snsr_sky)/length(snsr_sky), avg)
		ymax 	<- max(exp_reg$y, na.rm=TRUE)
		ymin 	<- min(exp_reg$y, na.rm=TRUE)
		title 	<- "Correlation between Mean PW and Temperature\nCondition: Clear Sky"
	}else{
		exp_reg <- exp_regression(Reduce("+", snsr_sky)/length(snsr_sky), avgo)
		ymax 	<- max(exp_reg$y, na.rm=TRUE)
		ymin 	<- min(exp_reg$y, na.rm=TRUE)
		title 	<- "Correlation between Mean PW and Temperature\nCondition: Overcast"
	}
# Non-linear model (exponential)
		plot(exp_reg$x,exp_reg$y, col=c("blueviolet"), pch=16,
			xlim=c(exp_reg$xmin, exp_reg$xmax), ylim=c(ymin, ymax),
			xlab="Zenith Sky Temperature [C]", ylab="PW [mm]", main=title)
# Best Fit
	curve(exp(coef(exp_reg$model)[1] + coef(exp_reg$model)[2]*x), col="Red", add=TRUE)
# Confidence Interval
	lines(exp_reg$newx, exp(exp_reg$confint[ ,3]), col="blue", lty="dashed")
	lines(exp_reg$newx, exp(exp_reg$confint[ ,2]), col="blue", lty="dashed")
# Prediction Interval
	lines(exp_reg$newx, exp(exp_reg$predint[ ,3]), col="magenta", lty="dashed")
	lines(exp_reg$newx, exp(exp_reg$predint[ ,2]), col="magenta", lty="dashed")

	legend("topleft",col=c("Red", "Magenta", "Blue"), pch=c("-", '--', "--"),
			legend=c(parse(text=sprintf("%.2f*e^{%.3f*x}", exp(coef(exp_reg$model)[1]),coef(exp_reg$model)[2])), "Prediction", "Confidence"))
}
## Residual Plot
plots4 	<- function(..., overcast=args$overcast){
	if(!overcast){
		exp_reg <- exp_regression(as.numeric(unlist(snsr_sky)), avg)
		title 	<- "Residual of the Mean PW and Temperature Model\nCondition: Clear Sky"
	}else{
		exp_reg <- exp_regression(as.numeric(unlist(snsr_skyo)), avgo)
		title 	<- "Residual of the Mean PW and Temperature Model\nCondition: Overcast"
	}
	plot(resid(exp_reg$model), col=c("royalblue"), pch=16,
		xlab="Zenith Sky Temperature [C]", ylab=expression(sigma), main=title)
}
## Pacman Residual Plot
plots5 	<- function(..., overcast=args$overcast){
	if(!overcast){
		exp_reg 	<- exp_regression(atemp_am, avg)
		title 		<- "Pac-Man Residual of the Mean PW and Temperature Model\nCondition: Clear Sky"
	}else{
		exp_reg 	<- exp_regression(atemp_amo, avgo)
		title 		<- "Pac-Man Residual of the Mean PW and Temperature Model\nCondition: Overcast"
	}
# residual quanities from the regression model
	residual 	<- abs(resid(exp_reg$model))
# sequence used for angular position
	t 			<- seq(40, 320, len=length(residual))
# Maximum radial distance
	rmax 		<- max((residual), na.rm=TRUE)
# 6 equal divisions
	divs 		<- seq(round(min(residual)), round(max(residual)), len=6)
# Plots the residual against an angular position
	polar.plot(0, rp.type="s",labels="",
		radial.lim=c(0, round(rmax, 0)),show.grid=TRUE, show.grid.labels=FALSE,
		main= title, show.radial.grid=FALSE, grid.col="black")

# Color Scheme for the rings
	color1 <- "Yellow"; color2 <- "White"
	draw.circle(0, 0, radius=divs[6], col=color1)
	draw.circle(0, 0, radius=divs[5], col=color2)
	draw.circle(0, 0, radius=divs[4], col=color1)
	draw.circle(0, 0, radius=divs[3], col=color2)
	draw.circle(0, 0, radius=divs[2], col=color1)

	polar.plot(residual, t, rp.type="s",point.col="blue",point.symbols=16, add=TRUE)

	text(divs[2] - 0.08, 0, labels=bquote(.(divs[2])*sigma))
	text(divs[3] - 0.1, 0,  labels=bquote(.(divs[3])*sigma))
	text(divs[4] - 0.1, 0,  labels=bquote(.(divs[4])*sigma))
	text(divs[5] - 0.1, 0,  labels=bquote(.(divs[5])*sigma))
	text(divs[6] - 0.1, 0,  labels=bquote(.(divs[6])*sigma))

	polar.plot(c(0, round(rmax, 0)), c(min(t) - 10, min(t) - 10), lwd=1, rp.type="p",line.col="black", add=TRUE)
	polar.plot(c(0, round(rmax, 0)), c(max(t) + 10, max(t) + 10), lwd=1, rp.type="p",line.col="black", add=TRUE)
}

## Overcast Condition Percentage (bar)
other1 	<- function(...){
	par(mar=c(7.1, 7.1, 7.1, 1.3), xpd=TRUE)
	norm_tmp	<- atemp_am[-c(which(avg %in% NaN))]
	over_tmp	<- atemp_amo[-c(which(avg %in% NaN))]

	norm 		<- norm_tmp[-c(which(norm_tmp %in% NaN))]
	over 		<- over_tmp[-c(which(over_tmp %in% NaN))]

	tot_norm_na <- length(which(norm_tmp %in% NaN)) + length(atemp_am) - length(norm_tmp)
	tot_over_na <- length(which(over_tmp %in% NaN)) + length(atemp_amo) - length(over_tmp)

	slices 	<- c(length(norm), length(over), tot_norm_na, tot_over_na)
	title 	<- c("Clear Sky","Overcast", "Clear Sky NaN", "Overcast NaN")

	color 	<- c("paleturquoise", "plum", "deepskyblue", "magenta")
	bar <- barplot(rev(slices), names.arg=rev(title), col=rev(color),
	horiz=TRUE, las=1,xlab="Samples", axes=FALSE, main="Overcast Condition Percentage")

	axis(side = 1, at = slices, labels=TRUE, las=1)

	pct 	<- round(rev(slices)/sum(rev(slices))*100, 1)
	lbls 	<- paste("   ",pct)
	lbls 	<- paste(lbls, "%", sep="")
	text(0, bar, lbls, cex=1, pos=4)
}
## Overcast Condition Percentage (pie)
other2 	<- function(...){
	par(mar=c(1.1, 1.1, 1.1, 1.3), xpd=TRUE)
	norm_tmp	<- atemp_am[-c(which(avg %in% NaN))]
	over_tmp	<- atemp_amo[-c(which(avg %in% NaN))]

	norm 		<- norm_tmp[-c(which(norm_tmp %in% NaN))]
	over 		<- over_tmp[-c(which(over_tmp %in% NaN))]

	tot_norm_na <- length(which(norm_tmp %in% NaN)) + length(atemp_am) - length(norm_tmp)
	tot_over_na <- length(which(over_tmp %in% NaN)) + length(atemp_amo) - length(over_tmp)

	slices 	<- c(length(norm), length(over), tot_norm_na, tot_over_na)

	title 	<- c("Clear Sky\t","Overcast\t\t", "Clear Sky NaN\t", "Overcast NaN\t")

	color 	<- c("paleturquoise", "plum", "deepskyblue", "magenta")
	pct 	<- round(slices/sum(slices)*100, 1)
	lbls 	<- paste("  ", pct)
	lbls	<- paste(lbls, "%", sep="")

	pie3D(slices, explode=0.07, labels=lbls, main="Overcast Condition Percentage",
		col=color)

	lbls 	<- paste(title, "|\tSample Size:", slices)
	legend("bottomleft", lbls, cex=0.8, inset=c(-0.1, -0.1), fill=color,
			text.width=strwidth(title)[1]*3)
}

## Analytical solution
dev1 	<- function(...){
	#T 	<- seq(min(atemp_am, na.rm=TRUE),max(atemp_am, na.rm=TRUE),len=length(atemp_am) )
	T 	<- atemp_am
	p1 	<- 856.756
	r 	<- 0.997
	g 	<- 9.806

	var 	<- (T*(23.036 - 0.003 * T)/(279.82 + T))
	start	<- 0.38/(r*g) * var

	anal1 	<- log(0.61115, base=exp(1))  + var
	anal2 	<- log(abs(p1 - 0.61115 * exp(-var)), base=exp(1))

	anal_sol <- 10 * start * (anal1 - anal2)
	#anal_sol <- (1.6908/(r*g)) * abs(anal1 - anal2)
	plot(atemp_am, anal_sol)
	print(T)
}

## Main plots for poster
poster1 <- function(...){
# Layout/Margin configuration
		par(mfrow=c(3,2),mar=c(1,2, 3.1, 1), oma=c(1,2,0,0), xpd=TRUE)
# Date limits
		xmin = min(clear_date, na.rm=TRUE)
		xmax = max(clear_date, na.rm=TRUE)
# Air Temperature Time series
		ymax 		<- max(atemp_fl, atemp_te, atemp_am,na.rm=TRUE)
		ymin 		<- min(atemp_fl, atemp_te, atemp_am,na.rm=TRUE)
		range 		<- cbind(atemp_am, atemp_fl, atemp_te)
		range_index <- list(atemp_am, atemp_fl, atemp_te)

		plot(clear_date, t(range)[1,], xlab=NA, ylab=NA, main=NA, pch=16,
			xlim=c(xmin, xmax), ylim=c(ymin, ymax), col=c(toString(sensor[1,3])))

		title("Air Temperature",line=0.5)
		mtext("Temperature [C]", side=2, line=2.5, cex=0.65)

		for(j in 2:length(range_index)){
			points(clear_date, t(range)[j,], pch=16, col=c(toString(sensor[j, 3])))
		}
		legend("topleft", legend=c(sensor_name),col=c(sensor_color), pch=16)

# Air Temperature Time Series (overcast)
		ymax 		<- max(atemp_flo, atemp_teo, atemp_amo, na.rm=TRUE)
		ymin 		<- min(atemp_flo, atemp_teo, atemp_amo, na.rm=TRUE)
		range 		<- cbind(atemp_amo, atemp_flo, atemp_teo)
		range_index <- list(atemp_amo, atemp_flo, atemp_teo)

		plot(over_date, t(range)[1,], ylab=NA,
			main=NA, pch=16, las=1, col=c(toString(sensor[1,3])),
			xlim=c(xmin, xmax), ylim=c(ymin, ymax))

		title("Air Temperature", line=0.5)
		for(j in 2:length(range_index)){
			points(over_date, t(range)[j,], pch=16, col=c(toString(sensor[j, 3])))
		}
# Ground Temperature Time Series
		ymax  		<- max(gtemp_am, gtemp_fl, gtemp_te, na.rm=TRUE)
		ymin  		<- min(gtemp_am, gtemp_fl, gtemp_te, na.rm=TRUE)
		range 		<- cbind(gtemp_am, gtemp_fl, gtemp_te)
		range_index <- list(gtemp_am, gtemp_fl, gtemp_te)

		plot(clear_date, t(range)[1,], xlab=NA, ylab=NA, main=NA, pch=16,
			xlim=c(xmin, xmax), ylim=c(ymin, ymax), col=c(toString(sensor[1, 3])))
		title("Ground Temperature", line=0.5)
		mtext("Temperature [C]", side=2, line=2.5, cex=0.65)

		for(j in 2:length(range_index)){
			points(clear_date, t(range)[j,], pch=16, col=c(toString(sensor[j, 3])))
		}
# Ground Temperature Time Series (overcast)
		ymax  		<- max(gtemp_amo,gtemp_flo,gtemp_teo,na.rm=TRUE)
		ymin  		<- min(gtemp_amo,gtemp_flo,gtemp_teo,na.rm=TRUE)
		range 		<- cbind(gtemp_amo, gtemp_flo, gtemp_teo)
		range_index <- list(gtemp_amo, gtemp_flo, gtemp_teo)

		plot(over_date, t(range)[1,], xlab=NA, ylab=NA, main=NA, pch=16,
			xlim=c(xmin, xmax), ylim=c(ymin, ymax), col=c(toString(sensor[1,3])))
		title("Ground Temperature", line=0.5)

		for(j in 2:length(range_index)){
			points(over_date, t(range)[j,], pch=16, col=c(toString(sensor[j, 3])))
		}
# Change in Temperature Time Series
		ymax 		<- max(d_flir,d_ames,d_te,na.rm=TRUE)
		ymin 		<- min(d_flir,d_ames,d_te,na.rm=TRUE)
		range 		<- cbind(d_ames, d_flir, d_te)
		range_index <- list(d_ames, d_flir, d_te)

		plot(clear_date, t(range)[1,], xlab=NA, ylab=NA,main=NA, pch=16,
			  xlim=c(xmin, xmax), ylim=c(ymin, ymax),col=c(toString(sensor[1, 3])))
		title("Change in Temperature", line=0.5)
		mtext("Temperature [C]", side=2, line=2.5, cex=0.65)

		for(j in 2:length(range_index)){
			points(clear_date, t(range)[j,], pch=16, col=c(toString(sensor[j, 3])))
		}
# Change in Temperature Time Series (overcast)
		ymax 		<- max(d_fliro,d_ameso,d_teo,na.rm=TRUE)
		ymin 		<- min(d_fliro,d_ameso,d_teo,na.rm=TRUE)
		range 		<- cbind(d_ameso, d_fliro, d_teo)
		range_index <- list(d_ameso, d_fliro, d_teo)

		plot(over_date, t(range)[1,], xlab=NA, ylab=NA,main=NA, pch=16,
			 xlim=c(xmin, xmax), ylim=c(ymin, ymax),col=c(toString(sensor[1, 3])))

		title("Change in Temperature", line=0.5)

		for(j in 2:length(range_index)){
			points(over_date, t(range)[j,], pch=16, col=c(toString(sensor[j, 3])))
		}
# Column Titles
		mtext("Condition: Overcast", outer=TRUE, cex=0.75, line=-1.5, at=c(x=0.76))
		mtext("Condition: Clear Sky", outer=TRUE, cex=0.75, line=-1.5, at=c(x=0.26))
}
## Plots Galore for poster
poster2 <- function(...){
# Layout/Margin Configuration
		par(mar=c(3,3, 3, 1), oma=c(1,1.5,0,0), xpd=FALSE)
		layout(matrix(c(1,2,3,3), 2, 2, byrow=TRUE))
# Individual Location PW Temperature Correlation
		xmin  = min(atemp_am, na.rm=TRUE)
		xmax  = max(atemp_am, na.rm=TRUE)
		ymax = max(pw_abq12, pw_abq00, pw_epz12, pw_epz00, na.rm=TRUE)
		ymin = min(pw_abq12, pw_abq00, pw_epz12, pw_epz00, na.rm=TRUE)

		plot(atemp_am, pw_abq12, col=c("red"), las=1, pch=16,
			xlim=c(xmin, xmax), ylim=c(ymin, ymax), xlab=NA, ylab=NA, main=NA)

		title("PW vs Temp",line=0.5)
		mtext("PW [mm]", side=2, line=2.25, cex=0.65)
		mtext("Zenith Sky Temperature [C]", side=1, line=2.25, cex=0.65)

		points(atemp_am, pw_abq00, col=c("blue"), pch=16)
		points(atemp_am, pw_epz12, col=c("green"), pch=16)
		points(atemp_am, pw_epz00, col=c("violet"), pch=16)

		legend("topleft", legend=c("ABQ 12Z", "ABQ 00Z", "EPZ 12Z", "EPZ 00Z"),
				col=c("red", "blue", "green", "violet"), pch=16)

# Locational Average Pw Temperature Correlation
		ymax <- max(abq, epz, na.rm=TRUE)
		ymin <- min(abq, epz, na.rm=TRUE)
		plot(atemp_am, abq, col=c("gold2"), pch=16, las=1, xlim = c(xmin, xmax),
			ylim=c(ymin, ymax),xlab = NA, ylab=NA, main = NA)

		title("Locationional Mean PW and Temp",line=0.5)
		mtext("Zenith Sky Temperature [C]", side=1, line=2.25, cex=0.65)

		points(atemp_am, epz, col=c("dodgerblue"), pch=16)

		legend("topleft", legend=c("ABQ", "EPZ"),
				col=c("gold2", "dodgerblue"), pch=16)
# Total Mean PW Temperature Correlation with expotential regression
		exp_reg <- exp_regression(atemp_am, avg)

		ymax = max(exp_reg$y, na.rm=TRUE)
		ymin = min(exp_reg$y, na.rm=TRUE)

# Non-linear model (exponential)
		plot(exp_reg$x,exp_reg$y, col=c("blueviolet"), pch=16,
		xlim=c(exp_reg$xmin, exp_reg$xmax), ylim=c(ymin, ymax),
		xlab=NA, ylab=NA, main=NA)

		title("Mean PW vs Temp",line=0.5)
		mtext("PW [mm]", side=2, line=2.25, cex=0.65)
		mtext("Zenith Sky Temperature [C]", side=1, line=2.25, cex=0.65)

# Best Fit
		curve(exp(coef(exp_reg$model)[1] + coef(exp_reg$model)[2]*x), col="Red", add=TRUE)
# Confidence Interval
		lines(exp_reg$newx, exp(exp_reg$confint[ ,3]), col="blue", lty="dashed")
		lines(exp_reg$newx, exp(exp_reg$confint[ ,2]), col="blue", lty="dashed")
# Prediction Interval
		lines(exp_reg$newx, exp(exp_reg$predint[ ,3]), col="magenta", lty="dashed")
		lines(exp_reg$newx, exp(exp_reg$predint[ ,2]), col="magenta", lty="dashed")

		legend("topleft",
			legend=c(parse(text=sprintf("%.2f*e^{%.3f*x}", exp(coef(exp_reg$model)[1]),coef(exp_reg$model)[2])), "Prediction", "Confidence"),
			,col=c("Red", "Magenta", "Blue"), pch=c("-", '--', "--"))
# Layout configuration for preceding plots
		layout(matrix(c(1), 2, 2, byrow=TRUE))
}

if(args$instrument){
	print(sensor)
	quit_it()
}
if(args$data){
	if(!args$ml){
	# Pulls the data
		norm  	<- data.frame(list(x=atemp_am, y=avg))
	# Removes the NaN data
		norm 	<- norm[-c(which(avg %in% NaN)), ]
		norm 	<- norm[-c(which(atemp_am %in% NaN)), ]
	# Organizes data to be saved as a csv
		data 	<- data.frame(list(air_temp=c(norm$x), pw=c(norm$y)))
	# File name has a date stamp of the last data entry
		sname 	<- sprintf("~/Downloads/trendline_verify_%s.csv", gsub("/", "_", recent))
	# Writes the data to a csv
		write.csv(data, file=sname, row.names=FALSE)
		cat(green(sprintf("Data sent to %s\n", sname)))
	}else{
	# Pulls the data
		avg_temp	<- fname[7]
		avg_pw 		<- (fname[8] + fname[9] + fname[10] + fname[11])/4
	# Pulls the data
		norm  		<- data.frame(list(x=fname[1], y1=avg_temp, y2=avg_pw, y3=fname[12]))
		print(norm)
	# Removes the NaN data
		norm 		<- norm[-c(which(avg_pw %in% NaN)), ]
		norm 		<- norm[-c(which(avg_temp %in% NaN)), ]

		print(norm)
		data 		<- data.frame(list(date=c(norm$x),
									avg_temp=c(norm$y1),
									avg_pw=c(norm$y2),
									condition=c(norm$y3)))
		print(data)
		colnames(data) <- c("date", "avg_temp", "avg_pw", "condition")
	# Writes the data to a csv
		write.csv(data, file="../data/ml_data.csv", row.names=FALSE)
		cat(green(sprintf("Data sent to ../data/ml_data.csv\n")))
	}
	quit_it()
}
if(args$set == "i"){
	if (!args$overcast){
# Clear Sky condition
		cat(magenta("Condition:"), "Clear Sky\n")
		sname <- sprintf("~/Downloads/main_%s.pdf", gsub("/", "_", recent)) # File name of saved pdf
	}else{
# Overcast Condition
		cat(magenta("Condition:"), "Overcast\n")
		sname <- sprintf("~/Downloads/main_overcast_%s.pdf", gsub("/", "_", recent)) # File name of saved pdf
	}
# Plots avaiable with this option
	cat(green("[1]"), "Air Temperature Time Series\n")
	cat(green("[2]"), "Ground Temperature Time Series\n")
	cat(green("[3]"), "Change in Temperature between Air and Ground Time Series\n")
# Shows plots
	show(te1, te2, am11, am12, fl1, fl2, overcast=args$overcast)
# Saves plots
	if (args$save){
		save(c(te1("save", overcast=args$overcast),
				te2("save", overcast=args$overcast),
				am11("save", overcast=args$overcast),
				am12("save", overcast=args$overcast)), sname)
		cat(green(sprintf("Plot set downloaded to %s\n", sname)))
	}
}
if(args$set == "m"){
	if (!args$overcast){
# Clear Sky condition
		cat(magenta("Condition:"), "Clear Sky\n")
		sname <- sprintf("~/Downloads/main_%s.pdf", gsub("/", "_", recent)) # File name of saved pdf
	}else{
# Overcast Condition
		cat(magenta("Condition:"), "Overcast\n")
		sname <- sprintf("~/Downloads/main_overcast_%s.pdf", gsub("/", "_", recent)) # File name of saved pdf
	}
# Plots avaiable with this option
	cat(green("[1]"), "Air Temperature Time Series\n")
	cat(green("[2]"), "Ground Temperature Time Series\n")
	cat(green("[3]"), "Change in Temperature between Air and Ground Time Series\n")
# Shows plots
	show(main1, main2, main3, overcast=args$overcast)
# Saves plots
	if (args$save){
		save(c(main1("save", overcast=args$overcast),main2("save", overcast=args$overcast), main3("save", overcast=args$overcast)), sname)
		cat(green(sprintf("Plot set downloaded to %s\n", sname)))
	}
}else if(args$set == "p"){
	if(!args$overcast){
# Clear Sky condition
		cat(magenta("Condition:"), "Clear Sky\n")
		sname <- sprintf("~/Downloads/plots_galore_%s.pdf", gsub("/", "_", recent)) # File name of saved pdf
	}else{
# Overcast condition
		cat(magenta("Condition:"), "Overcast\n")
		sname <- sprintf("~/Downloads/plots_galore_overcast_%s.pdf", gsub("/", "_", recent)) # File name of saved pdf
	}
# Plots avaiable with this option
	cat(green("[1]"), "Correlation between PW and Temperature\n")
	cat(green("[2]"), "Correlation between Locational Mean PW and Temperature\n")
	cat(green("[3]"), "Total Mean PW and Temperature\n")
	cat(green("[4]"), "Residual of the Mean PW and Temperature Model\n")
	cat(green("[5]"), "Pac-Man Residual of the Mean PW and Temperature Model\n")
# Shows plots
	show(plots1, plots2, plots3, plots4, overcast=args$overcast)
# Saves plots
	if (args$save){
		save(c(plots1(overcast=args$overcast), plots2(overcast=args$overcast),
			plots3(overcast=args$overcast), plots4(overcast=args$overcast), plots5(overcast=args$overcast)), sname)
		cat(green(sprintf("Plot set downloaded to %s\n", sname)))
	}
}else if(args$set == "o"){
# Plots avaiable with this option
	cat(green("[1]"), "Overcast Condition Percentage (Bar)\n")
	cat(green("[2]"), "Overcast Condition Percentage (Pie)\n")
# Shows plots
	show(other1, other2, overcast=NA)
# Saves plots
	if (args$save){
		sname 	<- sprintf("~/Downloads/other_%s.pdf", gsub("/", "_", recent))
		save(c(other1(), other2()), sname)
		cat(green(sprintf("Plot set downloaded to %s\n", sname)))
	}
}
if(args$poster){
# Plots avaiable with this option
	cat(green("[1]"), "Main\n")
	cat(green("[2]"), "Plots Galore\n")
	cat(green("[3]"), "Overcast Condition Percentage\n")
	cat(green("[4]"), "Pac-Man Residual for Total Mean PW and Temperature\n")
# Shows plots
	show(poster1, poster2, other1, plots5, overcast=NA)
# Saves plots
	if(args$save){
		sname <- sprintf("~/Downloads/poster_%s.pdf", gsub("/", "_", recent))
		save(c(poster1(),poster2(), other1(), plots5()), sname)
		cat(green(sprintf("Plot set downloaded to %s\n", sname)))
	}
}
if(args$dev){
# Plots avaiable with this option
	cat(red("[1]"), "Analytical Solution\n")
# Shows plots
	show(dev1, overcast=NA)
# Saves plots
	if(args$save){
		sname <- sprintf("~/Downloads/dev_%s.pdf", gsub("/", "_", recent))
		save(dev1(), sname)
		cat(green(sprintf("Plot set downloaded to %s\n", sname)))
	}
}
## Ends the script
quit_it()