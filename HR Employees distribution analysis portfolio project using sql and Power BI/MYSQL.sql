use portfolioprojetcts; 
select * from hr; 

-- changer le nom de la colonne ï»¿id.
alter table hr
change column ï»¿id emp_id varchar(20) null;

-- data types
describe hr;

-- change data types of "birthdate, hire_date, termdate(termination date)"
set sql_safe_updates = 0; -- afin de ne pas avoir de modifications dans la source

select * from hr;

select birthdate from hr;

update hr
set birthdate = case 
when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
else null
end; 
alter table hr
modify column birthdate date; 
----------------------------------

select hire_date from hr;

update hr
set hire_date = case 
when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
else null
end;
alter table hr
modify column hire_date date; 
------------------------------
select termdate from hr;
update hr
set termdate = date (str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC') )
where termdate is not null and termdate !='';

alter table hr
modify column termdate date;

alter table hr 
add column terminationdate date;

update hr
set terminationdate = termdate
where termdate is not null and termdate !='';

-- add age colomn
alter table hr 
add column age int;

update hr
set age = timestampdiff(year,birthdate,curdate());

select min(age) as youngest, max(age) as oldest from hr;
select count(*) from hr where age < 18;

select * from hr;
-- 1.what's the gender breakdown of employees in the company?
select gender, count(*) as count from hr
where age >= 18 and terminationdate is null
group by gender;

-- 2.what's the race/ethnicity breakdown of employees in the company?
select race, count(*) as count from hr
where age >= 18 and terminationdate is null
group by race
order by count desc;

-- 3. what's the age distribution in the company?
select min(age) as youngest, max(age) as oldest from hr
where age >= 18 and terminationdate is null;

select case
when age >=18 and age <=24 then "18-24"
when age >=25 and age <=34 then "25-34"
when age >=35 and age <=44 then "35-44"
when age >=45 and age <=54 then "45-54"
when age >=55 and age <=64 then "55-64"
else "65+"
end as age_group,
count(*) as count, gender from hr
where age >= 18 and terminationdate is null
group by age_group,gender
order by age_group,gender;

-- 4.how many employees work at headquarters versus remote locations?
select location, count(*) as count from hr
where age >= 18 and terminationdate is null
group by location
order by count desc;

-- 5. what's the average length of employment for employees who have been terminated?
select round(avg( datediff(terminationdate,hire_date))/365,0) as avg_length_employment from hr
where terminationdate<=curdate() and terminationdate is not null and age >= 18;

-- 6.how doe the gender distribution vary across departement and job titels?
select gender,department, count(*) as count from hr
where age >= 18 and terminationdate is null
group by department,gender
order by department;

select gender,jobtitle, count(*) as count from hr
where age >= 18 and terminationdate is null
group by jobtitle,gender
order by jobtitle;
 -- 7.what's the distribution of jobtitles across the company?
select jobtitle, count(*) as count from hr
where age >= 18 and terminationdate is null
group by jobtitle
order by jobtitle desc;

-- 8.which department has the highest turnover rate?
select department, total_count, terminated_count, terminated_count/total_count as termination_rate
-- subquery
from(
select department, count(*) as total_count,
sum(
case 
when terminationdate is not null and terminationdate <= curdate() then 1
ELSE 0 
end
) as terminated_count
from hr
where age >= 18
group by department
) as subquery
order by termination_rate desc;
-- 9. What is the distribution of employees across locations by state?
SELECT location_state, COUNT(*) as count
FROM hr
WHERE age >= 18 and terminationdate is null
GROUP BY location_state
ORDER BY count DESC;

-- 10. how has the company's employees count chandged over time based on the hire and term dates?
select the_year, hires, terminations, hires-terminations as net_change, round((hires-terminations)/hires*100,2) as net_change_percent
from(
select year(hire_date) as the_year, count(*) as hires,
sum(
case 
when terminationdate is not null and terminationdate <= curdate() then 1
ELSE 0 
end
) as terminations
from hr
where age >= 18
group by the_year
) as subquery
order by the_year asc;

-- 11.what's the tenure distribution for each departement?
select department, round(avg(datediff(terminationdate,hire_date)/365),0) as avg_tenure
from hr
where terminationdate is not null and terminationdate <= curdate() and age >= 18
group by department
order by avg_tenure

