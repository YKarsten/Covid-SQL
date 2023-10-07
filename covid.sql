USE
    covid;

-- List directory allowed for import
SHOW VARIABLES
    LIKE 'secure_file_priv';

-- Drop the table if it exists
DROP TABLE
    IF EXISTS covid_deaths;

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

-- Load Vaccinations Data
-- Drop the table if it exists
DROP TABLE
    IF EXISTS covid_vaccinations;

-- Create the table
CREATE TABLE
    covid_vaccinations (
        iso_code VARCHAR(255),
        continent VARCHAR(255),
        location VARCHAR(255),
        `date` DATE,
        total_tests BIGINT,
        new_tests BIGINT,
        total_tests_per_thousand INT,
        new_tests_per_thousand INT,
        new_tests_smoothed FLOAT,
        new_tests_smoothed_per_thousand INT,
        positive_rate FLOAT,
        tests_per_case FLOAT,
        tests_units VARCHAR(255),
        total_vaccinations BIGINT,
        people_vaccinated BIGINT,
        people_fully_vaccinated BIGINT,
        total_boosters BIGINT,
        new_vaccinations INT,
        new_vaccinations_smoothed INT,
        total_vaccinations_per_hundred FLOAT,
        people_vaccinated_per_hundred FLOAT,
        people_fully_vaccinated_per_hundred FLOAT,
        total_boosters_per_hundred FLOAT,
        new_vaccinations_smoothed_per_million INT,
        new_people_vaccinated_smoothed INT,
        new_people_vaccinated_smoothed_per_hundred FLOAT,
        stringency_index FLOAT,
        population_density FLOAT,
        median_age FLOAT,
        aged_65_older FLOAT,
        aged_70_older FLOAT,
        gdp_per_capita FLOAT,
        extreme_poverty FLOAT,
        cardiovasc_death_rate FLOAT,
        diabetes_prevalence FLOAT,
        female_smokers FLOAT,
        male_smokers FLOAT,
        handwashing_facilities FLOAT,
        hospital_beds_per_thousand FLOAT,
        life_expectancy FLOAT,
        human_development_index FLOAT
    );

-- Load data from CSV
LOAD DATA
    INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\covid_vaccinations.csv' INTO
TABLE
    covid_vaccinations FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS -- Skip the header row
    (
        iso_code,
        continent,
        location,
        @date_column,
        @total_tests,
        @new_tests,
        @total_tests_per_thousand,
        @new_tests_per_thousand,
        @new_tests_smoothed,
        @new_tests_smoothed_per_thousand,
        @positive_rate,
        @tests_per_case,
        @tests_units,
        @total_vaccinations,
        @people_vaccinated,
        @people_fully_vaccinated,
        @total_boosters,
        @new_vaccinations,
        @new_vaccinations_smoothed,
        @total_vaccinations_per_hundred,
        @people_vaccinated_per_hundred,
        @people_fully_vaccinated_per_hundred,
        @total_boosters_per_hundred,
        @new_vaccinations_smoothed_per_million,
        @new_people_vaccinated_smoothed,
        @new_people_vaccinated_smoothed_per_hundred,
        @stringency_index,
        @population_density,
        @median_age,
        @aged_65_older,
        @aged_70_older,
        @gdp_per_capita,
        @extreme_poverty,
        @cardiovasc_death_rate,
        @diabetes_prevalence,
        @female_smokers,
        @male_smokers,
        @handwashing_facilities,
        @hospital_beds_per_thousand,
        @life_expectancy,
        @human_development_index
    )
