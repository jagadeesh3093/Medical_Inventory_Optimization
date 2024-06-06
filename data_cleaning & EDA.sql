SELECT * FROM mio.medic;

-- For Data Cleaing
-- Describe about each Column i.e data_type
desc mio.medic;

-- Alter the table to change the data type of the column to DATE
ALTER TABLE mio.medic MODIFY COLUMN Dateofbill DATE;

-- Update the original column with the converted date values
UPDATE mio.medic SET Dateofbill = STR_TO_DATE(Dateofbill, '%m/%d/%Y');

-- Select the Dateofbill column in the desired format
SELECT DATE_FORMAT(Dateofbill, '%d/%m/%Y') AS Dateofbill_dd_mm_yyyy FROM mio.medic;

-- identify duplicates 
SELECT Typeofsales, Patient_ID, Specialisation, Dept, Dateofbill, Quantity, ReturnQuantity , Final_Cost, Final_Sales, RtnMRP, Formulation, DrugName, SubCat, SubCat1, COUNT(*)
FROM mio.medic
GROUP BY Typeofsales, Patient_ID, Specialisation, Dept, Dateofbill, Quantity, ReturnQuantity , Final_Cost, Final_Sales, RtnMRP, Formulation, DrugName, SubCat, SubCat1
HAVING COUNT(*) > 1;

-- Count the number of missing values in Quantity column
SELECT COUNT(*) AS missing_values_count
FROM mio.medic
WHERE Quantity IS NULL;

-- Count the number of missing values in ReturnQuantity column
SELECT COUNT(*) AS missing_values_count
FROM mio.medic
WHERE ReturnQuantity IS NULL;

-- Count the number of missing values in Final_Cost column
SELECT COUNT(*) AS missing_values_count
FROM mio.medic
WHERE Final_Cost IS NULL;

-- To replace empty strings with NULL values
UPDATE mio.medic
SET Formulation = NULL
WHERE Formulation = '';

UPDATE mio.medic
SET DrugName = NULL
WHERE DrugName = '';

UPDATE mio.medic
SET SubCat = NULL
WHERE SubCat = '';

UPDATE mio.medic
SET SubCat1 = NULL
WHERE SubCat1 = '';

-- List rows with null values in a Formulation column
SELECT *
FROM mio.medic
WHERE Formulation IS NULL;

-- Most commonly sold drugs
SELECT DrugName, COUNT(*) AS SalesCount
FROM mio.medic
GROUP BY DrugName
ORDER BY SalesCount DESC;

-- Most popular specializations
SELECT Specialisation, COUNT(*) AS SalesCount
FROM mio.medic
GROUP BY Specialisation
ORDER BY SalesCount DESC;

-- return rate as the ratio of returned quantity to total quantity sold for each drug
SELECT 
    DrugName, 
    COUNT(*) AS TotalSales, 
    SUM(ReturnQuantity) AS TotalReturns, 
    SUM(ReturnQuantity) / COUNT(*) AS ReturnRate
FROM mio.medic
GROUP BY DrugName
ORDER BY ReturnRate DESC;

-- Order by Dateofbill column
CREATE VIEW mio.sorted_medic AS
SELECT *
FROM mio.medic
ORDER BY Dateofbill;

-- View Sorted table
SELECT * FROM mio.sorted_medic;

-- EDA
-- For Quantity column
-- i. First Moment Business Decision
SELECT 
    (SELECT AVG(Quantity) FROM mio.medic) AS mean_quantity,
    (SELECT 
        (SELECT AVG(Quantity) AS median_quantity
         FROM (
             SELECT Quantity, 
                    ROW_NUMBER() OVER (ORDER BY Quantity) AS row_num,
                    COUNT(*) OVER () AS total_rows
             FROM mio.medic
         ) AS ranked
         WHERE row_num IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2))
        )
    ) AS median_quantity,
    (SELECT Quantity AS mode_quantity
     FROM (
         SELECT Quantity, COUNT(*) AS frequency
         FROM mio.medic
         GROUP BY Quantity
         ORDER BY frequency DESC
         LIMIT 1
     ) AS most_frequent
    ) AS mode_quantity;

