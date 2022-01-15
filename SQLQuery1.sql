/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..Coviddeaths$
where continent is not null
order by 3,4


-- select data we are using
SELECT
Location,
date,
total_cases,
new_cases,
total_deaths,
population

from
PortfolioProject..Coviddeaths$

where 
continent is not null

order by 1,2


-- looking at total cases vs total deaths
-- shows the likelyhood of death if contract corona in India
Select
Location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage

From
PortfolioProject..Coviddeaths$

Where
location = 'India'

order by 1,2


--Looking at Total cases vs Population
--shows what percentage of population got covid
Select
Location,
date,
Population,
total_cases,
(total_cases/population)*100 as Percent_Population_Infected

From 
PortfolioProject..Coviddeaths$

Where
location = 'India' and 
continent is not null

order by 1,2

--Looking at countries with highest infection rate compared to population
Select
Location,
Population,
MAX(total_cases) AS Highest_Infection_Count,
MAX((total_cases/population))*100 as Percent_Population_Infected

From 
PortfolioProject..Coviddeaths$

--Where
--location = 'India'
where 
continent is not null

Group By Location,Population

order by Percent_Population_Infected DESC


--Showing highest deathcount per population
Select
Location,
MAX(cast(total_deaths as int)) as Total_Death_Count

From 
PortfolioProject..Coviddeaths$

where 
continent is not null

Group By Location

order by Total_Death_Count desc


-- let's breat things by continent
--showing the continents with big death count
Select
location,
MAX(cast(total_deaths as int)) as Total_Death_Count_Continent

From 
PortfolioProject..Coviddeaths$

where 
continent is null

Group By location

order by Total_Death_Count_Continent desc


--Global numbers
Select
SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage

From
PortfolioProject..Coviddeaths$

where continent is not null 

order by 1,2


-- Total Population vs Vaccinations
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_People_Vaccinated

From
PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null 

order by 2,3


-- Using CTE
With PopvsVac
(Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null 

)

Select *, (Rolling_People_Vaccinated/Population)*100

From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100

From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinatedd AS
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null




