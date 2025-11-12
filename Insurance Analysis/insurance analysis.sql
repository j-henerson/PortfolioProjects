# Creating database
CREATE DATABASE insurance;

USE insurance;

# Data cleaning
# Observing data
SELECT *
FROM insurance_claims
LIMIT 10;

# Identifying duplicate rows without a primary key
WITH dupe_cte as (
	SELECT *,
    ROW_NUMBER() OVER (PARTITION BY age, sex, bmi, children, smoker, region, charges ORDER BY (SELECT NULL)) AS rn
    FROM insurance_claims
)
SELECT *
FROM dupe_cte
WHERE rn > 1
;

# Creating new table without duplicates
CREATE TABLE clean_claims AS 
SELECT *
FROM (
	SELECT *,
    ROW_NUMBER() OVER (PARTITION BY age, sex, bmi, children, smoker, region, charges ORDER BY (SELECT NULL)) AS rn
    FROM insurance_claims
) as rn_tb
WHERE rn = 1
;

# Removing row number
ALTER TABLE clean_claims
DROP COLUMN rn
;

# Checking unique values in categorical columns
SELECT DISTINCT sex
FROM clean_claims;

SELECT DISTINCT region
FROM clean_claims;

SELECT DISTINCT smoker
FROM clean_claims;

# Adding categorical columns for numeric values (Age, BMI buckets)
ALTER TABLE clean_claims
ADD COLUMN age_cat VARCHAR(25) AS (
	CASE
		WHEN age BETWEEN 18 AND 24 THEN '18 to 24'
        WHEN age BETWEEN 25 AND 34 THEN '25 to 34'
        WHEN age BETWEEN 35 AND 44 THEN '35 to 44'
        WHEN age BETWEEN 45 AND 54 THEN '45 to 54'
        WHEN age >= 55 THEN '55 and Older'
        ELSE NULL
	END
),
ADD COLUMN bmi_cat VARCHAR(25) AS (
	CASE
		WHEN bmi < 18.5 THEN 'Underweight (<18.5)'
        WHEN (bmi >= 18.5 AND bmi < 25) THEN 'Normal Weight (18.5-24.9)'
        WHEN (bmi >= 25 AND bmi < 30) THEN 'Overweight (25-29.9)'
        WHEN (bmi >= 30 AND bmi < 40) THEN 'Obese (30-39.9)'
        WHEN bmi >= 40 THEN 'Morbidly Obese (>40)'
        ELSE NULL
	END
)
;


# Observing new columns
SELECT *
FROM clean_claims
LIMIT 10
;

# Checking data types
DESCRIBE clean_claims;

# Checking top and bottom 20 charges and BMI for outliers
SELECT charges
FROM clean_claims
ORDER BY charges DESC
LIMIT 20
;

SELECT charges
FROM clean_claims
ORDER BY charges ASC
LIMIT 20
;

SELECT bmi
FROM clean_claims
ORDER BY bmi DESC
LIMIT 20
;

SELECT bmi
FROM clean_claims
ORDER BY bmi ASC
LIMIT 20
;

# Exploratory data analysis
# Descriptive statistics from numerical columns
SELECT COUNT(age),
AVG(age),
MIN(age),
MAX(age)
FROM clean_claims
;

SELECT COUNT(charges),
AVG(charges),
MIN(charges),
MAX(charges)
FROM clean_claims
;

SELECT COUNT(bmi),
AVG(bmi),
MIN(bmi),
MAX(bmi)
FROM clean_claims
;

# Observing average charges by region
SELECT region, 
ROUND(AVG(charges),2) AS avg_charge
FROM clean_claims
GROUP BY region
ORDER BY avg_charge DESC
;
# On average, the southeast region has the highest insurance charges, while the southwest has the lowest

# Observing average charges by sex
SELECT sex, 
ROUND(AVG(charges),2) AS avg_charge
FROM clean_claims
GROUP BY sex
ORDER BY avg_charge DESC
;
# On average, men have higher insurance charges than women

# Observing average charges by BMI category
SELECT bmi_cat, 
ROUND(AVG(charges),2) AS avg_charge
FROM clean_claims
GROUP BY bmi_cat
ORDER BY avg_charge DESC
;
# On average, insurance charges for those who are morbidly obese are much higher than those in the lowest BMI categories, nearly double of those who are underweight

# Observing average charges by smokers vs. non-smokers
SELECT smoker, 
ROUND(AVG(charges),2) AS avg_charge
FROM clean_claims
GROUP BY smoker
ORDER BY avg_charge DESC
;
# On average, smokers have much higher insurance charges than non-smokers, nearly four times higher

# Observing average charges by age group
SELECT age_cat, 
ROUND(AVG(charges),2) AS avg_charge
FROM clean_claims
GROUP BY age_cat
ORDER BY avg_charge DESC
;
# There appears to be a correlation between age and avergae insurance charge

# Observing characteristics of 100 highest charges
CREATE TEMPORARY TABLE top_100_charges AS (
SELECT *
FROM clean_claims
ORDER BY charges DESC
LIMIT 100)
;

SELECT *
FROM top_100_charges
;

SELECT bmi_cat,
COUNT(bmi_cat) AS count,
(COUNT(*) * 100/SUM(COUNT(*)) OVER()) AS percent
FROM top_100_charges
GROUP BY bmi_cat
ORDER BY percent DESC
;

SELECT age_cat,
COUNT(age_cat) AS count,
(COUNT(*) * 100/SUM(COUNT(*)) OVER()) AS percent
FROM top_100_charges
GROUP BY age_cat
ORDER BY percent DESC
;

SELECT age_cat,
COUNT(age_cat) AS count,
(COUNT(*) * 100/SUM(COUNT(*)) OVER()) AS percent
FROM top_100_charges
GROUP BY age_cat
ORDER BY percent DESC
;

SELECT smoker,
COUNT(smoker) AS count,
(COUNT(*) * 100/SUM(COUNT(*)) OVER()) AS percent
FROM top_100_charges
GROUP BY smoker
ORDER BY percent DESC
;

SELECT sex,
COUNT(sex) AS count,
(COUNT(*) * 100/SUM(COUNT(*)) OVER()) AS percent
FROM top_100_charges
GROUP BY sex
ORDER BY percent DESC
;

SELECT region,
COUNT(region) AS count,
(COUNT(*) * 100/SUM(COUNT(*)) OVER()) AS percent
FROM top_100_charges
GROUP BY region
ORDER BY percent DESC
;

# From looking at these percentages, we can see that all of those in the top 100 highest insurance charges are smokers and either obese or morbidly obese. 
# The majority are male, over the age of 35, and live in the southeast region
# Based on these, we will create a calculated column for risk level
ALTER TABLE clean_claims
ADD COLUMN risk_level VARCHAR(25) AS (
	CASE
		WHEN bmi >= 30 AND smoker = 'yes' THEN 'Very High'
        WHEN bmi >= 30 OR smoker = 'yes' THEN 'High'
        WHEN age >= 35 THEN 'Moderate'
        ELSE 'Low'
	END
)
;

