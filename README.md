# SQL Project Portfolio

## Project Overview

This repository is part of my data-analysis portfolio and focuses on SQL.  
I used an open source dataset from [ourworldindata.org](https://ourworldindata.org/covid-deaths) on covid-19. It is a well maintained, up to date dataset on all kinds of aspects related to covid-19.  
Some of the columns I'll be working with in this project are:
- Continent
- Location
- Date
- Population
- Number of people infected (per day/ in total)
- Number of people that died (per day/ in total)
- The fatality rate
- Number of vaccinations (per day/ in total)

In total the dataset holds 67 categories, so there is a lot of data to dig into.

## How to Use
1. Download MySQL Community Server for your OS at [mysql.com](https://dev.mysql.com/downloads/mysql/).  
2. Install mySQL Server and mySQL Shell.   
3. Setup a local mySQL server (you can keep the default network options) and set a password for the root admin account.  
4. Once installed open the mySQL command line client and login.  
5. `create database covid;`
6. Either continue in the command line client or use a different SQL editor, personally I use [popSQL](https://popsql.com/).


## Dependencies
- [MySQL Community Server](https://dev.mysql.com/downloads/mysql/): [8.1 or above]
  - Description: The project relies on a MySQL database for data storage and retrieval.

## Visualization

Using a subset of SQL queries listed in [tableau_views](tableau-views.sql) I created a tableau dashboard:  

![Tableau Dashboard](images/Covid_Dashboard.png)  

An interactive version can be accessed via [public.tableau.com/](https://public.tableau.com/app/profile/yannik.karsten/viz/CovidDashboard_16972811581590/Dashboard1#1)


## SQL Queries

### 1. Connect to database

I set up a local mySQL server and used popSQL to write queries. 

```sql
-- connect to database
USE
    covid;
```

By default mySQL only has reading privileges to specific directories.
```
-- List directory allowed for import
SHOW VARIABLES
    LIKE 'secure_file_priv';

```

### 2. Load data from CSV

I created two subsets of the original csv file that are specific to covid_deaths and covid_vaccinations. For the sake of brevity, I only show the table "covid_deaths" here.

```
-- Create the table
CREATE TABLE
    covid_deaths (
        iso_code VARCHAR(255),
        continent VARCHAR(255),
        location VARCHAR(255),
        `date` DATE,
        total_cases BIGINT,
        new_cases INT,
        new_cases_smoothed FLOAT,
        total_deaths INT,
        new_deaths INT,
        new_deaths_smoothed FLOAT,
        total_cases_per_million DECIMAL(18, 6),
        new_cases_per_million DECIMAL(18, 6),
        new_cases_smoothed_per_million DECIMAL(18, 6),
        total_deaths_per_million DECIMAL(18, 6),
        new_deaths_per_million DECIMAL(18, 6),
        new_deaths_smoothed_per_million DECIMAL(18, 6),
        reproduction_rate DECIMAL(5, 2),
        population BIGINT
    );
```
Next, I used the `LOAD DATA` statement to read data from the specified CSV file and insert it into the designated MySQL table.
```
-- Load data from CSV
LOAD DATA
    INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\covid_deaths.csv' INTO
TABLE
    covid_deaths FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS -- Skip the header row
    (
        iso_code,
        continent,
        location,
        @date_column,
        @total_cases,
        @new_cases,
        @new_cases_smoothed,
        @total_deaths,
        @new_deaths,
        @new_deaths_smoothed,
        @total_cases_per_million,
        @new_cases_per_million,
        @new_cases_smoothed_per_million,
        @total_deaths_per_million,
        @new_deaths_per_million,
        @new_deaths_smoothed_per_million,
        @reproduction_rate,
        @population
    )
SET
    `date` = STR_TO_DATE(@date_column, '%Y-%m-%d'),
    total_cases = NULLIF(@total_cases, ''),
    new_cases = NULLIF(@new_cases, ''),
    new_cases_smoothed = NULLIF(@new_cases_smoothed, ''),
    total_deaths = NULLIF(@total_deaths, ''),
    new_deaths = NULLIF(@new_deaths, ''),
    new_deaths_smoothed = NULLIF(@new_deaths_smoothed, ''),
    total_cases_per_million = NULLIF(@total_cases_per_million, ''),
    new_cases_per_million = NULLIF(@new_cases_per_million, ''),
    new_cases_smoothed_per_million = NULLIF(@new_cases_smoothed_per_million, ''),
    total_deaths_per_million = NULLIF(@total_deaths_per_million, ''),
    new_deaths_per_million = NULLIF(@new_deaths_per_million, ''),
    new_deaths_smoothed_per_million = NULLIF(@new_deaths_smoothed_per_million, ''),
    reproduction_rate = CASE
        WHEN TRIM(@reproduction_rate) REGEXP '^[0-9]*\\.?[0-9]+$' THEN TRIM(@reproduction_rate)
        ELSE NULL
    END,
    -- " " was treated as an incorrect decimal value. Thus, I set reproduction_rate to NULL when it encounters non-numeric values.
    population = NULLIF(@population, '');
```

Explanation
- Fields Terminated By: Specifies the character that separates fields in the CSV file.
- Enclosed By: Specifies the character that encloses fields containing special characters or spaces.
- Lines Terminated By: Specifies the character that indicates the end of a line.
- IGNORE 1 ROWS: Skips the header row in the CSV file.
- SET: Maps each column from the CSV file to the corresponding column in the table, applying transformations as necessary.
  - As the csv file has some empty cells, it was necessary to set "" to NULL
  
### 3. Query Categories

#### Select, FROM, WHERE, ORDER BY

```
-- Whats the fatatlity rate in germany?
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 as FatalityRate
FROM
    covid_deaths
WHERE
    location LIKE 'germany'
ORDER BY
    1,
    2;
```
```
-- Show what percentage of the population got covid
SELECT
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 as ContractionRate
FROM
    covid_deaths
WHERE
    location LIKE 'germany'
ORDER BY
    1,
    2;
```

#### Aggregate functions

```
--Show highest death count per population by continent
SELECT
    COALESCE(NULLIF(TRIM(continent), ''), 'Global') as continent,
    MAX(total_deaths) as TotalDeathCount
FROM
    covid_deaths
GROUP BY
    continent
ORDER BY
    TotalDeathCount DESC;
```
```
-- Show global data by day for
-- new cases
-- new deaths
-- Fatatlity rate 
SELECT
    date,
    SUM(new_cases) as total_cases,
    SUM(new_deaths) as total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 as FatalityRate
FROM
    covid_deaths
GROUP BY
    DATE
ORDER BY
    1,
    2;
```

#### JOIN + common table expression
```
-- Show total Population vs Vaccinations
-- Using common table expression
WITH
    PopVsVac AS (
        SELECT
            dea.continent,
            dea.location,
            dea.date,
            dea.population,
            vac.new_vaccinations,
            SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location, dea.date) as CumulativePeopleVaccinated,
            (
                SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location, dea.date) / dea.population
            ) * 100 as PercentageVaccinated
        FROM
            covid_deaths dea
            JOIN covid_vaccinations vac ON dea.location = vac.location
            AND dea.date = vac.date
        WHERE
            dea.continent IS NOT NULL
        ORDER BY
            2,
            3
    )
SELECT
    *
FROM
    PopVsVac;
```

#### JOIN + Temporary Table
```
-- Using temp table
-- Drop table if it exists
DROP TEMPORARY
TABLE
    IF EXISTS PercentPopulationVaccinated;

-- Create the temporary table
CREATE TEMPORARY
TABLE
    PercentPopulationVaccinated (
        Continent VARCHAR(255),
        Location VARCHAR(255),
        `date` DATE,
        Population BIGINT,
        New_vaccinations BIGINT,
        CumulativePeopleVaccinated BIGINT
    );

-- Insert into the temporary table
INSERT INTO
    PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (
        PARTITION BY dea.Location
        ORDER BY
            dea.location,
            dea.Date
    ) as CumulativePeopleVaccinated
FROM
    covid_deaths dea
    JOIN covid_vaccinations vac ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    2,
    3;

-- Select from the temporary table with the percentage calculation
SELECT
    *,
    (CumulativePeopleVaccinated / Population) * 100 as PercentageVaccinated
FROM
    PercentPopulationVaccinated;
```

#### Views
```
-- Creating View to store data for later visualization
CREATE VIEW
    PercentPopulationVaccinated as
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (
        PARTITION BY dea.Location
        ORDER BY
            dea.location,
            dea.Date
    ) as CumulativePeopleVaccinated
FROM
    covid_deaths dea
    JOIN covid_vaccinations vac ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    2,
    3;

SELECT
    *
FROM
    PercentPopulationVaccinated
```

## License

Specify the license for your project.


