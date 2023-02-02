SELECT * FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2


SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Group by location, Population
order by PercentPopulationInfected desc

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
Order By TotalDeathCount desc

SELECT SUM(new_cases) as toal_cases, SUM(cast(new_deaths as int)) as tota_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--GROUP BY date
order by 1,2

-- POPULATION VS VACCINATION
SELECT death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
FROM PortfolioProject..CovidDeaths$ AS death
Join PortfolioProject..CovidVaccinations$  vaccination
	ON death.location = vaccination.location
	and death.date = vaccination.date
	WHERE death.continent is not null
ORDER BY 1,2,3


-- USE CTE

With popVSvac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, SUM(CONVERT(INT, vaccination.new_vaccinations)) OVER (Partition By death.location Order by death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS death
Join PortfolioProject..CovidVaccinations$  vaccination
	ON death.location = vaccination.location
	and death.date = vaccination.date
	WHERE death.continent is not null
--ORDER BY 1,2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM popVSvac


-- USE TEMP 

DROP TABLE IF exists #PercentPopulationVaccinatinated
CREATE TABLE #PercentPopulationVaccinatinated
(
Continent nvarchar (200),
Location nvarchar (200),
Date datetime,
Population numeric, 
New_vaccination numeric,
RollingPeopleVaccinated numeric, 
)

INSERT INTO #PercentPopulationVaccinatinated
SELECT death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, SUM(CONVERT(INT, vaccination.new_vaccinations)) OVER (Partition By death.location Order by death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS death
Join PortfolioProject..CovidVaccinations$  vaccination
	ON death.location = vaccination.location
	and death.date = vaccination.date
	WHERE death.continent is not null
--ORDER BY 1,2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinatinated


-- CREATING VIEW TO STORE DATA VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinatinated as 
SELECT death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, SUM(CONVERT(INT, vaccination.new_vaccinations)) OVER (Partition By death.location Order by death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS death
Join PortfolioProject..CovidVaccinations$  vaccination
	ON death.location = vaccination.location
	and death.date = vaccination.date
	WHERE death.continent is not null
	--ORDER BY 1,2,3