-- ii. Second Moment Business Decision
SELECT
    (SELECT VARIANCE(Quantity) FROM mio.medic) AS variance_quantity,
    (SELECT STDDEV(Quantity) FROM mio.medic) AS std_dev_quantity,
    (SELECT MAX(Quantity) FROM mio.medic) AS max_quantity,
    (SELECT MIN(Quantity) FROM mio.medic) AS min_quantity;

-- iii. Third Moment Business Decision
SELECT 
    (SUM((Quantity - mean_quantity) * (Quantity - mean_quantity) * (Quantity - mean_quantity)) / COUNT(*)) / POWER(STDDEV(Quantity), 3) AS skewness_quantity
FROM 
    mio.medic,
    (SELECT AVG(Quantity) AS mean_quantity FROM mio.medic) AS mean,
    (SELECT STDDEV(Quantity) AS std_dev_quantity FROM mio.medic) AS std_dev;

-- iv. Fourth Moment Business Decision
SELECT 
    (SUM((Quantity - mean_quantity) * (Quantity - mean_quantity) * (Quantity - mean_quantity) * (Quantity - mean_quantity)) / COUNT(*)) / POWER(STDDEV(Quantity), 4) AS kurtosis_quantity
FROM 
    mio.medic,
    (SELECT AVG(Quantity) AS mean_quantity FROM mio.medic) AS mean,
    (SELECT STDDEV(Quantity) AS std_dev_quantity FROM mio.medic) AS std_dev;
    
-- For ReturnQuantity column
-- i. First Moment Business Decision
SELECT 
    (SELECT AVG(ReturnQuantity) FROM mio.medic) AS mean_return_quantity,
    (SELECT 
        (SELECT AVG(ReturnQuantity) AS median_return_quantity
         FROM (
             SELECT ReturnQuantity, 
                    ROW_NUMBER() OVER (ORDER BY ReturnQuantity) AS row_num,
                    COUNT(*) OVER () AS total_rows
             FROM mio.medic
         ) AS ranked
         WHERE row_num IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2))
        )
    ) AS median_return_quantity,
    (SELECT ReturnQuantity AS mode_return_quantity
     FROM (
         SELECT ReturnQuantity, COUNT(*) AS frequency
         FROM mio.medic
         GROUP BY ReturnQuantity
         ORDER BY frequency DESC
         LIMIT 1
     ) AS most_frequent
    ) AS mode_return_quantity;

-- ii. Second Moment Business Decision
SELECT
    (SELECT VARIANCE(ReturnQuantity) FROM mio.medic) AS variance_return_quantity,
    (SELECT STDDEV(ReturnQuantity) FROM mio.medic) AS std_dev_return_quantity,
    (SELECT MAX(ReturnQuantity) FROM mio.medic) AS max_return_quantity,
    (SELECT MIN(ReturnQuantity) FROM mio.medic) AS min_return_quantity;

-- iii. Third Moment Business Decision
SELECT 
    (SUM((ReturnQuantity - mean_return_quantity) * (ReturnQuantity - mean_return_quantity) * (ReturnQuantity - mean_return_quantity)) / COUNT(*)) / POWER(STDDEV(ReturnQuantity), 3) AS skewness_return_quantity
FROM 
    mio.medic,
    (SELECT AVG(ReturnQuantity) AS mean_return_quantity FROM mio.medic) AS mean,
    (SELECT STDDEV(ReturnQuantity) AS std_dev_return_quantity FROM mio.medic) AS std_dev;

-- iv. Fourth Moment Business Decision
SELECT 
    (SUM((ReturnQuantity - mean_return_quantity) * (ReturnQuantity - mean_return_quantity) * (ReturnQuantity - mean_return_quantity) * (ReturnQuantity - mean_return_quantity)) / COUNT(*)) / POWER(STDDEV(ReturnQuantity), 4) AS kurtosis_return_quantity
