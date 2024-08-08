select * from CovidDeaths where continent is not null

-- Total Cases vs Death
-- Shows likelihood of dying from covid in your country until 2021.

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from CovidDeaths 
where location like '%india%' and continent is not null
order by 1,2

-- Total cases vs Population of a country
-- Shows percentage of population affected by Covid

select location, date, total_cases, population, (total_cases/population)*100 as CasesPerPopulation
from CovidDeaths 
where location like '%states%'
order by 1,2

-- Countries with the highest Covid rate per Population

select location, population, max(total_cases) as MaxCasesRecorded, max((total_cases/population)*100) as InfectionRateByCountry
from CovidDeaths 
group by location, population
order by 4
DESC

-- Countries with the highest Death Count per Population

select location, max(cast(total_deaths as int)) as MaxDeathsRecorded
from CovidDeaths 
where continent is not null
group by location
order by MaxDeathsRecorded
DESC


-- Breakdown by Continent

select continent, max(cast(total_deaths as int)) as MaxDeathsRecorded
from CovidDeaths 
where continent is not null
group by continent
order by MaxDeathsRecorded
DESC


-- Global Numbers

select date, sum(new_cases) as NewCovidCases, sum(cast(new_deaths as int)) as NewCovidDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths 
where continent is not null
group by date
order by 1,2


select * from CovidVaccinations

-- Total population of the world vaccinated

-- Rolling people vaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select location, date, new_cases, sum(new_cases) 
over( partition by location order by location,date )as NewCasesbyCountry 
from CovidDeaths;


-- Using CTE

with PopvsVac ( Continent, Location, date, Population, New_Vaccinatons, RollingPeopleVaccinated)
as 
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

)
-- Percentage of population vaccinated
select *,(RollingPeopleVaccinated/population)*100 as 'Rolling % of People vaccinated'
from
PopvsVac


-- Views for visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

