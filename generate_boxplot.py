#!/usr/bin/env python

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
import sys

# Use a non-interactive backend for Matplotlib
matplotlib.use('Agg')

# Get input and output file names from command line arguments
input_file = sys.argv[1]
output_file = sys.argv[2]

# Read the data
data = pd.read_csv(input_file, sep="\t")  # Adjust the separator if necessary

# Strip whitespace from column names
data.columns = data.columns.str.strip()

# Print the column names for debugging
print("Columns in the data:", data.columns.tolist())

# Create a boxplot using Matplotlib
plt.figure(figsize=(10, 6))

# Create a boxplot for each unique value in the 'Sample Type' column
data.boxplot(column='Expression_Value', by='Sample Type', grid=False)

# Set the title and labels
plt.title('Boxplot of Expression Values by Sample Type')
plt.suptitle('')  # Suppress the default title to clean up the plot
plt.xlabel('Sample Type')
plt.ylabel('Expression Value')

# Save the plot
plt.savefig(output_file)
plt.close()
