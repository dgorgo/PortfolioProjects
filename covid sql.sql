USE PortfolioProjects;

SELECT *
FROM PortfolioProjects..CovidDeaths$
ORDER BY 4,5

SELECT *
FROM PortfolioProjects..CovidVaccinations$
ORDER BY 3,4

SELECT *
FROM PortfolioProjects..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--DATA TO USE--

SELECT location, date, total_cases, new_cases,total_deaths,population
FROM PortfolioProjects..CovidDeaths$
ORDER BY 1,2


--TOTAL CASES AGAINST TOTAL DEATHS--

SELECT location, date, total_cases,total_deaths, (Total_deaths/total_cases)
FROM PortfolioProjects..CovidDeaths$
ORDER BY 1,2



--TOTAL CASES/TOTAL DEATH BY PERCENTAGE--
SELECT location, date, total_cases,total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM Project..['covid death$']
ORDER BY 1,2

--CASES IN AFRICA--
SELECT location, date, total_cases,total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE location LIKE '%Africa%'
ORDER BY 1,2


--in NIGERIA--
SELECT location, date, total_cases,total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2 




--TOTAL CASES/ POPULATION--
SELECT location, date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths$
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2 


SELECT location, date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%Nigeria%'--
ORDER BY 1,2 



--checking for highest infection rate compared to population--
SELECT location,population,MAX(total_cases) AS HghestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%Nigeria%'--
GROUP BY location, population
ORDER BY 1,2 

SELECT location,population,MAX(total_cases) AS HghestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths$
WHERE location LIKE '%Africa%'
GROUP BY location, population
ORDER BY 1,2 




--Countries with highest death count--
SELECT location,MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%Nigeria%'--
GROUP BY location
ORDER BY TotalDeathCount desc   




--CASTING TO CHANGE THE DATA TYPE--
SELECT location,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%Nigeria%'--
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc 





--by continent--
SELECT continent,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%Nigeria%'--
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc 


SELECT location,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%Nigeria%'--
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc 



SELECT continent,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%Nigeria%'--
WHERE continent is null
GROUP BY continent
ORDER BY TotalDeathCount desc 


--global numbers--

SELECT  date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE continent is not null
group by date
ORDER BY 1,2 




SELECT *
FROM PortfolioProjects..CovidDeaths$ DEA
JOIN PortfolioProjects..CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date



SELECT DEA.continent,DEA.location,DEA.DATE,DEA.population,VAC.new_vaccinations
FROM PortfolioProjects..CovidDeaths$ DEA
JOIN PortfolioProjects..CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


SELECT DEA.continent,DEA.location,DEA.DATE,DEA.population,VAC.new_vaccinations
FROM PortfolioProjects..CovidDeaths$ DEA
JOIN PortfolioProjects..CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.location LIKE '%Nigeria%'
--WHERE DEA.continent IS NOT NULL--
ORDER BY 1,2,3



--Population vs Vaccinations
SELECT DEA.continent,DEA.location,DEA.DATE,DEA.population,VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (Partition by DEA.location order by DEA.location,DEA.date) as RollingPeaopleVaccinated
FROM PortfolioProjects..CovidDeaths$ DEA
JOIN PortfolioProjects..CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 1,2,3




--use CTE--



with PopsvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT DEA.continent,DEA.location,DEA.DATE,DEA.population,VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (Partition by DEA.location order by DEA.location,DEA.date) as RollingPeaopleVaccinated
--(RollingPeopleVaccinated/population)*100--
FROM PortfolioProjects..CovidDeaths$ DEA
JOIN PortfolioProjects..CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 1,2,3--
)

select *, (RollingPeopleVaccinated/population)*100
from PopsvsVac




--TEMP TABLE--
Drop table if exists PercentageVaccinated
Create table PercentageVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
RollingPeopleVaccinated numeric

)


insert into PercentageVaccinated
SELECT DEA.continent,DEA.location,DEA.DATE,DEA.population,VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (Partition by DEA.location order by DEA.location,DEA.date) as RollingPeaopleVaccinated
--(RollingPeopleVaccinated/population)*100--
FROM PortfolioProjects..CovidDeaths$ DEA
JOIN PortfolioProjects..CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 1,2,3--

select *, (RollingPeopleVaccinated/population)*100
from PopsvsVac





create view  PopulationVaccinated as
SELECT DEA.continent,DEA.location,DEA.DATE,DEA.population,VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (Partition by DEA.location order by DEA.location,DEA.date) as RollingPeaopleVaccinated
--(RollingPeopleVaccinated/population)*100--
FROM PortfolioProjects..CovidDeaths$ DEA
JOIN PortfolioProjects..CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 1,2,3--


select *
from PopulationVaccinated