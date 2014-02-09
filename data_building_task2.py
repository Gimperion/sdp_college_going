from pandas import DataFrame
from datetime import datetime
import pandas as pd
import os
import numpy as np

os.chdir('/home/gimperion/box/sdp_cg_toolkit')
std_class = pd.read_csv("./raw/Student_Classifications_Raw.csv", na_values=['', 'NULL'])

frl_map =  pd.Series({'N': 0, 'R': 1, 'F': 2})
std_class['frl_num'] = std_class.frpl.map(frl_map)

def class_reduce(x):
    ret_chunk = {
        'sid': x.sid[0]
    }
    return DataFrame(ret_chunk)

max_group = std_class[['sid', 'school_year', 'grade_level', 'frl_num', 'iep', 'ell', 'gifted']].groupby(['sid', 'school_year']).max()

sum_group = std_class[['sid', 'school_year', 'total_days_enrolled', 'total_days_absent', 'days_suspended_out_of_school']].groupby(['sid', 'school_year']).sum()

std_class_final = pd.merge(max_group, sum_group, left_index=True, right_index=True, how='outer')
