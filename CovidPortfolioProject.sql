/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

use PortfolioProject;

Select *
From PortfolioProject..CovidDeath
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
Where continent is not null 
order by 1,2

---------------------------------------------------------------------------------------
-- Total Cases vs Total Deaths -------------------------------------------------------
-- Shows likelihood of dying if you contract covid in your country --------------------
----------------------------------------------------------------------------------------

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where location like '%states%'
and continent is not null 
order by 1,2

---------------------------------------------------------------------------------------------------
---Total Number of Deaths per million people for each location-------------------------------------
---------------------------------------------------------------------------------------------------

SELECT 
    location,
    SUM(convert(int,total_deaths)) / (SUM(population) / 1000000) AS deaths_per_million
FROM 
    PortfolioProject..CovidDeath
WHERE 
     continent IS NOT NULL
GROUP BY 
    location;

------------------------------------------------------------------------------------------
-- Total Cases vs Population--------------------------------------------------------------
-- Shows what percentage of population infected with Covid--------------------------------
------------------------------------------------------------------------------------------
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  ROUND(Max((total_cases/population))*100,2) as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-----GLOBAL NUMBERS ---------------------------

Select   sum(new_cases) as total_NEW_cases , SUM(cast(new_deaths as int)) as total_deaths , ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is not null 
-- group by date
order by 1,2;

-----------------------------------------------------------------------------------------
---------------------TOTAL POPULATION VS VACCINATION-------------------------------------
-----------------------------------------------------------------------------------------


Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(INT,CV.New_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION , CD.DATE) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeath AS CD
JOIN PortfolioProject..CovidVaccination AS CV
	ON CD.location =CV.location 
	AND CD.date = CV.date
Where CD.continent is not null 
ORDER BY 2,3;


--USING CTE---

WITH POPVSVAC(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(INT,CV.New_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION , CD.DATE) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeath AS CD
JOIN PortfolioProject..CovidVaccination AS CV
	ON CD.location =CV.location 
	AND CD.date = CV.date
Where CD.continent is not null 

)
SELECT * ,(RollingPeopleVaccinated/population)*100
FROM POPVSVAC
ORDER BY 2,3
;

-----TEMP TABLE

DROP TABLE IF EXISTS #PERCENTAGE_POPULAION_VACCINATED
CREATE TABLE #PERCENTAGE_POPULAION_VACCINATED
(
Continent NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATION NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PERCENTAGE_POPULAION_VACCINATED
Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(INT,CV.New_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION , CD.DATE) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeath AS CD
JOIN PortfolioProject..CovidVaccination AS CV
	ON CD.location =CV.location 
	AND CD.date = CV.date
--Where CD.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 AS PER_PEOPLE_VACCINATED
From #PERCENTAGE_POPULAION_VACCINATED;


--CREATING VIEW TO STORE DATA FOR VISUALIZATION------------------------------------------------


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;


CREATE VIEW TOTAL_DEATH_COUNT
AS
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
Where continent is not null 
Group by continent
;

CREATE VIEW Death_Count_by_population
AS
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by Location
;

CREATE VIEW deaths_per_million
AS 
SELECT 
    location,
    SUM(convert(int,total_deaths)) / (SUM(population) / 1000000) AS deaths_per_million
FROM 
    PortfolioProject..CovidDeath
WHERE 
     continent IS NOT NULL
GROUP BY 
    location;


CREATE VIEW PercentPopulationInfected
AS 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  ROUND(Max((total_cases/population))*100,2) as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%states%'
Group by Location, Population;

CREATE VIEW TotalDeathCount
AS
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
Where continent is not null 
Group by Location;









select * from PercentPopulationVaccinated;