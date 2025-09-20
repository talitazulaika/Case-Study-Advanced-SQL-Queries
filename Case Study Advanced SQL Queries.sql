--1) The Report
with student_in_grade as (
    select name, grade, marks
    from students s
    join grades g
    on s.marks between g.min_mark and g.max_mark
)
select 
case 
when grade < 8 then 'NULL'
else name
end as name, grade, marks
from student_in_grade
order by grade DESC,
case 
when grade >=8 
then name 
end ASC ,
case 
when grade < 8
then marks
end ASC;

--2) Weather Observation Station 18
with agregation as(
select 
min(LAT_N) as a,
min(LONG_W) as b,
max(LAT_N) as c,
max(LONG_W) as d
from STATION
)
select cast(round (
    abs(a-c) + abs(b-d), 4)
    as decimal(10,4)
) as manhattan_distance
from agregation;

--3) Top Competitors
with max_score as (
    select s.hacker_id, c.challenge_id
    from Submissions s
    inner join Challenges c
    on s.challenge_id = c.challenge_id
    inner join Difficulty  d
    on d.difficulty_level = c.difficulty_level
    where s.score = d.score
),
    count_max_score as (
    select hacker_id, count(distinct challenge_id) as count_max
    from max_score
    group by hacker_id
    having count(distinct challenge_id) > 1
)
select h.hacker_id, h.name
from Hackers h
inner join count_max_score cms
on cms.hacker_id = h.hacker_id
order by count_max desc, hacker_id asc;

--4) Ollivander's Inventory
with wands_info as(
    select id,w.code,age,power,is_evil,coins_needed,
    min(coins_needed) over (partition by age,power) as coins_min
    from Wands w
    inner join Wands_property wp 
    on w.code = wp.code
    where is_evil = 0
) 
select id,age,coins_needed,power from wands_info
where coins_needed = coins_min
order by power desc, age desc;


--5) Contest Leaderboard
with score as (
    select hacker_id, challenge_id, max(score) as max_score
    from Submissions
    group by hacker_id,challenge_id
),
hacker_detil as(
    select h.hacker_id,name,max_score
    from Hackers h
    inner join score s
    on h.hacker_id = s.hacker_id
)
select hacker_id,name,sum(max_score) as score
 from hacker_detil
 group by hacker_id,name
 having sum(max_score) > 0
 order by score DESC, hacker_id ASC;