## SDP Toolkit: College Going Data Building
## Part 2: Student School Year

## Load necessary packages
## See Previous data_building_task1.R for explanation
source("http://www.straydots.com/code/tomkit.R") 
library(plyr)

## Setting active directory.  
active <- shell('echo %HOMEPATH%', intern=TRUE)
active <- gsub('\\\\', '/', active)
setwd(paste0('C:', active, '/Documents/My Box Files/sdp_cg_toolkit/'))

## Loading of demo file.  I'm assuming everything is unzipped as is.
std_classifications <- read.csv("./raw/Student_Classifications_Raw.csv")

## Data Transformations Needed
## factor() transforms a column of strings into ordinal categories.  'levels = c(...)' sets the ranking of of the categories.  This allows us to run max/min function on this particular column without having to transform it into a number.
std_classifications$frpl <- factor(std_classifications$frpl, levels=c("N", "R", "F"))

## the other variables are all in the form of integers and easily to manipulate using max/min/sum functions.  For this particular exercise, having a singular flag for iep/ell/gifted is enough to qualify in that category so a max(1,0,0) = 1 would be a 'yes' flag.

## Final Data Set - compile.
## ddply is slow but very convenient for pulling datasets together on the fly.
std_classif_final <- ddply(std_classifications, .(sid, school_year), summarize, 
	grade_level= max(grade_level),
	frpl = max(frpl),
	iep = max(iep),
	ell = max(ell),
	gifted = max(gifted),
	total_days_enrolled = sum(total_days_enrolled),
	total_days_absent = sum(total_days_absent),
	days_suspended_out_of_school = sum(days_suspended_out_of_school))

## Don't have days_suspended_in_school variable so this is skipped.	
	
## Export to output directory.
dir.create(file.path("./output/"), showWarnings = FALSE) ## create directory
write.csv(std_classif_final, "./output/Student_School_Year.csv", row.names=FALSE) 