FROM 
    mio.medic,
    (SELECT AVG(ReturnQuantity) AS mean_return_quantity FROM mio.medic) AS mean,
    (SELECT STDDEV(ReturnQuantity) AS std_dev_return_quantity FROM mio.medic) AS std_dev;


-- For Final_Cost column
-- i. First Moment Business Decision
SELECT 
    (SELECT AVG(Final_Cost) FROM mio.medic) AS mean_final_cost,
    (SELECT 
        (SELECT AVG(Final_Cost) AS median_final_cost
         FROM (
             SELECT Final_Cost, 
                    ROW_NUMBER() OVER (ORDER BY Final_Cost) AS row_num,
                    COUNT(*) OVER () AS total_rows
             FROM mio.medic
         ) AS ranked
         WHERE row_num IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2))
        )
    ) AS median_final_cost,
    (SELECT Final_Cost AS mode_final_cost
     FROM (
         SELECT Final_Cost, COUNT(*) AS frequency
         FROM mio.medic
         GROUP BY Final_Cost
         ORDER BY frequency DESC
         LIMIT 1
     ) AS most_frequent
    ) AS mode_final_cost;

-- ii. Second Moment Business Decision
SELECT
    (SELECT VARIANCE(Final_Cost) FROM mio.medic) AS variance_final_cost,
    (SELECT STDDEV(Final_Cost) FROM mio.medic) AS std_dev_final_cost,
    (SELECT MAX(Final_Cost) FROM mio.medic) AS max_final_cost,
    (SELECT MIN(Final_Cost) FROM mio.medic) AS min_final_cost;

-- iii. Third Moment Business Decision
SELECT 
    (SUM((Final_Cost - mean_final_cost) * (Final_Cost - mean_final_cost) * (Final_Cost - mean_final_cost)) / COUNT(*)) / POWER(STDDEV(Final_Cost), 3) AS skewness_final_cost
FROM 
    mio.medic,
    (SELECT AVG(Final_Cost) AS mean_final_cost FROM mio.medic) AS mean,
    (SELECT STDDEV(Final_Cost) AS std_dev_final_cost FROM mio.medic) AS std_dev;

-- iv. Fourth Moment Business Decision
SELECT 
    (SUM((Final_Cost - mean_final_cost) * (Final_Cost - mean_final_cost) * (Final_Cost - mean_final_cost) * (Final_Cost - mean_final_cost)) / COUNT(*)) / POWER(STDDEV(Final_Cost), 4) AS kurtosis_final_cost
FROM 
    mio.medic,
    (SELECT AVG(Final_Cost) AS mean_final_cost FROM mio.medic) AS mean,
    (SELECT STDDEV(Final_Cost) AS std_dev_final_cost FROM mio.medic) AS std_dev;

-- For Final_Sales column
-- i. First Moment Business Decision
SELECT 
    (SELECT AVG(Final_Sales) FROM mio.medic) AS mean_final_sales,
    (SELECT 
        (SELECT AVG(Final_Sales) AS median_final_sales
         FROM (
             SELECT Final_Sales, 
                    ROW_NUMBER() OVER (ORDER BY Final_Sales) AS row_num,
                    COUNT(*) OVER () AS total_rows
             FROM mio.medic
         ) AS ranked
         WHERE row_num IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2))
        )
    ) AS median_final_sales,
    (SELECT Final_Sales AS mode_final_sales
     FROM (
         SELECT Final_Sales, COUNT(*) AS frequency
         FROM mio.medic
         GROUP BY Final_Sales
         ORDER BY frequency DESC
         LIMIT 1
     ) AS most_frequent
    ) AS mode_final_sales;

-- ii. Second Moment Business Decision
SELECT
    (SELECT VARIANCE(Final_Sales) FROM mio.medic) AS variance_final_sales,
    (SELECT STDDEV(Final_Sales) FROM mio.medic) AS std_dev_final_sales,
    (SELECT MAX(Final_Sales) FROM mio.medic) AS max_final_sales,
    (SELECT MIN(Final_Sales) FROM mio.medic) AS min_final_sales;

