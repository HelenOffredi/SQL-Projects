/* 

Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--SELECT *
--FROM Coviddeaths$
--ORDER BY 3,4

--SELECT *
--FROM covidvaccinations$
--ORDER BY 3,4;

--Select key data to analyse

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM Coviddeaths$
ORDER BY location, date;

--Looking at total cases vs total deaths
--Shows likelihood of dying if you catch covid split by country/date

SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As death_perc
FROM Coviddeaths$
ORDER BY location, date;

--Shows likelihood of dying if you catch covid in the UK

SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As death_perc
FROM Coviddeaths$
WHERE location LIKE '%kingdom%'
ORDER BY location, date;

--Looking at total cases v population
--Shows what % of population got covid

SELECT continent, location, date, total_cases, population, (total_cases/population)*100 AS perc_pop_had_covid
FROM Coviddeaths$
ORDER BY location, date;

--Looking at countries with highest infection rate compared to population

SELECT continent, location,  population, MAX(total_cases) AS highest_infection_count, ROUND(MAX((total_cases/population))*100,2) AS perc_pop_infected
FROM Coviddeaths$
GROUP BY continent, location, population
ORDER BY perc_pop_infected DESC;

--Showing countries with highest death count & % death count per population

SELECT continent, location,  population, MAX(total_deaths) AS highest_death_count, ROUND(MAX((total_deaths/population))*100,2) AS perc_deaths
FROM Coviddeaths$
GROUP BY continent, location, population
ORDER BY highest_death_count DESC;

--Summarise by Continent
--Showing continents with highest death count & death rate % per population

SELECT continent, SUM(new_deaths) AS ttl_death_count, ROUND(SUM((new_deaths/population))*100,2) AS perc_deaths
FROM Coviddeaths$
GROUP BY continent
ORDER BY ttl_death_count DESC;

--Global numbers
--Create CTE for global population

WITH globalpop AS (SELECT location, SUM(new_cases) AS ttl_cases, SUM(new_deaths) AS ttl_deaths, MAX(population) AS ttl_pop
					FROM Coviddeaths$
					GROUP BY location)

SELECT SUM(ttl_cases) AS global_cases, SUM(ttl_deaths) AS global_deaths, SUM(ttl_pop) AS global_pop
FROM globalpop;


--Join Covid deaths & covid vaccinations
--Join on location & date
--Select new vaccinations by date and running total


SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.date) AS running_ttl
FROM Coviddeaths$ AS D
JOIN covidvaccinations$ AS V
ON D.location=V.location AND D.date=V.date
ORDER BY 2,3;

--Use CTE
--Add % of population that have been vaccinated

WITH percpopvac AS (SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.date) AS running_ttl
					FROM Coviddeaths$ AS D
					JOIN covidvaccinations$ AS V
					ON D.location=V.location AND D.date=V.date)

SELECT *, running_ttl/percpopvac.population
FROM percpopvac;

--TEMP Table

DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated (continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, running_ttl numeric)

INSERT INTO #percentpopulationvaccinated 
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.date) AS running_ttl
FROM Coviddeaths$ AS D
JOIN covidvaccinations$ AS V
ON D.location=V.location AND D.date=V.date

SELECT *, (running_ttl/population)*100
FROM #percentpopulationvaccinated;


--Creating view to store data for later visualisations

CREATE VIEW percentpopulationvaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.date) AS running_ttl
FROM Coviddeaths$ AS D
JOIN covidvaccinations$ AS V
ON D.location=V.location AND D.date=V.date;




























