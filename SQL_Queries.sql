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
