## SDP Toolkit: College Going Data Building
## Part 1: Student Attributes

## Load necessary packages
## if you don't have plyr, just type "install.packages("plyr")" into the R prompt
source("http://www.straydots.com/code/tomkit.R") ## this is my own set of R preferences/useful collection of functions
library(plyr)
## library(foreign) -- to read STATA files, if neccessary.

## Setting active directory.  Your directory might look different
## Set active directory by calling: setwd("C:/<your path here/sdp_cg_toolkit/")
## Mine is tied to my box.net account so I can work on several computers and 
## not worry about where I save my files
active <- shell('echo %HOMEPATH%', intern=TRUE)
active <- gsub('\\\\', '/', active)
setwd(paste0('C:', active, '/Documents/My Box Files/sdp_cg_toolkit/'))

## Loading of demo file.  I'm assuming everything is unzipped as is.
std_demo <- read.csv("./raw/Student_Demographics_Raw.csv")

## Function Calls
## Useful functions that will be run over and over on the data.

## Note to self: Need to write different processing rules for one mode_last 
## function instead of separate functions for each data type.
## Flag for future improvement.
mode_last_integer <- function(x){
	.ret <- mhack(x)
	
	if(length(.ret)==1){
		return(.ret)
	} else{
		return(tail(x,1))
	}
}

mode_last_string <- function(x){
	x <- subset(x, !is.na(x))
	.ret <- mhack2(x)
	
	if(length(.ret)==1){
		return(.ret)
	} else{
		return(tail(x,1))
	}
}

## Function that returns most prestigious diploma for the minimum date chunk
GetDiplType <- function(x){
	x <- as.data.frame(x)
	x <- subset(x, !is.na(x$dipl_num) & dipl_date == min(x$dipl_date))
	
	if(nrow(x)==0){
		return(NA)
	} else{
		.ret <- mhack(x$dipl_num)
		
		if(length(.ret)==1){
			return(.ret)
		} else{
			return(min(.ret, na.rm=TRUE))
		}
	}
}

### START DATA PROCESSING ### 
std_demo <- std_demo[order(std_demo$sid, std_demo$school_year),]  ## Make sure data is sorted properly so that the last is the latest.

## Fix for Native American coded to 'NA'
std_demo$race_ethnicity[is.na(std_demo$race_ethnicity)] <- "NA"

std_attrib <- ddply(std_demo, .(sid), summarize, 
	male=mode_last_integer(male), 
	race_ethnicity=mode_last_string(race_ethnicity))

## Diploma Type processing
std_demo$dipl_num <- NA
std_demo$dipl_num[std_demo$hs_diploma_type=='College Prep Diploma'] <- 1
std_demo$dipl_num[std_demo$hs_diploma_type=='Standard Diploma'] <- 2
std_demo$dipl_num[std_demo$hs_diploma_type=='Alternative Diploma'] <- 3

## Conversion of hs_diploma_date to machine readable date
std_demo$dipl_date <- as.Date(toupper(std_demo$hs_diploma_date), "%d%b%Y")

## Calculates hs_diploma_date and hs_diploma_type according to SDP Toolkit rules.
std_diploma <- ddply(std_demo[!is.na(std_demo$dipl_date),], .(sid), summarize,
	hs_diploma_date = min(dipl_date, na.rm=TRUE),
	hs_diploma_type = GetDiplType(cbind(dipl_date, dipl_num)))

## If student is in std_diploma, then hs_diplma = yes
std_attrib$hs_diploma <- 0
std_attrib$hs_diploma[std_attrib$sid %in% std_diploma$sid] <- 1

## Final Data Set - compile.
std_attrib_final <- merge(std_attrib, std_diploma, by=c("sid"), all.x=TRUE)

## Export File 
dir.create(file.path("./output/"), showWarnings = FALSE) ## create directory
write.csv(std_attrib_final, "./output/Student_Attributes.csv", row.names=FALSE)