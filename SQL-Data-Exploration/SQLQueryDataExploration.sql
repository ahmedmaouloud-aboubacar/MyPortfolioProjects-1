----------------------------------------------
--------  Retrieving Data from Tables  -------
----------------------------------------------
--Select all data from the CovidDeaths table
SELECT * FROM PortfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL
ORDER BY 1,2

--Select all data from the CovidVaccinations table
SELECT * FROM PortfolioProject..CovidVaccinations$ 
WHERE continent IS NOT NULL
ORDER BY 1,2

	---------------------------------------------------
	-------- Analyzing COVID Cases and Deaths ---------
	---------------------------------------------------
--Select Data that we are going to use from the CovidDeaths table
SELECT location,Date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,6

-- Looking at Total Cases vs Total Deaths In Mauritania
SELECT location,Date, total_cases,total_deaths,(convert(float ,total_deaths)/ convert(float ,total_cases) )*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE total_deaths >= total_cases  AND location like '%auritan%'   
ORDER BY 1,2 
-- Shows what percentage of population got Covid
SELECT location,Date, total_cases, population,(total_cases/population)*100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths$ 
WHERE total_cases IS NOT NULL-- AND location like '%aurita%'  
ORDER BY 1,2 

-- Looking at The countries With Highest Infection Rate Compared To Population
SELECT location, MAX(total_cases) as HighestIfectionCount,Max((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$ 
WHERE total_cases IS NOT NULL AND population IS NOT NULL --AND date<'2021-06-15'
Group By location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at The countries With Highest Death Rate Compared To Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL
Group By location, population
ORDER BY TotalDeathCount DESC

--Lets Bring thing Down By Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount --,Max((total_deaths/population)*100) as PercentPopulationDeaths
FROM PortfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL
Group By continent
ORDER BY TotalDeathCount DESC
--Lets Bring thing Down By Continent
--Showing  The continents With the Highest DeathCount
SELECT continent, SUM(cast(new_cases as int)) as TotalDeathCount --,Max((total_deaths/population)*100) as PercentPopulationDeaths
FROM PortfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL
Group By continent
ORDER BY TotalDeathCount DESC

--GLOBAL Numbers
SELECT date,SUM(new_cases) AS TotalPopulationInfected
		   ,SUM(cast(new_deaths as int)) as TotalPopulationDeath
		   ,SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL AND new_cases !=0
ORDER BY 1,2 DESC


		----------------------------------------
		-------- Analyzing Vaccinations --------
		----------------------------------------
	
--Looking At Total Population Vs Vaccinations 
-- 1) Using Common Table Expression (CTE)
WITH PopvsVac (Continent,location,Date,Population,new_vaccinations,RollingPeopleVacinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(convert(float,vac.new_vaccinations)) OVER (PARTITION BY  dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVacinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , RollingPeopleVacinated/Population*100 FROM PopvsVac

-- 2) Using Temporary Table
DROP TABLE IF EXISTS #PourcentPopulationVaccinated
CREATE TABLE #PourcentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVacinated numeric
);

INSERT INTO #PourcentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(convert(float,vac.new_vaccinations)) OVER (PARTITION BY  dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVacinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
 SELECT *  FROM #PourcentPopulationVaccinated

-- Creating a View to store data for later visualization
DROP VIEW IF EXISTS PourcentPopulationVaccinated
CREATE VIEW PourcentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(convert(float,vac.new_vaccinations)) OVER (PARTITION BY  dea.location
		ORDER BY dea.location, dea.date) as RollingPeopleVacinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PourcentPopulationVaccinated


 
