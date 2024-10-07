import pandas as pd

blank_df = pd.read_csv('data/CUSTOMS copy.csv')
NA_df = pd.read_csv('data/CUSTOMS.csv')

# Check if two DataFrames are equal
print(blank_df.equals(NA_df))
