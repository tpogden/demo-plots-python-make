"""Create table for average trips on weekdays between 08:00-09:00 across 
seasons for dry and wet weather.
"""

import sys
import os
import argparse

import numpy as np
import pandas as pd

# Args ------------------------------------------------------------------------

parser = argparse.ArgumentParser(description="Table script.")
parser.add_argument("--start", default='2015-01-04', help="Start date.",
    type=str)
parser.add_argument("--end", default='2017-01-03', help="End date.",
    type=str)
opts, unknown = parser.parse_known_args()
print('opts:', opts)

# Data ------------------------------------------------------------------------

FPATH = 'data/raw/london_merged.csv'
START_DATE = opts.start
END_DATE = opts.end

df_raw = pd.read_csv(filepath_or_buffer=FPATH, index_col=0, parse_dates=[0], 
    dtype={'weather_code': np.int, 'is_holiday': np.bool, 'is_weekend': bool, 
        'season': int})

df = df_raw.loc[START_DATE:END_DATE]
df['dayofweek'] = df.index.dayofweek
df['hour'] = df.index.hour
df = df[df['is_weekend'] == False]
df = df[df['is_holiday'] == False]
df['dry'] = df['weather_code'].isin([1,2,3,4])

df = df[df['hour'] == 8] # Only trips between 8AM and 9AM

dict_season = {0: 'Spring', 1:'Summer', 2:'Autumn', 3:'Winter'}
dict_weather = {False: 'Dry', True: 'Wet'}

df['dry'].replace(dict_weather, inplace=True)
df['season'].replace(dict_season, inplace=True)

# Table ------------------------------------------------------------------------

df_piv = pd.pivot_table(df, values='cnt', index='dry', 
    columns=['season'], aggfunc={'cnt': [np.mean]})
df_piv.index.name = None
df_piv.columns = dict_season.values()
df_piv = df_piv.astype(int)

# Output ----------------------------------------------------------------------

path_no_ext = os.path.splitext(sys.argv[0])[0]

df_piv.to_latex(path_no_ext + '.tex')
