from pandas import DataFrame
from datetime import datetime
import pandas as pd
import os
import numpy as np

## get current dir -- os.getcwd()
os.chdir('/Users/Gimperion/Documents/My Box Files/sdp_cg_toolkit/')
std_demo = pd.read_csv("./output/Student_School_Year.csv", na_values=['', 'NULL'])

def GetFirst9th(x):
    x = x.sort(['school_year', 'grade_level'])
    x = x[x.grade_level >= 9]
    
    ## this was a pain in the neck to debug.  Arrays used by Pandas through groupby are now convered into series and cannot be accessed directly via: x.school_year[0] but must be accessed through values.
    if len(x) > 0:
        return x.school_year.values[0] - (x.grade_level.values[0] - 9)

std_9th_year = std_demo.groupby("sid").apply(GetFirst9th)
std_demo['std_9th_year'] = std_demo.sid.map(std_9th_year)


