select *
from covid_deaths
where continent is not null
order by 3, 4

select *
from covid_vaccinations
order by 3, 4

-- Select data that we are going to be using

select location
	, total_cases
	, new_cases
	, total_deaths
	, population
from covid_deaths
order by 1, 2

-- Looking at Total Cases vs. Total Deaths

select location
	, date
	, total_cases
	, total_deaths
	, (total_deaths / total_cases) * 100 as death_percentage
from covid_deaths
where location like '%states%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location
	, date
	, total_cases
	, population
	, (total_cases / population) * 100 as got_covid_percentage
from covid_deaths
where location like '%states%'
order by 1, 2

-- Looking at what countries has highest infection rates

select location
	, max(total_cases) as highest_infection
	, population
	, max((total_cases / population)) * 100 as pop_infectec_percentage
from covid_deaths
group by location
	, population
order by pop_infectec_percentage desc

-- Showing countries with highest death count per population

select location
	, max(cast(total_deaths as int)) as total_deaths
from covid_deaths
where continent is not null
group by location
order by total_deaths desc

-- Breaking things out by continent
select location
	, max(cast(total_deaths as int)) as total_deaths
from covid_deaths
where continent is null
group by location
order by total_deaths desc

-- Global numbers

select date
	, sum(new_cases) as total_cases
	, sum(cast(new_deaths as int)) as total_deaths
	, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as death_percentage
from covid_deaths
where continent is not null
group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations

select dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations_smoothed
	, sum(cast(vac.new_vaccinations_smoothed as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from covid_deaths dea
join covid_vaccinations vac on dea.location = vac.location
							and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Use CTE

with popvsvac (continent, location, date, population, new_vaccinations_smoothed, RollingPeopleVaccinated)
as
(
select dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations_smoothed
	, sum(cast(vac.new_vaccinations_smoothed as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from covid_deaths dea
join covid_vaccinations vac on dea.location = vac.location
							and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *
	, (rolling_people_vaccinated / population) * 100
from popvsvac
order by 1,2

-- Temp Table

drop table if exists #percent_population_vaccinated

create table #percent_population_vaccinated (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations_smoothed numeric,
	RollingPeopleVaccinated numeric
)

insert into #percent_population_vaccinated
select dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations_smoothed
	, sum(cast(vac.new_vaccinations_smoothed as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from covid_deaths dea
join covid_vaccinations vac on dea.location = vac.location
							and dea.date = vac.date
where dea.continent is not null

-- Views

create view percent_population_vaccinated as
select dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations_smoothed
	, sum(cast(vac.new_vaccinations_smoothed as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from covid_deaths dea
join covid_vaccinations vac on dea.location = vac.location
							and dea.date = vac.date
where dea.continent is not null
