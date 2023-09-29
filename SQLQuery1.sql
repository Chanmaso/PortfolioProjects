
select * 
from portfolioproject..CovidDeaths
where continent is not null
order by 3,4;

--select * 
--from portfolioproject..covidvaccinations
--order by 3,4;


select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
order by 1,2;

--total cases vs total deaths
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (cast(total_deaths as int)/total_cases) deathpercentage
FROM
    portfolioproject..CovidDeaths
ORDER BY
    1, 2;

	--total cases vs population

SELECT
    location,
    date,
    total_cases,
    population, (total_cases/population)*100 as infectedpercentage
from portfolioproject..CovidDeaths
--where location like '%india%'
order by 1,2;



--Countries with highest infection rate wrt population

SELECT
    location,
	population,
    max(total_cases) highest_Infected_count,
	max((total_cases/population))*100 infectedpercentage 
from portfolioproject..CovidDeaths
group by location, population
order by infectedpercentage desc;


--highest covid death/country
SELECT
    location,
	max(cast(total_deaths as int)) total_death_count
from portfolioproject..CovidDeaths
where continent is not null
group by location
order by total_death_count desc;


-- CONTINENT DEATH COUNT
SELECT
    continent,
	max(cast(total_deaths as int)) total_death_count
from portfolioproject..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc;


--GLOBAL NUMBERS
SELECT
    date,
    SUM(new_cases) AS totalcases,
    SUM(CAST(new_deaths AS INT)) AS totaldeaths,
    CASE
        WHEN SUM(new_cases) > 0
        THEN (SUM(CAST(new_deaths AS INT)) * 100.0) / SUM(new_cases)
        ELSE 0  -- Handle cases where new_cases is zero to avoid divide by zero error
    END AS DeathsPercentage
FROM
    portfolioproject..CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    DeathsPercentage DESC;


SELECT
    SUM(new_cases) AS totalcases,
    SUM(CAST(new_deaths AS INT)) AS totaldeaths,
    CASE
        WHEN SUM(new_cases) > 0
        THEN (SUM(CAST(new_deaths AS INT)) * 100.0) / SUM(new_cases)
        ELSE 0  -- Handle cases where new_cases is zero to avoid divide by zero error
    END AS DeathsPercentage
FROM
    portfolioproject..CovidDeaths
WHERE
    continent IS NOT NULL
--GROUP BY
--    date
ORDER BY
    DeathsPercentage DESC;


--Population vs vaccinations

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as rolling_people_vaccinated
FROM
    CovidDeaths dea
JOIN
    covidvaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.location,
    dea.date;


--CTE

with popvsvac (continent, location, date, population, new_vaccination, rolling_people_vaccinated)
as
(
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as rolling_people_vaccinated
FROM
    CovidDeaths dea
JOIN
    covidvaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
	)
select *, (rolling_people_vaccinated/population)*100
from popvsvac



--Temporary table


drop table if exists #percentpopulationvaccinated

CREATE TABLE #percentpopulationvaccinated
(
    Continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_people_vaccinated NUMERIC
)

INSERT INTO #percentpopulationvaccinated
SELECT
    dea.Continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM
    CovidDeaths dea
JOIN
    covidvaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date

SELECT *, (rolling_people_vaccinated / population) * 100
FROM #percentpopulationvaccinated


create view percentpopulationvaccinated as 
SELECT
    dea.Continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM
    CovidDeaths dea
JOIN
    covidvaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
where dea.continent is not null


select *
from percentpopulationvaccinated