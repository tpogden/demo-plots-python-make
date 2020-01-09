"""Plot average trips on weekdays between 08:00-09:00 versus the feels-like
  temperature.
"""

import sys
import os
import argparse

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Args ------------------------------------------------------------------------

parser = argparse.ArgumentParser(description="Plotting script.")
parser.add_argument('--pdf', default=False, action="store_true",
    help="Output PDF file.")
parser.add_argument('--png', default=False, action="store_true",
    help="Output PNG file.")
parser.add_argument("--show", default=False, action="store_true",
    help="Show plot in GUI.")
parser.add_argument("--tex", default=False, action="store_true",
    help="Render with TeX.")
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
df['dry'] = df['weather_code'].isin([1,2,3,4])

df = df[df['hour'] == 8] # Only trips between 8AM and 9AM
df = df[df['is_weekend'] == False] # On weekdays
df = df[df['is_holiday'] == False]
df = df[df['dry'] == True]

# Plot ------------------------------------------------------------------------

sns.set_style('darkgrid')
pal = sns.color_palette('deep')
if opts.tex:
    import matplotlib
    matplotlib.rcParams['text.usetex'] = True

jp = sns.jointplot(x='t1', y='cnt', data=df, kind='reg', 
    joint_kws={'scatter_kws':dict(alpha=0.2)}, height=8)
jp.ax_joint.set_xlabel('Temperature (Feels Like)')
jp.ax_joint.set_ylabel('Trips per Hour')
jp.ax_joint.set_ylim([0, 8000])

plt.tight_layout()

# Output ----------------------------------------------------------------------

path_no_ext = os.path.splitext(sys.argv[0])[0]
if opts.pdf:
    plt.savefig(path_no_ext + '.pdf')
if opts.png:
    plt.savefig(path_no_ext + '.png')
if opts.show:
    plt.show()
