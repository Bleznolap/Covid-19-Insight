Select *
From Portfolio_Project..CovidDeaths$
Where continent is not null
order by 3,4

Select *
From Portfolio_Project..CovidVaccination$
order by 3,4

-- Selected variables 

Select Location, Date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths$
order by 1,2

-- Calculating Total Cases vs Total Death
-- Chances of dying if infected
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths$
Where location like 'Africa%'
order by 1,2

--Comparing Total cases with Population
--Percentage Population infected with Covid
Select Location, Date, Population, total_cases, (total_cases/population)*100 as PopulationPercentage
From Portfolio_Project..CovidDeaths$
order by 1,2

--Showing Comparison of Countries with highest infection rate with Population
Select Location, Population, Max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
From Portfolio_Project..CovidDeaths$
Group by Location, Population
order by PercentagePopulationInfected DESC

--Countries with Highest Death Count by Population
Select Location, population, MAX(cast(total_deaths as int))as TotalDeathCount
From Portfolio_Project..CovidDeaths$
Where continent is not null
Group by Location, Population
order by TotalDeathCount desc

--QUERYING BY CONTINENT
--Continent with Highest Death Count by Population
Select continent, MAX(cast(total_deaths as int))as TotalDeathCount
From Portfolio_Project..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL DETAILS
--Global cases, death, and death percentage By date
Select Date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
From Portfolio_Project..CovidDeaths$
Where continent is not null
Group by date
order by 1,2

--Total Global cases, death, and death percentage
Select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
From Portfolio_Project..CovidDeaths$
Where continent is not null
order by 1,2

--Showing Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date)
as CummulativePeopleVaccinated
From Portfolio_Project..CovidDeaths$ dea
Join Portfolio_Project..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Using Common Table Expression (CTE)
With PopVac (continent, location, Date,  Population, new_Vaccinations, CummulativePeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date)
as CummulativePeopleVaccinated
From Portfolio_Project..CovidDeaths$ dea
Join Portfolio_Project..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (CummulativePeopleVaccinated/Population)*100
From PopVac

--Using Temporary (TEMP) TABLE to perform former query with CTE
DROP TABLE if EXISTS #PercentPopVaccinated
Create table #PercentPopVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CummulativePeopleVaccinated numeric
)

Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date)
as CummulativePeopleVaccinated
From Portfolio_Project..CovidDeaths$ dea
Join Portfolio_Project..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (CummulativePeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
From #PercentPopVaccinated


--Creating View for Viz

Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date)
as CummulativePeopleVaccinated
From Portfolio_Project..CovidDeaths$ dea
Join Portfolio_Project..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
FROM PercentPopVaccinated




