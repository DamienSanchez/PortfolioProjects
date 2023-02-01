
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ProtfolioProject..CovidDeaths
order by 1,2;

-- shows liklihood of dying if contracting covid in your country
SELECT Location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as death_percentage
FROM ProtfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2;

-- Looking at total cases vs population
SELECT Location, date, total_cases, population, ((total_cases/population)*100) as infectionrate
FROM ProtfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2;

--highest infection rate OVERALL
SELECT TOP 1 Location, total_cases, population, ((total_cases/population)*100) as infectionrate
FROM ProtfolioProject..CovidDeaths
ORDER BY infectionrate DESC;

--Looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)*100) as infectionrate
FROM ProtfolioProject..CovidDeaths
Group By location, population
order by infectionrate DESC;

-- showing country with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProtfolioProject..CovidDeaths
WHERE continent is not null
Group By location
order by TotalDeathCount DESC;

--showing the continent with hiegest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProtfolioProject..CovidDeaths
WHERE continent is not null
Group By continent
order by TotalDeathCount DESC;

-- global numbers day by day
SELECT date, SUM(new_cases) as totalCases, SUM(cast (new_deaths as int)) as totalDeaths, SUM(cast (new_deaths as int))/SUM(new_cases) *100 as deathPercentage
FROM ProtfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2;

-- global numbers totals
SELECT SUM(new_cases) as totalCases, SUM(cast (new_deaths as int)) as totalDeaths, SUM(cast (new_deaths as int))/SUM(new_cases) *100 as deathPercentage
FROM ProtfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2;

--Looking at population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingCountOfVax
FROM ProtfolioProject..CovidVaccinations vac
JOIN ProtfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3;

-- USE CTE
with Popvsvac (continent, location,date, population,new_vaccinations,rollingCountOfVax )
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingCountOfVax
FROM ProtfolioProject..CovidVaccinations vac
JOIN ProtfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rollingCountOfVax/population)*100 as percentOfPopVac
FROM Popvsvac
;

--creating views for later viz

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingCountOfVax
FROM ProtfolioProject..CovidVaccinations vac
JOIN ProtfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

CREATE VIEW PercentageOfCasesVsPopulation as
SELECT Location, date, total_cases, population, ((total_cases/population)*100) as infectionrate
FROM ProtfolioProject..CovidDeaths
WHERE location like '%states%';

CREATE VIEW  LiklihoodOfDeath   as
SELECT Location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as death_percentage
FROM ProtfolioProject..CovidDeaths
WHERE location like '%states%';

CREATE VIEW HighestDeathRatePerContry as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProtfolioProject..CovidDeaths
WHERE continent is not null
Group By location;