Select * 
From Coviddeaths
Order by 3,4

Select * 
From CovidVaccinations
Order by 3,4
--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population 
From Coviddeaths
Order by 1,2

--Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying if u contract covid in your own country
select location, date, total_cases, total_deaths, cast(total_deaths as float)/ cast(total_cases as float)*100 AS DeathPercent
from Coviddeaths
WHERE location like 'india'
Order by 1,2

--Looking at Total Cases vs. Population
--Shows what percentage of population got covid
select location, date, total_cases, population, cast(cast(total_cases as float)/ cast(population as float)*100 AS int) AS PercentPopinfected
from Coviddeaths
WHERE location= 'India'
Order by 1,2
--In the above, if u dont use big int, ur answers will be in scientific notation, for smaller cases

--Looking at countries with highest infection rate compared to population
select location, MAX(total_cases) as maxtotalcases, population, cast(MAX(total_cases) as float)/ cast(population as float) AS InfectionRate
from Coviddeaths
Group by location,population
Order by InfectionRate desc

select CAST(total_cases AS int), location,population
from Coviddeaths
WHERE location= 'India'
order by CAST(total_cases AS int) desc

--showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS highestdeath
FROM Coviddeaths
Where continent is not null
Group by location,population
ORDER BY highestdeath/population DESC

SELECT location, MAX(cast (total_deaths as int)) as highestdeathcount
FROM Coviddeaths
Where continent is not null
GROUP BY location
ORDER BY highestdeathcount DESC;

--lET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast (total_deaths as int)) as highestdeathcount
FROM Coviddeaths
Where continent is not null
GROUP BY continent
ORDER BY highestdeathcount DESC;

--global numbers

Select date, SUM(new_cases) as totalnewcases, SUM(cast(new_deaths as int)) as totalnewdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Coviddeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2;

Select date, SUM(new_cases) as totalnewcases, SUM(cast(new_deaths as int)) as totalnewdeaths
FROM Coviddeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2;

SELECT date, 
       SUM(new_cases) as totalnewcases, 
       SUM(cast(new_deaths as int)) as totalnewdeaths, 
       CASE WHEN SUM(new_cases) = 0 
            THEN 0 
            ELSE SUM(cast(new_deaths as int))/SUM(new_cases)*100 
       END as DeathPercentage
FROM Coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

---Vaccinations table
Select *
From CovidVaccinations


--let's join the two tables
Select *
from Coviddeaths dea
JOIN CovidVaccinations vac
 On dea.location=vac.location
 and dea.date= vac.date

 --looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
from Coviddeaths dea
JOIN CovidVaccinations vac
 On dea.location=vac.location
 and dea.date= vac.date
 WHERE dea.continent is not null
 Order by 1,2


--let's do a rolling count of these vaccinations per location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplecount
from Coviddeaths dea
JOIN CovidVaccinations vac
 On dea.location=vac.location
 and dea.date= vac.date
 WHERE dea.continent is not null
 Order by 2,3

 --USE CTE

 With PopvsVac (continent,location,date,population,new_vaccinations, Rollingpeoplecount)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplecount
from Coviddeaths dea
JOIN CovidVaccinations vac
 On dea.location=vac.location
 and dea.date= vac.date
 WHERE dea.continent is not null
 )
 Select *, (Rollingpeoplecount/Population)*100 as peoplenewlyvaxxed
 from PopvsVac

 --TEMP TABLE

 
 IF OBJECT_ID('tempdb..#Percentpopuvaxxed') IS NOT NULL
    DROP TABLE #Percentpopuvaxxed;
 Create table #Percentpopuvaxxed
 (continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric, 
 Rollingpeoplecount numeric
 )

 Insert into #Percentpopuvaxxed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplecount
from Coviddeaths dea
JOIN CovidVaccinations vac
 On dea.location=vac.location
 and dea.date= vac.date
 --WHERE dea.continent is not null
 --Order by 2,3

 Select *, (Rollingpeoplecount/Population)*100 as peoplenewlyvaxxed
 from #Percentpopuvaxxed



