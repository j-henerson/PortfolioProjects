Use Portfolio;
Select *
From covid_deaths
Where continent is not null
Order By 3,4
--Select *
--From covid_vaccinations
--Order By 3,4
--Select data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From covid_deaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying from COVID-19 based on confirmed infections in the United States 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As case_fatality_rate
From covid_deaths
Where location like '%States%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of U.S. population has had a confirmed COVID-19 infection
Select location, date, total_cases, population, (total_cases/population)*100 As percent_infected
From covid_deaths
Where location like '%States%'
Order By 1,2

-- Looking at countries with highest confirmed COVID-19 infection rate compared to population
Select location,  MAX(total_cases) As highest_infection_count, population, MAX(total_cases/population)*100 As percent_infected
From covid_deaths
Group By location, population
Order By percent_infected Desc

-- Looking at countries with highest COVID-19 associated deaths
Select location,  MAX(Cast(total_deaths As int)) As total_death_count
From covid_deaths
Where continent is not null
Group By location
Order By total_death_count Desc

-- Looking at continents with highest COVID-19 associated deaths
Select location,  MAX(Cast(total_deaths As int)) As total_death_count
From covid_deaths
Where continent is null And location not like '%income%'
Group By location
Order By total_death_count Desc

-- Global Numbers
Select SUM(new_cases) As global_cases, SUM(Cast(new_deaths As int)) As global_deaths, SUM(Cast(new_deaths As int))/SUM(new_cases)*100 As case_fatality_rate
From covid_deaths
Where continent is not null

-- Total Population vs Vaccinations
-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinatons, rolling_people_vaccinated) As (
Select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(Cast(cv.new_vaccinations As float)) Over (Partition By cd.location Order By cd.location,cd.date) As rolling_people_vaccinated
From covid_deaths cd
Join covid_vaccinations cv
On cd.location = cv.location And cd.date = cv.date
Where cd.continent is not null
)
Select *, rolling_people_vaccinated/population*100 As percent_vaccinated
From PopvsVac

-- Use Temp Table
Drop Table if exists #PercentPopulationVaccinated --resets the table 
Create Table #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255), 
	Date datetime, 
	Population numeric,
	New_Vaccinations numeric, 
	Rolling_People_Vaccinated numeric, 
	)
Insert Into #PercentPopulationVaccinated
Select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(Cast(cv.new_vaccinations As float)) Over (Partition By cd.location Order By cd.location,cd.date) As rolling_people_vaccinated
From covid_deaths cd
Join covid_vaccinations cv
On cd.location = cv.location And cd.date = cv.date
Where cd.continent is not null

Select *, rolling_people_vaccinated/population*100 As percent_vaccinated
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated As 
Select 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(Cast(cv.new_vaccinations As float)) Over (Partition By cd.location Order By cd.location,cd.date) As rolling_people_vaccinated
From covid_deaths cd
Join covid_vaccinations cv
On cd.location = cv.location And cd.date = cv.date
Where cd.continent is not null

Create View PercentPopulationInfected As
Select location,  MAX(total_cases) As highest_infection_count, population, MAX(total_cases/population)*100 As percent_infected
From covid_deaths
Group By location, population
--Order By percent_infected Desc
