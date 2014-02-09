from pandas import DataFrame
from datetime import datetime
import pandas as pd
import os
import numpy as np

## get current dir -- os.getcwd()
os.chdir('/Users/Gimperion/Documents/My Box Files/sdp_cg_toolkit/')
std_class = pd.read_csv("./output/Student_School_Year.csv", na_values=['', 'NULL'])

def GetFirst9th(x):
    