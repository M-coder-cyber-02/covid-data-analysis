

-- COVID-19 Contributing Factors SQL Project Queries

-- Data Understanding & Cleaning

-- Check distinct values for unexpected labels
SELECT DISTINCT "age_group" FROM covid_data;
SELECT DISTINCT "state" FROM covid_data;
SELECT DISTINCT "condition" FROM covid_data;

-- Check for missing values
SELECT COUNT(*) - COUNT("covid_deaths") AS missing_deaths FROM covid_data;

-- Validate date formats
SELECT MIN("start_date"), MAX("end_date") FROM covid_data;

-- 2️. Exploratory Data Analysis (EDA)

-- Total COVID deaths per state and year
SELECT 
  "state",
  EXTRACT(YEAR FROM "end_date") AS year,
  SUM("covid_deaths") AS total_deaths
FROM covid_data
WHERE "state" != 'United States'
GROUP BY "state", EXTRACT(YEAR FROM "end_date")
ORDER BY total_deaths DESC;

-- Deaths by age group
SELECT 
  "age_group",
  SUM("covid_deaths") AS total_deaths
FROM covid_data
WHERE age_group NOT IN ('All Ages', 'Not stated')
GROUP BY "age_group"
ORDER BY total_deaths DESC;

-- Deaths by contributing condition
SELECT 
  "condition",
  SUM("covid_deaths") AS total_deaths
FROM covid_data
WHERE condition NOT IN ('COVID-19', 'All other conditions and causes (residual)')
GROUP BY "condition"
ORDER BY total_deaths DESC;

-- Death trends over time (monthly)
SELECT
  EXTRACT (MONTH FROM "start_date") AS month,
  SUM(covid_deaths) AS total_deaths
FROM covid_data
GROUP BY month
ORDER BY month;

-- Most common contributing conditions per state
SELECT
  "state",
  "condition", 
  SUM("covid_deaths") AS total_deaths
FROM covid_data
WHERE state != 'United States' AND condition NOT IN ('COVID-19', 'All other conditions and causes (residual)')
GROUP BY "state", "condition"
ORDER BY total_deaths DESC;


-- Most commonly occurring conditions per state
SELECT 
  "state",
  "condition",
  COUNT(*) AS condition_count,
  RANK() OVER (PARTITION BY "state" ORDER BY COUNT(*) DESC) AS rank
FROM covid_data
WHERE state != 'United States' AND condition NOT IN ('COVID-19', 'All other conditions and causes (residual)')
GROUP BY "state", "condition"
ORDER BY "state", rank;

-- Compare deaths with and without contributing conditions by age group
SELECT 
  "age_group",
  SUM(CASE WHEN "number_of_mentions" > 0 THEN "covid_deaths" ELSE 0 END) AS deaths_with_factors,
  SUM(CASE WHEN "number_of_mentions" = 0 THEN 1 ELSE 0 END) AS deaths_without_factors
FROM covid_data
WHERE "age_group" NOT IN('All Ages', 'Not stated')
GROUP BY "age_group"
ORDER BY "age_group" DESC;


-- 3. Advanced Analytics

-- Rank states by deaths per year
SELECT 
  "state",
  SUM("covid_deaths") AS total_deaths,
  EXTRACT (YEAR FROM "end_date") AS year,
  RANK() OVER(PARTITION BY EXTRACT (YEAR FROM "end_date") ORDER BY SUM(covid_deaths) DESC) AS rank
FROM covid_data
WHERE state != 'United States'
GROUP BY state, EXTRACT(YEAR FROM "end_date")
ORDER BY rank, total_deaths DESC;

-- States with more than 5000 deaths in a year
SELECT 
  "state",
  EXTRACT(YEAR FROM "end_date") AS year,
  SUM("covid_deaths") AS total_deaths
FROM covid_data
WHERE state != 'United States'
GROUP BY state, year
HAVING SUM("covid_deaths") > 5000
ORDER BY total_deaths;

-- Top 5 contributing factors overall
SELECT
  "condition",
  SUM("covid_deaths") AS total_deaths
FROM covid_data
WHERE condition NOT IN ('COVID-19', 'All other conditions and causes (residual)')
GROUP BY "condition"
ORDER BY total_deaths DESC
LIMIT 5;

-- Average number of contributing conditions per death (if Number_of_Mentions exists)
SELECT  
  AVG("number_of_mentions") AS avg_contributing_conditions
FROM covid_data
WHERE "covid_deaths" > 0;
 
-- 4️. Outlier and Quality Check

-- Identify unexpected flags
SELECT DISTINCT "flags" FROM covid_data;

-- Check for 'All Ages' total vs sum of individual age groups
SELECT SUM("covid_deaths") FROM covid_data WHERE "age_group" = 'All Ages';
SELECT SUM("covid_deaths") FROM covid_data WHERE "age_group" != 'All Ages';
