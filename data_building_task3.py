from pandas import DataFrame
from datetime import datetime
import pandas as pd
import os
import numpy as np

os.chdir('/home/gimperion/box/sdp_cg_toolkit')
std_class = pd.read_csv("./raw/Student_Classifications_Raw.csv", na_values=['', 'NULL'])

