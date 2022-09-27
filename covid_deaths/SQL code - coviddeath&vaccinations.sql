Select * 
From [Portfolio Project1]..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--from [Portfolio Project1]..CovidVaccinations
--order by 3,4

--select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population 
From [Portfolio Project1]..CovidDeaths
where continent is not null
order by 1,2

--total cases vs total deaths
Select Location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project1]..CovidDeaths
where location like 'Poland' and continent is not null
order by 1,2

--total cases vs population

Select Location, date, total_cases, Population,(total_deaths/population)*100 as PercentofPopulationInfected
From [Portfolio Project1]..CovidDeaths
--where location like 'Poland'
where continent is not null
order by 1,2

--highest infection rate compare to populations

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
from [Portfolio Project1]..CovidDeaths
--where location like 'Poland'
where continent is not null
group by Location, population
order by PercentofPopulationInfected desc

--countries with highest death count per population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project1]..CovidDeaths
--where location like 'Poland'
where continent is not null
group by Location
order by TotalDeathCount desc

-- BY CONTINENT 
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project1]..CovidDeaths
--where location like 'Poland'
where continent is not null
group by continent
order by TotalDeathCount desc

--continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project1]..CovidDeaths
--where location like 'Poland'
where continent is not null
group by continent, population
order by TotalDeathCount desc

--global numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from [Portfolio Project1]..CovidDeaths
where continent is not null
--group by date
order by 1, 2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from [Portfolio Project1]..CovidDeaths
where continent is not null
--group by date
order by 1, 2

--% in country vaccinated
  --CTE
with PopvsVac1 (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio Project1]..CovidDeaths dea
join [Portfolio Project1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac1

--creating view to store data for later viz

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio Project1]..CovidDeaths dea
join [Portfolio Project1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
