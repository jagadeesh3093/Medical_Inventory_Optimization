import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import create_engine

# Establish a connection to your MySQL database
engine = create_engine('mysql://root:root@localhost/mio')

# Query the data from the 'medic' table into a DataFrame
query = 'SELECT * FROM medic;'
df = pd.read_sql(query, engine)

#--------------Data Preprocessing---------------------------
# i. Handling Duplicate Rows
duplicates = df[df.duplicated()]
print("Duplicate Rows:")
print(duplicates)

# Drop duplicates 
df = df.drop_duplicates()

# ii. Handling Missing Values
missing_values = df.isnull().sum()
print("Missing Values:")
print(missing_values)

# Fill missing values in 'Formulation' column with the mode
mode_formulation = df['Formulation'].mode()[0]
df['Formulation'] = df['Formulation'].fillna(mode_formulation)

# Fill missing values in 'DrugName' column with the mode
mode_drugname = df['DrugName'].mode()[0]
df['DrugName'] = df['DrugName'].fillna(mode_drugname)

# List of categorical columns with missing values
categorical_columns_with_missing_values = ['Specialisation', 'Dept', 'SubCat', 'SubCat1']

# Fill missing values in each categorical column with its mode
for column in categorical_columns_with_missing_values:
    mode_value = df[column].mode()[0]
    df[column] = df[column].fillna(mode_value)

# iii. Outlier Analysis / Treatment
# Perform outlier analysis for numerical columns
# Boxplot
numerical_columns = ['Quantity', 'ReturnQuantity', 'Final_Cost', 'Final_Sales', 'RtnMRP']
for column in numerical_columns:
    plt.figure(figsize=(8, 6))
    plt.boxplot(df[column])
    plt.title(f'Boxplot of {column}')
    plt.show()
#Scatter plot
# Scatter plot of 'Final_Cost' vs 'Final_Sales'
plt.figure(figsize=(8, 6))
plt.scatter(df['Final_Cost'], df['Final_Sales'])
plt.title('Scatter Plot of Final Cost vs Final Sales')
plt.xlabel('Final Cost')
plt.ylabel('Final Sales')
plt.show()

# Scatter plot of 'Quantity' vs 'ReturnQuantity'
plt.figure(figsize=(8, 6))
plt.scatter(df['Quantity'], df['ReturnQuantity'])
plt.title('Scatter Plot of Quantity vs Return Quantity')
plt.xlabel('Quantity')
plt.ylabel('Return Quantity')
plt.show()


# Calculate the median or mean of the 'Quantity' column
median_quantity = df['Quantity'].median()  # Use median for skewed data, otherwise use mean

# Replace outlier with the median or mean
df.loc[df['Quantity'] > 140, 'Quantity'] = median_quantity

# Calculate the median or mean of the 'Final_Cost' column
median_final_cost = df['Final_Cost'].median()  # Use median for skewed data, otherwise use mean

# Replace outlier with the median or mean
df.loc[df['Final_Cost'] > 30000, 'Final_Cost'] = median_final_cost

# Calculate the median or mean of the 'Final_Sales' column
median_final_sales = df['Final_Sales'].median()  # Use median for skewed data, otherwise use mean

# Replace outliers with the median or mean
df.loc[df['Final_Sales'] > 35000, 'Final_Sales'] = median_final_sales

# Calculate the median or mean of the 'RtnMRP' column
median_rtnmrp = df['RtnMRP'].median()  # Use median for skewed data, otherwise use mean

# Replace outlier with the median or mean
df.loc[df['RtnMRP'] > 7000, 'RtnMRP'] = median_rtnmrp

#------------------------ Data Analysis -----------------------------------------------
# # Plot line charts for sales and returns over time
# Convert 'Dateofbill' column to datetime format
df['Dateofbill'] = pd.to_datetime(df['Dateofbill'])

# Group data by date and calculate total sales and returns for each date
daily_sales = df[df['Typeofsales'] == 'Sale'].groupby('Dateofbill')['Final_Cost'].sum()
daily_returns = df[df['Typeofsales'] == 'Return'].groupby('Dateofbill')['Final_Cost'].sum()

