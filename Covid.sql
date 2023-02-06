-- KUDOS to https://www.youtube.com/@AlexTheAnalyst

Select * FROM PortfolioProject..CovidDeath$
WHERE continent is not null
order by 3,4

--Select * FROM PortfolioProject..CovidVaccination$
--order by 3, 4

--Select Data that we are going to be using

Select Location, date, total_cases, total_deaths, population 
FROM PortfolioProject..CovidDeath$
order by 1, 2

--Looking at Total Caes vs Total Deaths
--Shows likelihood of dying if infected by Covid
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath$
Where location = 'Malaysia'
order by 1, 2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeath$
--WHERE location = 'Malaysia'
order by 1, 2


--Looking at Countries with highest infection rate compared to population
Select Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
FROM PortfolioProject..CovidDeath$
--WHERE location = 'Malaysia'
GROUP by Location, population, date
order by InfectionPercentage DESC


--SHowing countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
--WHERE location = 'Malaysia'
WHERE continent is not null
GROUP by Location
order by TotalDeathCount DESC


--Let break things down by continent
--Showing continent with the highest death count
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
--WHERE location = 'Malaysia'
WHERE continent is not null
GROUP by continent
order by TotalDeathCount DESC

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath$
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2 

-- Global Number v2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
WHERE continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount desc

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated, 
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
