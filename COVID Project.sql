SELECT *
FROM [Portfolio Project  COVID]..CovidDeaths
Where continent is not null
Order by 3,4

--SELECT *
--FROM [Portfolio Project  COVID]..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using
SELECT Location, date, total_cases, New_cases, total_deaths,population
FROM [Portfolio Project  COVID]..CovidDeaths
Where continent is not null
Order by 1, 2

--Looking at Total Cases vs Total Deaths
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project  COVID]..CovidDeaths
WHERE location like '%states%'
Order by 1, 2

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project  COVID]..CovidDeaths
WHERE location like '%kingdom%'
Order by 1, 2

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project  COVID]..CovidDeaths
WHERE location like '%zealand%'
Order by 1, 2

-- Looking at the Total Cases vs Population
-- Here, it shows what percentage of the U.S. population contracted COVID

SELECT Location, date, Population, total_cases, (total_cases/population)*100 as 'Contracted Percentage'
FROM [Portfolio Project  COVID]..CovidDeaths
WHERE location like '%states%'
Order by 1, 2
 
 --Countries With Highest infection Rate Compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 'PercentPopulationInfected'
FROM [Portfolio Project  COVID]..CovidDeaths
--WHERE location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc

-- Countries With The Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project  COVID]..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT


--Showing Continents with highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project  COVID]..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project  COVID]..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by date
Order by 1, 2

--TOTAL GLOBAL CASES
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project  COVID]..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
--Group by date
Order by 1, 2


--Looking at Total Population vs Vaccinations (total amount of people in the world that have been vaccinated)

Select *
FROM [Portfolio Project  COVID]..CovidDeaths dea
join [Portfolio Project  COVID]..CovidVaccinations vac
	on dea.location = vac. location 
	and dea.date = vac. date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project  COVID]..CovidDeaths dea
join [Portfolio Project  COVID]..CovidVaccinations vac
	on dea.location = vac. location 
	and dea.date = vac. date
Where dea.continent is not null
Order by 2, 3

--ROLLING COUNT
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location 
 Order by dea.location, dea.date) as RollingPeopleVaccinated
 (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project  COVID]..CovidDeaths dea
join [Portfolio Project  COVID]..CovidVaccinations vac
	On dea.location = vac. location 
	and dea.date = vac. date
Where dea.continent is not null
Order by 2, 3



--USE CTE


With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project  COVID]..CovidDeaths dea
join [Portfolio Project  COVID]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project  COVID]..CovidDeaths dea
join [Portfolio Project  COVID]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Drop Table 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project  COVID]..CovidDeaths dea
join [Portfolio Project  COVID]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to Store Data for later visualizations
Create View PopulationVaccinatedPercentage AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project  COVID]..CovidDeaths dea
join [Portfolio Project  COVID]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Create View PercentageofVaccinatedPopulation as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project  COVID]..CovidDeaths dea
join [Portfolio Project  COVID]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