-- iii. Third Moment Business Decision
SELECT 
    (SUM((Final_Sales - mean_final_sales) * (Final_Sales - mean_final_sales) * (Final_Sales - mean_final_sales)) / COUNT(*)) / POWER(STDDEV(Final_Sales), 3) AS skewness_final_sales
FROM 
    mio.medic,
    (SELECT AVG(Final_Sales) AS mean_final_sales FROM mio.medic) AS mean,
    (SELECT STDDEV(Final_Sales) AS std_dev_final_sales FROM mio.medic) AS std_dev;

-- iv. Fourth Moment Business Decision
SELECT 
    (SUM((Final_Sales - mean_final_sales) * (Final_Sales - mean_final_sales) * (Final_Sales - mean_final_sales) * (Final_Sales - mean_final_sales)) / COUNT(*)) / POWER(STDDEV(Final_Sales), 4) AS kurtosis_final_sales
FROM 
    mio.medic,
    (SELECT AVG(Final_Sales) AS mean_final_sales FROM mio.medic) AS mean,
    (SELECT STDDEV(Final_Sales) AS std_dev_final_sales FROM mio.medic) AS std_dev;

-- For RtnMRP column
-- i. First Moment Business Decision
SELECT 
    (SELECT AVG(RtnMRP) FROM mio.medic) AS mean_rtnmrp,
    (SELECT 
        (SELECT AVG(RtnMRP) AS median_rtnmrp
         FROM (
             SELECT RtnMRP, 
                    ROW_NUMBER() OVER (ORDER BY RtnMRP) AS row_num,
                    COUNT(*) OVER () AS total_rows
             FROM mio.medic
         ) AS ranked
         WHERE row_num IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2))
        )
    ) AS median_rtnmrp,
    (SELECT RtnMRP AS mode_rtnmrp
     FROM (
         SELECT RtnMRP, COUNT(*) AS frequency
         FROM mio.medic
         GROUP BY RtnMRP
         ORDER BY frequency DESC
         LIMIT 1
     ) AS most_frequent
    ) AS mode_rtnmrp;

-- ii. Second Moment Business Decision
SELECT
    (SELECT VARIANCE(RtnMRP) FROM mio.medic) AS variance_rtnmrp,
    (SELECT STDDEV(RtnMRP) FROM mio.medic) AS std_dev_rtnmrp,
    (SELECT MAX(RtnMRP) FROM mio.medic) AS max_rtnmrp,
    (SELECT MIN(RtnMRP) FROM mio.medic) AS min_rtnmrp;

-- iii. Third Moment Business Decision
SELECT 
    (SUM((RtnMRP - mean_rtnmrp) * (RtnMRP - mean_rtnmrp) * (RtnMRP - mean_rtnmrp)) / COUNT(*)) / POWER(STDDEV(RtnMRP), 3) AS skewness_rtnmrp
FROM 
    mio.medic,
    (SELECT AVG(RtnMRP) AS mean_rtnmrp FROM mio.medic) AS mean,
    (SELECT STDDEV(RtnMRP) AS std_dev_rtnmrp FROM mio.medic) AS std_dev;

-- iv. Fourth Moment Business Decision
SELECT 
    (SUM((RtnMRP - mean_rtnmrp) * (RtnMRP - mean_rtnmrp) * (RtnMRP - mean_rtnmrp) * (RtnMRP - mean_rtnmrp)) / COUNT(*)) / POWER(STDDEV(RtnMRP), 4) AS kurtosis_rtnmrp
FROM 
    mio.medic,
    (SELECT AVG(RtnMRP) AS mean_rtnmrp FROM mio.medic) AS mean,
    (SELECT STDDEV(RtnMRP) AS std_dev_rtnmrp FROM mio.medic) AS std_dev;