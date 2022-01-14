



-- 1. 

select sum(new_cases) as total_cases
	, sum(cast(new_deaths as int)) as total_deaths
	, sum(cast(new_deaths as int))/sum(New_Cases)*100 as death_percentage
From covid_deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- 2. 

-- These are not included in the above queries and want to stay consistent

select location 
	, sum(cast(new_deaths as int)) as total_death_count
from covid_deaths
--Where location like '%states%'
where continent is null 
	and location not in ('World', 'European Union', 'International', 'Upper middle income',
					 'Lower middle income', 'High income', 'Low income')
group by location
order by total_death_count desc


-- 3.

select Location
	, Population
	, max(total_cases) as highest_infection_count
	, max((total_cases/population))*100 as percent_population_infected
from covid_deaths
--Where location like '%states%'
group by Location
	, Population
order by percent_population_infected desc


-- 4.


Select Location
	, Population
	, date
	, max(total_cases) as highest_infection_count
	, max((total_cases/population))*100 as percent_population_infected
From covid_deaths
--Where location like '%states%'
Group by Location
	, Population
	, date
order by percent_population_infected desc












