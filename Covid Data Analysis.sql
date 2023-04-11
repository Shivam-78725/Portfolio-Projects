--select * 
--from [PORTFOLIO PROJECT]..CovidDeaths
--order by 3,4;

--select *
--from [PORTFOLIO PROJECT]..CovidVaccinations
--order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from [PORTFOLIO PROJECT]..CovidDeaths
order by 1,2

--Total cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from [PORTFOLIO PROJECT]..CovidDeaths
where location like '%states%'
order by 1,2 

--Looking at Total cases vs the Population
select location, date, total_cases, population, (total_cases/population) * 100 as peoplewithcovid
from [PORTFOLIO PROJECT]..CovidDeaths
where location like '%india%'
order by 1,2 

--Countries with the most highest infection rate
select location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationAffected
from [PORTFOLIO PROJECT]..CovidDeaths
--where location like '%india%'
group by location,population
order by PercentPopulationAffected desc 


--Countries with the highest death count per population
select location, Max(population) as TotalPopulation, max(cast(total_deaths as int)) as DeathsPerCountry
from [PORTFOLIO PROJECT]..CovidDeaths
where continent is not null
group by location
order by DeathsPerCountry desc

--Countries with the highest death count per population
select continent, max(cast(total_deaths as int)) as DeathsPerCountry
from [PORTFOLIO PROJECT]..CovidDeaths
where continent is not null
group by continent
order by DeathsPerCountry desc


--Breaking Global Numbers

select date, SUM(new_cases) AS New_case, SUM(cast(new_deaths as int)) as Newdeaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as PercentageOfDeaths
from [PORTFOLIO PROJECT]..CovidDeaths
where continent IS NOT NULL
GROUP BY date
order by 1,2 


--Joining two tables
--Looking at total population vs No. of people vaccinated

select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as PeopleVaccinated
from [PORTFOLIO PROJECT]..CovidDeaths dea
		join [PORTFOLIO PROJECT]..CovidVaccinations vac on
		dea.location = vac.location and
		dea.date = vac.date
		where dea.continent is not null
		order by 2,3

--Use CTE

with popvsvac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
as (
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as PeopleVaccinated
from [PORTFOLIO PROJECT]..CovidDeaths dea
		join [PORTFOLIO PROJECT]..CovidVaccinations vac on
		dea.location = vac.location and
		dea.date = vac.date
		where dea.continent is not null)
		--order by 2,3)

select *, (PeopleVaccinated/Population)*100 from  popvsvac


-- Using a Temp Table

CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as PeopleVaccinated
from [PORTFOLIO PROJECT]..CovidDeaths dea
		join [PORTFOLIO PROJECT]..CovidVaccinations vac on
		dea.location = vac.location and
		dea.date = vac.date
		where dea.continent is not null
		--order by 2,3)

		select *, (PeopleVaccinated/Population)*100 from  #PercentPeopleVaccinated


--Creating view to store data for later visulization
create view PercentPeopleVaccinated as 
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as PeopleVaccinated
from [PORTFOLIO PROJECT]..CovidDeaths dea
		join [PORTFOLIO PROJECT]..CovidVaccinations vac on
		dea.location = vac.location and
		dea.date = vac.date
		where dea.continent is not null
		--order by 2,3)