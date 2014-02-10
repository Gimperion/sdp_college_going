## Data building task 4
from pandas import DataFrame
from datetime import datetime
import pandas as pd
import os
import numpy as np

os.chdir('/Users/Gimperion/Documents/My Box Files/sdp_cg_toolkit/')
std_sch_enroll = pd.read_csv("./raw/Student_School_Enrollment_Raw.csv", na_values=['', 'NULL'])

date_conv = std_sch_enroll.enrollment_date[std_sch_enroll.enrollment_date.notnull()].apply(datetime.strptime, args=['%d%b%Y'])
std_sch_enroll['enr_dt_fixed'] = date_conv

date_conv = std_sch_enroll.withdrawal_date[std_sch_enroll.withdrawal_date.notnull()].apply(datetime.strptime, args=['%d%b%Y'])
std_sch_enroll['wdr_dt_fixed'] = date_conv

std_enr = std_sch_enroll[std_sch_enroll.wdr_dt_fixed.notnull() | std_sch_enroll.enr_dt_fixed.notnull()]

std_enr['school_start'] = (std_enr.school_year -1).apply(datetime, args= [8, 1, 0, 0])
std_enr['school_start'] = std_enr.school_year.apply(datetime, args= [8, 1, 0, 0])

std_enr.enrollment_date[std_enr.enrollment_date < std_enr.school_start & std_enr.enrollment_date.notnull()] = std_enr.school_start[std_enr.enrollment_date < std_enr.school_start & std_enr.enrollment_date.notnull()]

