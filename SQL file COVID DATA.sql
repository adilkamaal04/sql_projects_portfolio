select *
FROM [PORTFOLIO PRO1]..CovidVaccinations
WHERE continent is not null
Order by 3,4

SELECT *
FROM [PORTFOLIO PRO1]..CovidVaccinations
Order By 3,4

-- Select Data tha we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [PORTFOLIO PRO1]..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract  covid in your country
Select Location, date, total_cases,total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
From [PORTFOLIO PRO1]..CovidDeaths
Where location like '%India%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage if population got Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 AS PopulationInfection
From [PORTFOLIO PRO1]..CovidDeaths
Where location like '%India%'
Order by 1,2

-- Looking at countries with Highest Infection Rate compard to Population
Select Location, Population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
From [PORTFOLIO PRO1]..CovidDeaths
--Where location like '%India%'
Group By location, population
Order by PercentPopulationInfected DESC;





-- where continent is null

Select location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
From [PORTFOLIO PRO1]..CovidDeaths
--Where location like '%India%'
Where continent is null
Group By location
Order by TotalDeathCount DESC;

-- Let's BREAK THINGS DOWN BY CONTINENT
-- Showing continents with Highest Death count per Population

Select continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
From [PORTFOLIO PRO1]..CovidDeaths
--Where location like '%India%'
Where continent is not  null
Group By continent
Order by TotalDeathCount DESC;

-- GLOBAL NUMBERS
SELECT 
    -- date,
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths AS INT)) as total_deaths,
    CASE 
        WHEN SUM(New_Cases) = 0 THEN 0  -- Check if denominator is zero
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(New_Cases) * 100 
    END AS Deathpercentage
FROM [PORTFOLIO PRO1]..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date  
ORDER BY 1, 2;


-- VACCINATIONS

-- Looking at When India started Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [PORTFOLIO PRO1]..CovidDeaths dea
Join [PORTFOLIO PRO1]..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
AND dea.location like  'india%'
AND vac.new_vaccinations IS NOT NULL
Order by 2, 3;

-- Looking at Total Population vs Vaccinations

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	  dea.date) AS RollingPeopleVaccinated	
FROM [PORTFOLIO PRO1]..CovidDeaths dea
Join [PORTFOLIO PRO1]..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null  
-- Order by 2, 3
)

Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
      SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	  dea.date) AS RollingPeopleVaccinated	
FROM [PORTFOLIO PRO1]..CovidDeaths dea
Join [PORTFOLIO PRO1]..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date 
--WHERE dea.continent is not null 
-- Order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations



DROP VIEW if exists PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    [PORTFOLIO PRO1]..CovidDeaths dea
JOIN
    [PORTFOLIO PRO1]..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated




