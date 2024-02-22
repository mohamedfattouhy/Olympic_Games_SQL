"""This file contains the sql queries that answer the various questions"""

------------- Query 1 -------------
-- How many olympics games have been held ?
select distinct games, season, city from athlete_events
order by games;


------------- Query 2 -------------
-- List down all Olympics games held so far
select distinct games, season, city from athlete_events
order by games;


------------- Query 3 -------------
-- Mention the total no of nations who participated in each olympics game ?
select games, count(distinct noc) as total_countries from athlete_events
group by games
order by games;


------------- Query 4 -------------
-- Which year saw the highest and lowest no of countries participating in olympics ?
select games, count(distinct noc) as total_countries from athlete_events
group by games
order by games;


------------- Query 5 -------------
-- Which nation has participated in all of the olympic games ?
select noc, count(distinct games) as cnt from athlete_events
group by noc
having cnt = (select count(distinct games) from athlete_events);


------------- Query 6 -------------
-- Identify the sport which was played in all summer olympics
select sport, count(sport) as cnt from (
    select distinct sport, Games from athlete_events
    where season = "summer") as x
group by sport
having cnt = (select count(distinct Games) from athlete_events where season = "summer");


------------- Query 7 -------------
-- Which Sports were just played only once in the olympics ?
select sport, count(distinct Games) as cnt, min(games) as games from athlete_events
group by sport
having cnt = 1;


------------- Query 8 -------------
-- Fetch the total no of sports played in each olympic games
select games, count(distinct sport) as total_sports
from athlete_events
group by games
order by games;


------------- Query 9 -------------
-- Fetch oldest athletes to win a gold medal
select year, name, age, games from athlete_events
where medal="Gold" and age is not null
order by age desc
limit 2;


------------- Query 10 -------------
-- Find the Ratio of male and female athletes participated in all olympic games
select (select count(sex) from athlete_events where sex="M")/(select count(sex) from athlete_events where sex="F") as ratio_male_female
