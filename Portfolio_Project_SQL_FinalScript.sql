--SELECT *
--FROM Portfolio_project..CovidDeaths
--Order By 3,4

--SELECT *
--FROM Portfolio_project..CovidVaccinations
--Order By 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
Order By 1,2

--Total Cases vs Total Deaths--
--Shows countrywise Likelihood of death by COVID --
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
Order BY 1,2

--Total Cases vs Population--
--Shows percentage of COVID cases by country till 21/01/2022--
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS CasesPercentage
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
Order BY 1,2

--Country with highest percentage of infection--
Select location, population, MAX(total_cases) AS HighestInfections,  Max((total_cases/population))*100 AS CasesPercentage
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY CasesPercentage DESC

-- Total number of deaths by country--
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Analyzing by continen--
-- Showing highest death count by population--
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers--
--Global Numbers by Date-
SELECT date, SUM(new_cases) as NewGlobalCases, SUM(cast(new_deaths as int)) as NewGlobalDeaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
GROUP By date 
Order BY 1,2

--Total Global Numbers till 21/01/2022-
SELECT SUM(new_cases) as NewGlobalCases, SUM(cast(new_deaths as int)) as NewGlobalDeaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
Order BY 1,2

--Joining Vaccination Table--
--Total population vs new vaccinations using CTE--
WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date, dea.location Rows UNBOUNDED PRECEDING) as RollingPeopleVaccinated
FROM Portfolio_project..CovidDeaths as DEA
JOIN Portfolio_project..CovidVaccinations as VAC
ON DEA.date = VAC.date AND DEA.location = VAC.location
WHERE dea.continent is not null and VAC.new_vaccinations is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PopulationVaccinatedPercent
FROM POPvsVAC


--Temp Table--
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), 
location nvarchar(255), 
date datetime, population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric)
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date, dea.location Rows UNBOUNDED PRECEDING) as RollingPeopleVaccinated
FROM Portfolio_project..CovidDeaths as DEA
JOIN Portfolio_project..CovidVaccinations as VAC
ON DEA.date = VAC.date AND DEA.location = VAC.location
WHERE dea.continent is not null


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating Views for Future Visaluizations--
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, DEA.date, dea.population, VAC.new_vaccinations, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date, dea.location Rows UNBOUNDED PRECEDING) as RollingPeopleVaccinated
FROM Portfolio_project..CovidDeaths as DEA
JOIN Portfolio_project..CovidVaccinations as VAC
ON DEA.date = VAC.date AND DEA.location = VAC.location
WHERE dea.continent is not null

Create view TotalDeathCount as
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
GROUP BY location
--ORDER BY TotalDeathCount DESC--