SET
    `date` = STR_TO_DATE(@date_column, '%d.%m.%Y'),
    total_tests = NULLIF(REGEXP_REPLACE(@total_tests, '[^0-9]+', ''), ''),
    new_tests = NULLIF(@new_tests, ''),
    total_tests_per_thousand = NULLIF(@total_tests_per_thousand, ''),
    new_tests_per_thousand = NULLIF(@new_tests_per_thousand, ''),
    new_tests_smoothed = NULLIF(@new_tests_smoothed, ''),
    new_tests_smoothed_per_thousand = NULLIF(@new_tests_smoothed_per_thousand, ''),
    positive_rate = NULLIF(@positive_rate, ''),
    tests_per_case = NULLIF(@tests_per_case, ''),
    tests_units = NULLIF(@tests_units, ''),
    total_vaccinations = NULLIF(@total_vaccinations, ''),
    people_vaccinated = NULLIF(@people_vaccinated, ''),
    people_fully_vaccinated = NULLIF(@people_fully_vaccinated, ''),
    total_boosters = NULLIF(@total_boosters, ''),
    new_vaccinations = NULLIF(@new_vaccinations, ''),
    new_vaccinations_smoothed = NULLIF(@new_vaccinations_smoothed, ''),
    total_vaccinations_per_hundred = NULLIF(@total_vaccinations_per_hundred, ''),
    people_vaccinated_per_hundred = NULLIF(@people_vaccinated_per_hundred, ''),
    people_fully_vaccinated_per_hundred = NULLIF(@people_fully_vaccinated_per_hundred, ''),
    total_boosters_per_hundred = NULLIF(@total_boosters_per_hundred, ''),
    new_vaccinations_smoothed_per_million = NULLIF(@new_vaccinations_smoothed_per_million, ''),
    new_people_vaccinated_smoothed = NULLIF(@new_people_vaccinated_smoothed, ''),
    new_people_vaccinated_smoothed_per_hundred = NULLIF(@new_people_vaccinated_smoothed_per_hundred, ''),
    stringency_index = NULLIF(@stringency_index, ''),
    population_density = NULLIF(@population_density, ''),
    median_age = NULLIF(@median_age, ''),
    aged_65_older = NULLIF(@aged_65_older, ''),
    aged_70_older = NULLIF(@aged_70_older, ''),
    gdp_per_capita = NULLIF(@gdp_per_capita, ''),
    extreme_poverty = NULLIF(@extreme_poverty, ''),
    cardiovasc_death_rate = NULLIF(@cardiovasc_death_rate, ''),
    diabetes_prevalence = NULLIF(@diabetes_prevalence, ''),
    female_smokers = NULLIF(@female_smokers, ''),
    male_smokers = NULLIF(@male_smokers, ''),
    handwashing_facilities = NULLIF(@handwashing_facilities, ''),
    hospital_beds_per_thousand = NULLIF(@hospital_beds_per_thousand, ''),
    life_expectancy = NULLIF(@life_expectancy, ''),
    human_development_index = CASE
        WHEN TRIM(@human_development_index) REGEXP '^[0-9]*\\.?[0-9]+$' THEN TRIM(@human_development_index)
        ELSE NULL
    END;

-- " " was treated as an incorrect decimal value. Thus, I set human_development_index to NULL when it encounters non-numeric values.
---------------------------------
-- Check to see if the import was succesful, date starts at 2020-01-03
SELECT
    *
FROM
    covid_deaths;

SELECT
    *
FROM
    covid_vaccinations;

------
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

-- Looking at countries with highest infection rate compared to population
SELECT
    location,
    population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / population)) * 100 as PercentPopulationInfected
FROM
    covid_deaths
GROUP BY
    population,
    location
ORDER BY
    PercentPopulationInfected DESC;

--Show highest death count per population, by location
SELECT
    location,
    MAX(total_deaths) as TotalDeathCount
FROM
    covid_deaths
GROUP BY
    location
ORDER BY
    TotalDeathCount DESC;

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

------
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

-- Show total global data from the start of the pandemic till today
SELECT
    SUM(new_cases) as total_cases,
    SUM(new_deaths) as total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 as FatalityRate
FROM
    covid_deaths
ORDER BY
    1,
    2;

------
-- JOIN operations
SELECT
    *
FROM
    covid_deaths dea
    JOIN covid_vaccinations vac ON dea.location = vac.location
    AND dea.date = vac.date;

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

------

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
