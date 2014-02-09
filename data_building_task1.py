from pandas import DataFrame
from datetime import datetime
import pandas as pd
import os
import numpy as np

## setting my directory here and reading the raw data file from CSV
##os.chdir('C:\\Users\\Gimperion\\Documents\\My Box Files\\sdp_cg_toolkit')
os.chdir('/home/gimperion/box/sdp_cg_toolkit')
std_demo = pd.read_csv("./raw/Student_Demographics_Raw.csv", na_values=['', 'NULL'])

## Drop Column in Python -- removing as asked
std_demo_alt = std_demo.drop('first_9th_school_year_reported',1)

## defining a function to apply to various chunks of data
def mode_male(x):
    vcounts = x.male.value_counts()
    vcounts = vcounts[vcounts==vcounts.max()]
    ## value_counts() returns a count of each unique value in an array/column
    if len(vcounts)==1:
        return vcounts.keys()[0]
    else:
        x = x.sort('school_year', ascending=1)
        return x.male.keys()[-1:][0]

## deduped male_variable
dedupe_male = std_demo_alt.groupby("sid").apply(mode_male)
std_demo_alt['gender_male'] = std_demo_alt.sid.map(dedupe_male)

## fill NA due to var encoding
std_demo_alt.race_ethnicity = std_demo_alt.race_ethnicity.fillna("NA")  ## Because SDP codes Native American as NA and R/Python reads this as missing.
## This is a nifty way of mapping a data column to different values instead of doing lots of if/else statements
racemap =  pd.Series({'B':1, 'A':2, 'H':3, 'NA':4, 'W':5, 'M/O':6})
std_demo_alt['race_num'] = std_demo_alt.race_ethnicity.map(racemap)

## Drop & Rename a column
std_demo_alt = std_demo_alt.drop("male",1)
std_demo_alt = std_demo_alt.drop("race_ethnicity",1)
std_demo_alt = std_demo_alt.rename(columns={'gender_male':'male', 'race_num':'race_ethnicity'})

def within_yr_race(x):
    vcounts = x.race_ethnicity.value_counts()
    if len(vcounts) ==1:
        return vcounts.keys()[0]
    elif 3 in vcounts:
        return 3
    else: 
        return 6

def mode_race(x):
    y = x.groupby("school_year").apply(within_yr_race)
    vcounts = y.value_counts()
    vcounts = vcounts[vcounts==vcounts.max()]
    
    if len(vcounts)==1:
        return vcounts.keys()[0]
    else:
        x = x.sort('school_year', ascending=1)
        return x.race_ethnicity.values[-1]

## split data up by SID and apply mode_race to each chunk of the data and follows the split/apply/combine (SAC) paradigm which is similar to MapReduce/Hadoop and all kinds of other nifty parallel processing techniques.
dedupe_race = std_demo_alt.groupby("sid").apply(mode_race)

## map results to new table by key
## std_demo_alt['dedupe_race'] = zip(std_demo_alt.sid, std_demo_alt.school_year) -- no longer neccessary
std_demo_alt['race_num'] = std_demo_alt.sid.map(dedupe_race)
##std_demo_alt = std_demo_alt.drop('dedupe_race', 1) -- no longer neccessary

dipl_map = pd.Series({'College Prep Diploma':1, 'Standard Diploma':2, 'Alternative Diploma':3})
std_demo_alt['dipl_num'] = std_demo_alt.hs_diploma_type.map(dipl_map)

## I do this manually because it's 'safer' and I can run this in pieces to check if the data transformation is working.
std_demo_alt = std_demo_alt.drop("hs_diploma_type",1)
std_demo_alt = std_demo_alt.rename(columns={'dipl_num':'hs_diploma_type'})
## recode the date.  -- this can be better written but I'm somewhat lazy to lookup exact syntax
date_conv = std_demo_alt.hs_diploma_date[std_demo_alt.hs_diploma_date.notnull()].apply(datetime.strptime, args=['%d%b%Y'])
std_demo_alt['dipl_date_fmt'] = std_demo_alt.sid.map(date_conv)

def dipl_map(x):
    tmp = x[x.hs_diploma_type.notnull()]
    
    if len(tmp) == 0:
        return np.nan
    
    vcounts = tmp.hs_diploma_type.value_counts()
    vcounts = vcounts[vcounts==vcounts.max()]
    if len(vcounts)==1:
        return vcounts.keys()[0]
    else:
        sy = sorted(tmp.school_year.unique())[0]
        return min(tmp.hs_diploma_type[tmp.school_year == sy])

dedupe_dipl = std_demo_alt.groupby("sid").apply(dipl_map)

std_demo_alt['hs_diploma_type'] = std_demo_alt.sid.map(dedupe_dipl)

std_demo_final = std_demo_alt[['sid', 'male', 'race_num', 'hs_diploma', 'dipl_date_fmt', 'hs_diploma_type']].drop_duplicates()

std_demo_final.columns = ['sid', 'male', 'race_ethnicity', 'hs_diploma', 'hs_diploma_date', 'hs_diploma_type']
## export dataframe here.  -- not writing code right now.