# Plot line charts for sales and returns over time
plt.figure(figsize=(10, 6))
plt.plot(daily_sales.index, daily_sales.values, label='Total Sales')
plt.plot(daily_returns.index, daily_returns.values, label='Total Returns')
plt.title('Trends in Sales and Returns Over Time')
plt.xlabel('Date')
plt.ylabel('Amount')
plt.legend()
plt.show()


# Calculate inventory turnover ratio
total_quantity_sold = df['Quantity'].sum()
average_inventory = df['Quantity'].mean()
inventory_turnover_ratio = total_quantity_sold / average_inventory
print("Inventory Turnover Ratio:", inventory_turnover_ratio)

# Calculate return rate
total_returned_quantity = df['ReturnQuantity'].sum()
total_quantity_sold = df['Quantity'].sum()
return_rate = total_returned_quantity / total_quantity_sold
print("Return Rate:", return_rate)

# Plot distribution of sales by DrugName
plt.figure(figsize=(14, 6))
df.groupby('DrugName')['Final_Sales'].sum().sort_values(ascending=False).head(10).plot(kind='bar')
plt.title('Top 10 Drugs by Sales')
plt.xlabel('Drug Name')
plt.ylabel('Total Sales')
plt.xticks(rotation=0, fontsize=5.5)  # Rotate x-axis labels to 0 degrees (horizontal) and set font size
plt.tight_layout()  # Adjust layout to prevent clipping of labels
plt.show()

# Plot distribution of sales by SubCat
plt.figure(figsize=(13, 6))
df.groupby('SubCat')['Final_Sales'].sum().sort_values(ascending=False).head(6).plot(kind='bar')
plt.title('Top 6 Subcategories by Sales')
plt.xlabel('Subcategory')
plt.ylabel('Total Sales')
plt.xticks(rotation=0, fontsize=5.5)  # Rotate x-axis labels to 0 degrees (horizontal) and set font size
plt.tight_layout()  # Adjust layout to prevent clipping of labels
plt.show()

# Analyze return rates for different drugs and categories
drug_return_rates = df.groupby('DrugName')['ReturnQuantity'].sum() / df.groupby('DrugName')['Quantity'].sum()
subcat_return_rates = df.groupby('SubCat')['ReturnQuantity'].sum() / df.groupby('SubCat')['Quantity'].sum()

print("Return Rates by DrugName:")
print(drug_return_rates)
print("\nReturn Rates by SubCat:")
print(subcat_return_rates)

# Example data for sales by category
sales_by_category = df.groupby('Dept')['Final_Sales'].sum()

# Plot pie chart for sales by category
plt.figure(figsize=(8, 8))
plt.pie(sales_by_category, labels=sales_by_category.index, autopct='%1.1f%%', startangle=140)
plt.title('Proportion of Sales by Dept')
plt.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle
plt.show()

#line chart showing the trend of Final_Sales over time, overlaid with markers indicating changes in bounce rate
# Group data by date and calculate total sales for each date
daily_sales = df[df['Typeofsales'] == 'Sale'].groupby('Dateofbill')['Final_Sales'].sum()

# Calculate bounce rate (return percentage) for each date
daily_returns = df[df['Typeofsales'] == 'Return'].groupby('Dateofbill')['ReturnQuantity'].sum()
daily_quantity_sold = df[df['Typeofsales'] == 'Sale'].groupby('Dateofbill')['Quantity'].sum()
bounce_rate = (daily_returns / daily_quantity_sold) * 100  # Convert to percentage

# Plot line chart for total sales over time
plt.figure(figsize=(10, 6))
plt.plot(daily_sales.index, daily_sales.values, label='Total Sales', color='blue')
plt.xlabel('Date')
plt.ylabel('Total Sales')
plt.title('Trend of Total Sales Over Time')

# Overlay markers indicating changes in bounce rate
plt.scatter(bounce_rate.index, daily_sales.loc[bounce_rate.index], marker='o', color='red', label='Bounce Rate Change')
plt.legend()
plt.grid(True)
plt.show()
#---------------------------- AutoEDA ---------------------------------------
import sweetviz as sv

# Generate the AutoEDA report
report = sv.analyze(df)

# Save the report to a file
report.show_html("sweetviz_report.html")



