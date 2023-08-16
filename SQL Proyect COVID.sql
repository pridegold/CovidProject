select location, date, total_cases, new_cases, total_deaths,
population from CovidDeaths

-- Total cases vs Total Deaths
-- Muestra la cantidad de muertes teniendo como panorama el total de casos.

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Porcentaje_Muertes
from CovidDeaths where location = 'Argentina'

-- Total Cases Vs Population
-- Muestra que porcentaje de la población se contagio del virus.

select location, date,  population,total_cases, (total_cases/population)*100 as Porcentaje_Contagios
from CovidDeaths where location = 'Argentina'

-- Paises con el mayor porcentaje de poblacion infectada.

select location, population, max(total_cases) as Total_Contagios, 
round(max((total_cases/population)), 4) * 100 as Porcentaje_Contagios
from CovidDeaths where continent is not null group by location, population
order by Porcentaje_Contagios desc

-- Paises con el mayor porcentaje de poblacion fallecida.

select location, population, max(cast(total_deaths as int)) as Total_Fallecidos,
round((max(total_deaths/population)),3)*100 as Porcentaje_de_Muertes
from CovidDeaths where continent is not null group by location, population
order by Porcentaje_de_Muertes desc

-- Continentes

select location, max(cast(Total_deaths as int)) as Total_Fallecidos
from CovidDeaths where continent is null group by location order by Total_Fallecidos desc

-- Continentes con la mayor proporcion de poblacion fallecida.

select continent, max(cast(total_deaths as int)) as Total_Fallecidos
from CovidDeaths where continent is not null group by continent order by Total_Fallecidos desc


-- Informacion Global

select sum(new_cases) as Casos_Totales, sum(cast(new_deaths as int)) as Total_Fallecidos,
round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as Porcentaje_Fallecidos from CovidDeaths where continent is not null

-- Población Total vs Vacunacion -- Total Vacunación

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Total_Vacunación
from CovidDeaths dea inner join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date where dea.continent is not null


-- SUBQUERY Para Realizar Calculos -- Población Vacunada

with PopVsVac as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Total_Vacunación
from CovidDeaths dea inner join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date where dea.continent is not null
)
select *, round((Total_Vacunación/Population),4)*100 as Población_Vacunada from PopVsVac


-- Creando TEMP Table para la consulta anterior

create table Porcentaje_Población_Vacunada
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_Vacunación numeric)

insert into Porcentaje_Población_Vacunada
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Total_Vacunación
from CovidDeaths dea inner join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date where dea.continent is not null

select * from Porcentaje_Población_Vacunada

-- Crear view para visualizar cuando sea necesario

Create View Población_Vacunada as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Total_Vacunación
from CovidDeaths dea inner join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date where dea.continent is not null

select * from Población_Vacunada