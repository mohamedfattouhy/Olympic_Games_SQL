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


------------- Query 11 -------------
-- Fetch the top 5 athletes who have won the most gold medals
with top_5_gold_medals as (
    select *, dense_rank() over(order by total_gold_medals desc) as rnk from (
        select name, count(medal) as total_gold_medals from athlete_events
        where medal="Gold"
        group by name
        ) as x
    ) 

select name, total_gold_medals from top_5_gold_medals
where rnk <= 5;


------------- Query 12 -------------
-- Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)
with top_5_most_medals as 
    (select *, dense_rank() over(order by total_medals desc) as rnk from (
        select name, count(medal) as total_medals from athlete_events
        where medal is not null
        group by name) as x) 

select name, total_medals from top_5_most_medals
where rnk <= 5;


------------- Query 13 -------------
-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won
with top_5_countries1 as (
    select *, dense_rank() over(order by total_medals desc) as rnk from (
        select noc, count(medal) as total_medals from athlete_events
        where medal is not null
    group by noc) as x
    ),

    top_5_countries2 as (
        select tc.*, nr.region from top_5_countries1 as tc
        join
        olympics_history_noc_regions as nr
        on (tc.noc = nr.noc)
    )

select region as country, total_medals from top_5_countries2
where rnk <= 5;


------------- Query 14 -------------
-- List down total gold, silver and bronze medals won by each country
select nr.region as country, x.medal, x.no_medals from (select noc, medal,
    count(medal) as no_medals from athlete_events
    where medal is not null
    group by noc, medal
    order by noc) as x
join
olympics_history_noc_regions as nr
on (x.noc = nr.noc);


------------- Query 15 -------------
-- List down total gold, silver and bronze medals won by each country corresponding to each olympic games
with medals_by_games as (
        select nr.region as country, x.games, x.medal, x.no_medals from (select noc, games, medal,
            count(medal) as no_medals from athlete_events
            where medal is not null
            group by noc, games, medal
            order by noc) as x
        join
        olympics_history_noc_regions as nr
        on (x.noc = nr.noc)
    ),

    crosstab_medals as (
        select country, games, 
        min(case when medal='Gold' then no_medals end) as Gold_Medals,
        min(case when medal='Silver' then no_medals end) as Silver_Medals,
        min(case when medal='Bronze' then no_medals end) as Bronze_Medals
        from medals_by_games
        group by country, games
    )

select country, games,
case when Gold_Medals is null then 0 else Gold_Medals end as 'Gold Medals',
case when Silver_Medals is null then 0 else Silver_Medals end as 'Silver Medals',
case when Bronze_Medals is null then 0 else Bronze_Medals end as 'Bronze Medals'
from crosstab_medals;


------------- Query 16 -------------
-- Identify which country won the most gold, most silver and most bronze medals in each olympic games
with medals_by_games_and_country as (
        select x.games, nr.region, x.medal, x.no_medals from (select games, noc, medal,
            count(medal) as no_medals from athlete_events
            where medal is not null
            group by games, noc, medal
            order by games) as x
            join
            olympics_history_noc_regions as nr
            on (x.noc = nr.noc)
    ),

    medals_rank as (
        select *, dense_rank() over(partition by games, medal order by no_medals desc) as rnk,
        case medal when 'Gold' then 1
                   when 'Silver' then 2
                   when 'Bronze' then 3 end as medal_rank
        from medals_by_games_and_country
        order by games, medal_rank
    )

select distinct games, concat(first_value(region) over(partition by games), ' - ',
first_value(no_medals) over(partition by games)) as 'max gold',
concat(nth_value(region, 2) over(partition by games), ' - ',
nth_value(no_medals, 2) over(partition by games)) as 'max silver',
concat(nth_value(region, 3) over(partition by games), ' - ',
nth_value(no_medals, 3) over(partition by games)) as 'max bronze'

from medals_rank
where rnk = 1;
