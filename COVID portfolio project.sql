SELECT *
FROM CovidDeaths
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at total cases vs Population
--Shows percentage of population that got COVID

SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS Infection_Percentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Countires with highest infection rate

SELECT Location,population,MAX(total_cases), MAX (total_cases/population) * 100 AS Infection_Percentage
FROM CovidDeaths
GROUP BY location,population
ORDER BY 2 DESC

--Showing Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Showing continents with highest death count

SELECT continent, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int)) / SUM(new_cases) *100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3 DESC

--Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVacinnatedPeople
FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 


-- Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinatedPeople)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVacinnatedPeople
FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)

SELECT *, (RollingVaccinatedPeople/population)*100 
FROM PopvsVac

-- TEMP Table

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingVaccinatedPeople numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVacinnatedPeople
FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingVaccinatedPeople/population)*100 
FROM #PercentPopulationVaccinated
ORDER BY 2,3

-- Creating VIEW for Dataviz

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVacinnatedPeople
FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
