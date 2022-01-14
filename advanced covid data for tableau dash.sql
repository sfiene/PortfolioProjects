
-- 1

select dea.continent
	, dea.location
	, dea.date
	, dea.population
	, max(vac.total_vaccinations) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac on dea.location = vac.location
						   and dea.date = vac.date
where dea.continent is not null 
group by dea.continent
		, dea.location
		, dea.date
		, dea.population
order by continent
		, dea.location
		, dea.date




-- 2

select sum(new_cases) as total_cases
	, sum(cast(new_deaths as int)) as total_deaths
	, sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from covid_deaths
--where location like '%states%'
where continent is not null 
--group by date
--order by 1,2



-- 3
-- These are not included in the above queries and want to stay consistent

select location
	, sum(cast(new_deaths as int)) as TotalDeathCount
from covid_deaths
--where location like '%states%'
where continent is null 
	and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
group by location
order by TotalDeathCount desc

-- 4
-- Just left with the income ranges

select location
	, sum(cast(new_deaths as int)) as TotalDeathCount
from covid_deaths
--where location like '%states%'
where continent is null 
	and location not in ('World', 'European Union', 'International', 'Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania')
group by location
order by TotalDeathCount desc

-- 5

select Location
	, Population
	, max(total_deaths) as highest_deaths
	, max(total_cases) as highest_infection_count
	, max((total_cases/population))*100 as percent_population_infected
	, max((total_deaths/population))*100 as percent_population_dead
from covid_deaths
--where location like '%states%'
group by Location
		, Population
order by percent_population_infected desc


select location
	, Population
	, max(total_deaths) as Highest_deaths
	, max(total_cases) as highest_infection_count
	, max((total_cases/population))*100 as percent_population_infected
	, max((total_deaths/population))*100 as percent_population_dead
from covid_deaths
--where location like '%states%'
where continent is null 
	and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
group by continent
		, location
		, Population
order by percent_population_infected desc


-- 7 


with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations
	, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac on dea.location = vac.location
							and dea.date = vac.date
where dea.continent is not null 
)
select *
	, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
from PopvsVac


-- 8 

select Location
	, Population
	, date
	, max(total_cases) as HighestInfectionCount
	, max((total_cases/population))*100 as PercentPopulationInfected
from covid_deaths
--Where location like '%states%'
group by Location
		, Population
		, date
order by PercentPopulationInfected desc