-- Queries for Tableau visualization

-- 1. Select the sum of all cases, deaths and the fatality rate
SELECT
    SUM(new_cases) as total_cases,
    SUM(new_deaths) as total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 as FatalityRate
FROM
    covid_deaths
ORDER BY
    1,
    2;

-- 2. Select the sum of all deaths by continent
Select
    location,
    SUM(new_deaths) as TotalDeathCount
From
    covid_deaths
Where
    continent like "" and
    location not in ('World', 'European Union', 'International') AND
    location not like "%income"
Group by
    location
order by
    TotalDeathCount desc;

-- 3. Select all countries, their population, the highest infection rate and ratio of the population that contracted covid in the past.
Select
    location,
    population,
    MAX(total_cases) as HighestInfectionCount,
    Max((total_cases / population)) * 100 as PercentPopulationInfected
From
    covid_deaths 
Group by
    location,
    population
order by
    PercentPopulationInfected desc;

-- 4. Select all countries, their population, the daily infection count and the ratio of the population that contracted covid in the past.
Select
    location,
    population,
    date,
    MAX(total_cases) as HighestInfectionCount,
    Max((total_cases / population)) * 100 as PercentPopulationInfected
From
    covid_deaths 
Group by
    location,
    population,
    date
order by
    PercentPopulationInfected desc;