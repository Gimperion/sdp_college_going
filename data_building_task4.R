## SDP Toolkit: College Going Data Building
## Part 4: Student School Enrollment

## Load necessary packages
## See Previous data_building_task1.R for explanation
source("http://www.straydots.com/code/tomkit.R") 
library(plyr)

## Setting active directory.  
active <- shell('echo %HOMEPATH%', intern=TRUE)
active <- gsub('\\\\', '/', active)
setwd(paste0('C:', active, '/Documents/My Box Files/sdp_cg_toolkit/'))

## Function Definitions

DateRange <- function(x, y){
	return(as.Date(x:y, origin='1970-01-01'))
}


RetOneLine <- function(x){
	if(nrow(x)==1){
		return(x)
	} else{
		x <- x[order(x$enrollment_date),]
		.ret <- x[1,]
		
		.ret$enrollment_date <- min(x$enrollment_date, na.rm=TRUE)
		.ret$withdrawal_date <- max(x$withdrawal_date, na.rm=TRUE)
		
		y <- subset(x, withdrawal_date == max(x$withdrawal_date, na.rm=TRUE))
		
		.ret$withdrawal_code_desc <- y$withdrawal_code_desc[1]
		
		return(.ret)
	}
}


## Loading of finished demo file
std_sch_enroll <- read.csv("./raw/Student_School_Enrollment_Raw.csv")

std_sch_enroll$enrollment_date <- as.Date(std_sch_enroll$enrollment_date, '%d%b%Y')
std_sch_enroll$withdrawal_date <- as.Date(std_sch_enroll$withdrawal_date, '%d%b%Y')

## Make a new copy in case we break the old one ##
std_enr <- subset(std_sch_enroll, !is.na(enrollment_date) | !is.na(withdrawal_date))
std_enr <- subset(std_enr, !(enrollment_date >= withdrawal_date) |(is.na(enrollment_date) | is.na(withdrawal_date)))

std_enr$school_start <- paste(std_enr$school_year-1, "08-01", sep="-")
std_enr$school_end <- paste(std_enr$school_year, "07-31", sep="-")

std_enr <- subset(std_enr, enrollment_date <= school_end)  ## I modified this to <= because honest, you can't really enroll on the last day of school and meaningfully have it count as a valid enrollment. 

## This rule was dumb: Drop observations with enrollment date before the beginning of the current school year.
## So I changed it to: Set enrollment date to start date where this happens.

std_enr$enrollment_date[std_enr$enrollment_date < std_enr$school_start & !is.na(std_enr$enrollment_date)] <- std_enr$school_start[std_enr$enrollment_date < std_enr$school_start& !is.na(std_enr$enrollment_date)]


## Start Collapsing ##
enr_collapsed <- ddply(std_enr, .(sid, school_year, school_code), RetOneLine)
## This takes awhile to run

enr_collapsed$days_enrolled <- as.integer(enr_collapsed$withdrawal_date - enr_collapsed$enrollment_date) +1
enr_collapsed <- enr_collapsed[order(enr_collapsed$school_year, enr_collapsed$enrollment_date),] ## because I'm OCD

## Export to output directory.
dir.create(file.path("./output/"), showWarnings = FALSE) ## create directory
write.csv(enr_collapsed, "./output/Student_School_Enrollment.csv", row.names=FALSE) 


