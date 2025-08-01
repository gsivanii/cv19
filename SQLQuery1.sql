-- SELECTING DATA WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject..CovidDeaths_og
WHERE continent is NOT NULL
ORDER BY 1,2

--TOTAL CASES vs TOTAL DEATHS in my Country

SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS FLOAT) *100/ total_cases AS death_rate
FROM Portfolioproject..CovidDeaths_og
WHERE location like 'india' and continent is NOT NULL
ORDER BY 1,2

--TOTAL CASES vs POPULATION in my Country

SELECT location, date, total_cases, population,total_cases *100/ population AS death_rate
FROM Portfolioproject..CovidDeaths_og
WHERE location like 'india' and continent is NOT NULL
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, CAST(MAX(total_cases) AS FLOAT) *100/ NULLIF(population,0) AS PercentagePopulationInfected
FROM Portfolioproject..CovidDeaths_og
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--Countries with Highest Death count per Population

SELECT location, CAST(MAX(total_deaths) AS INT) as Deathcount
FROM Portfolioproject..CovidDeaths_og
WHERE continent is NOT NULL
GROUP BY location
ORDER BY Deathcount DESC

--BREAKING THINGS DOWN BY CONTINENT

--Continents with highest death count per population

SELECT continent, CAST(MAX(total_deaths) AS INT) as Deathcount
FROM Portfolioproject..CovidDeaths_og
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Deathcount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS totalCases, SUM(new_deaths) AS TotalDeaths,SUM(CAST(new_deaths AS FLOAT)) /SUM(CAST(new_cases AS FLOAT))*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths_og
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2

--VACCINATIONS

SELECT * FROM Portfolioproject..CovidVaccinations_og1

--JOIN

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS totalVaccination
FROM Portfolioproject..CovidDeaths_og dea
JOIN Portfolioproject..CovidVaccinations_og1 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS totalVaccination
FROM Portfolioproject..CovidDeaths_og dea
JOIN Portfolioproject..CovidVaccinations_og1 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Datee datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS totalVaccination
FROM Portfolioproject..CovidDeaths_og dea
JOIN Portfolioproject..CovidVaccinations_og1 vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM #PercentagePopulationVaccinated


--CREATE VIEW


CREATE VIEW PercentPopulationVaccinated AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS totalVaccination
FROM Portfolioproject..CovidDeaths_og dea
JOIN Portfolioproject..CovidVaccinations_og1 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT name 
FROM sys.views 
WHERE name = 'PercentPopulationVaccinated';

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME = 'PercentPopulationVaccinated';



SELECT * FROM PercentPopulationVaccinated

DROP VIEW IF EXISTS PercentPopulationVaccinated