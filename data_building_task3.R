## SDP Toolkit: College Going Data Building
## Part 3: Identifying the Ninth-Grade Cohort

## Load necessary packages
## See Previous data_building_task1.R for explanation
source("http://www.straydots.com/code/tomkit.R") 
library(plyr)

## Setting active directory.  
active <- shell('echo %HOMEPATH%', intern=TRUE)
active <- gsub('\\\\', '/', active)
setwd(paste0('C:', active, '/Documents/My Box Files/sdp_cg_toolkit/'))

## Loading of finished demo file
std_demo <- read.csv("./output/Student_School_Year.csv")

## DO NOT RUN -- this will take an hour or so.
## Data Processing  --- Fast programming, slow data processing way.
## This is a good way to prototype a working code chunk first
## Then vectorize it using apply or ddply elsewhere.
for(i in unique(std_demo$sid)){
	.tmp <- subset(std_demo, sid == i)
	
	.tmp <- .tmp[order(.tmp$school_year, .tmp$grade_level),]
	.tmp <- subset(.tmp, grade_level >=9)
	
	.tmp$first_9th_school_year_observed <- .tmp$school_year[1] - (.tmp$grade_level[1] - 9)
	
	if(exists('catch')){
		catch <- rbind(catch, .tmp)
	} else{
		catch <- .tmp
	}
	print(i)  ## use this as progress bar.  Boudn to be slow.
}

## Data Processing  ---- requires logic work but much faster runtime
GetFirst9th <- function(school_year, grade_level){
	.tmp <- data.frame(school_year, grade_level)
	.tmp <- subset(.tmp, grade_level >=9)
	
	.tmp <- .tmp[order(.tmp$school_year, .tmp$grade_level),]  ## not needed if data is pre-sorted but it is always good programming convention to make fewer assumptions about the condition of the input so that the code is more generalizeable in the long run.
	
	if(nrow(.tmp)>0){
	## After we filtered out the non-high school grades, we need to make sure that there's something left to calculate otherwise the function will error out.
		.ret <- .tmp$school_year[1] - (.tmp$grade_level[1] - 9)  
		return(.ret)
	} else{
		return(NA)  ## this can be any default value for N/A
	}
}

std_9th_year <- ddply(std_demo, .(sid), summarize, 
	first_9th_school_year_observed = GetFirst9th(school_year, grade_level))
	
std_demo_final <- merge(std_demo, std_9th_year, by="sid", all.x=TRUE)

## Export to output directory.
dir.create(file.path("./output/"), showWarnings = FALSE) ## create directory
write.csv(std_demo_final, "./output/Student_School_Year_Ninth.csv", row.names=FALSE) 
	
