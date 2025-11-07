#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Author: Daniel Rode


# Description: Python data graphing/plotting template.


import pandas as pd
import matplotlib.pyplot as plt


# BASIC PLOT EXAMPLE

EXPORT_FILE_FORMAT = 'svg'
EXPORT_FILE_NAME = f"plot.{EXPORT_FILE_FORMAT}"
EXPORT_DPI = 300
DATA_PATH = "./downloads/ESS129_Module04_Discussion02_Stevens.csv"
SHEET_NAME = "Sheet 1"
COLUMNS = [
    'Year',
    'Incidence (per 100,000 people) ',
]
PLOT_TITLE = None
X_LABEL = "Year"
Y_LABEL = "Incidence (per 100,000 people)"
X_TICK_RANGE = [0, 1400]
Y_TICK_RANGE = [210, 280]
MARKER_SIZE = 0.3


# Import data
if DATA_PATH.suffix.lower() == '.csv':
    data = pd.read_csv(
        DATA_PATH,
        # 'skiprows' ignores first N rows of data on import
        skiprows=None,
        header=0,
    )
elif DATA_PATH.suffix.lower() == '.xlsx':
    data = pd.read_excel(
        DATA_PATH,
        sheet_name=SHEET_NAME,
        # 'skiprows' ignores first N rows of data on import
        skiprows=None,
        header=0,
    )
else:
    raise Exception(f"Unsupported filetype: {DATA_PATH}")

# data = pd.read_csv(DATA_PATH, skiprows=6, sheet_name=SHEET_NAME)
# data = pd.DataFrame(data[COLUMNS])


# Boxplot: Select data
x = pd.to_datetime(data['Year'], format="%Y")
y = data['Incidence (per 100,000 people) ']


# Boxplot: Plot
fig, ax = plt.subplots(layout="compressed")
# OR
# fig.set_layout_engine('compressed')
ax.plot(x, y, label="Data Label")  # Create plot
ax.legend(loc="upper left")
# ax.scatter(x, y, s=MARKER_SIZE)  # Create scatter plot
ax.set(
    title=PLOT_TITLE,   # Label plot
    xlabel=X_LABEL,     # Label x-axis
    ylabel=Y_LABEL,     # Label y-axis
    xlim=X_TICK_RANGE,  # Set max and min x-ticks
    ylim=Y_TICK_RANGE,  # Set max and min y-ticks
)


# Boxplot: Save plot
fig.savefig(EXPORT_FILE_NAME, dpi=EXPORT_DPI)
plt.show()
