SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM PortfoliProject..CovidVaccinations
--ORDER BY 3,4

--Selecting only the data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfoliProject..CovidDeaths
ORDER BY 1,2


--Looking at total cases vs total daeths
-- SHOWS the likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases,total_deaths,  (total_deaths/total_cases)*100 AS death_percentage
FROM PortfoliProject..CovidDeaths
WHERE location LIKE '%Canada%'
ORDER BY 1,2

--Looking at the total cases vs population
--shows what percentage of population got covid
SELECT location, date,population total_cases,  (total_cases/population)*100 AS percent_infected
FROM PortfoliProject..CovidDeaths
--WHERE location LIKE '%Canada%'
ORDER BY 1,2

-- Looking at countries with highest inefction rate compared to population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfoliProject..CovidDeaths
GROUP BY location,population
--WHERE location LIKE '%Canada%'
ORDER BY PercentPopulationInfected DESC


-- Shows the countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as DeathCount
FROM PortfoliProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC

-- Lets Break thing sdown by continent
-- showing the continents with highest daeth count
SELECT continent, MAX(cast(total_deaths as int)) as DeathCount
FROM PortfoliProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC

-- GLOBAL NUMBERS
SELECT  SUM(new_cases) As TotalDeaths,SUM(cast(new_deaths as int)) AS TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS percentDeath
FROM PortfoliProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%Canada%'
--GROUP BY date
ORDER BY 1,2
-- GROUPED BY DATE
SELECT  date, SUM(new_cases) As TotalDeaths,SUM(cast(new_deaths as int)) AS TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS percentDeath
FROM PortfoliProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%Canada%'
GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccintion
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- use CTE

WITH PopvsVac (continent, location, date, population, NewVaccinations, RollingPeopleVaccinated)
as
(
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
--ORDER BY 2,3
SELECT *,(RollingPeopleVaccinated/Population)*100 FROM PopvsVac


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccianted numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccianted/Population)*100 FROM #PercentPopulationVaccinated


-- Creating View to store data forlater vizualizations

CREATE VIEW PercentPopulationvaccinated
AS
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationvaccinated