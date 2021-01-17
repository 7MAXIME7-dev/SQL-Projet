
-- tool for data preparing. The goal is to replace '' by NULL in order to avoid future issues
UPDATE covid_19.patient 
SET 
    source = NULL
WHERE
    source = '';

-----------------------------------------------------------------------------------------------------------------
-- Display the Dataset : 

SELECT 
    *
FROM
    covid_19.patient;
-----------------------------------------------------------------------------------------------------------------

-- 1) Data Informations

-- this dataset was submitted on 15th of March 2020. 
-- (https://www.kaggle.com/lperez/coronavirus-france-dataset)
-- That's why we're going to analyze the situation for the day 15/03 .

-- there are a lot of NULL values in this dataset,
-- it can be avoid to have good results and there are severals column unusable 
-- like released date (very important indicator)


-- what's the birth year range ?
SELECT 
    MIN(birth_year), MAX(birth_year), ROUND(avg(birth_year))
FROM
    covid_19.patient;
  
-- Birth year is between 1922 and 2019 with average 1966.



-- what's the age range ?
SELECT 
    2020 - MAX(birth_year) AS age_min,
    2020 - MIN(birth_year) AS age_max,
    2020 - ROUND(AVG(birth_year)) AS avg_age
FROM
    covid_19.patient;

-- Age is between 1 and 98 with average 54 years old.



-- how much patient in this dataset?
SELECT 
    COUNT(id)
FROM
    covid_19.patient;
    
-- In this dataset, there is 2072 patients.


-----------------------------------------------------------------------------------------------------------------


-- 2) Data analyze

-- how much case by region on the 15/03?
SELECT 
    region, COUNT(region) AS numberOfCases
FROM
    covid_19.patient
GROUP BY region
ORDER BY COUNT(region) DESC;

-- Grand-Est (461 cases) and Ile-de-France (440 cases) regions are 
-- the most affected by this epidemic.

-- display the region most affected by this epidemic
SELECT 
    region, MAX(numberOfCases)
FROM
    (SELECT 
        region, COUNT(region) AS numberOfCases
    FROM
        covid_19.patient
    GROUP BY region
    ORDER BY COUNT(region) DESC) AS previousQuery;
-- Grand-Est with 461 cases

-- what's the different infection reason?
SELECT DISTINCT
    (infection_reason)
FROM
    covid_19.patient;
    
-- we can see that infection reasons are multiple.


-- What's the count for each infection_reason on the 15/03?
SELECT 
    infection_reason, COUNT(infection_reason)
FROM
    covid_19.patient
GROUP BY infection_reason
ORDER BY COUNT(infection_reason) DESC;

-- we can see that contact with patient and 
-- visit to Mulhouse religious gathering was the main epidemic spreading reasons.
-- then, there is visit to Italy and Egypt as infection reasons.


-- We will now try to retrace epidemic spreading :
SELECT 
    confirmed_date, infection_reason
FROM
    covid_19.patient
WHERE
    infection_reason IS NOT NULL
ORDER BY confirmed_date;

-- the first case was confirmed the 27th of january due to an Italy travel.
-- so we can see that confirmed case came from Italy in first time. 
-- the epidemic quickly became locally present in other regions.
-- this is mainly due to the religious meeting in Mulhouse between the 17th & 21th of february.

-- when the first cases for the religious gathering was confirmed ?
SELECT 
    confirmed_date, infection_reason
FROM
    covid_19.patient
WHERE
    infection_reason LIKE '%Mulhouse%'
ORDER BY confirmed_date;

-- The first case for the religious gathering was confirmed the 4th of march, 
-- 11 days after the end of the gathering.

-- We can see that the first symptoms take time to be felt. 
-- We now understand why it was already too late to contain the progression of the virus.

-- How much patient exactly visit Italy before being sick ?
SELECT 
    infection_reason, COUNT(infection_reason)
FROM
    covid_19.patient
WHERE
    infection_reason LIKE '%Italy%'
        OR '%Milan%'
        OR '%Lombardy%'
        OR 'Italian'
ORDER BY confirmed_date;

-- There is exactly 23 persons who visited Italy before being sick.

-- how much patient exactly visited Mulhouse religious meeting ?
SELECT 
    infection_reason, COUNT(infection_reason)
FROM
    covid_19.patient
WHERE
    infection_reason LIKE '%Mulhouse%'
ORDER BY confirmed_date;
-- There is exactly 51 persons who visited the Mulhouse religious meeting before being sick.


-- how much new case for each day until 15/03?
SELECT 
    confirmed_date, COUNT(confirmed_date)
FROM
    covid_19.patient
GROUP BY confirmed_date
ORDER BY confirmed_date;

-- This confirm that Mulhouse meeting is the biggest trigger of the epidemic
-- because after 4th of March the number of new cases indradays jumped from 45
-- to several hundred.

-- this dataset was submitted on the 15th of March 2020. 
-- So, we can't have the current situation.

-- On the 15/03 what was the number of cases for each statues ?
SELECT 
    SUM(CASE
        WHEN status IS NULL THEN 1
    END) AS nullValue,
    SUM(CASE
        WHEN status = 'hospital' THEN 1
    END) AS hospital,
    SUM(CASE
        WHEN status = 'home isolation' THEN 1
    END) AS home_isolation,
    SUM(CASE
        WHEN status = 'deceased' THEN 1
    END) AS deceased,
    SUM(CASE
        WHEN status = 'released' THEN 1
    END) AS released
FROM
    covid_19.patient;

-- What was the percentage of hospitalization ?
SELECT 
    (SUM(CASE
        WHEN status = 'hospital' THEN 1
    END) / COUNT(status)) * 100 AS percentage_of_hospitalization
FROM
    covid_19.patient;
    
-- The result is 75 %. I think this result is not true. I think it's due to 
-- high number of NULL values.


-- What was the percentage of deceased ?
SELECT 
    (SUM(CASE
        WHEN status = 'deceased' THEN 1
    END) / COUNT(status)) * 100 AS percentage_of_deceased
FROM
    covid_19.patient;
 
-- Oficial values (4th of May) annonce a deceased rate less than 3 % in France.
-- This Dataset gives 4.39 % . This is close to reality.
-- This is difficult to have the good rate because of NULL values...

    
-- What about health cases ?

SELECT 
    SUM(CASE
        WHEN health IS NULL THEN 1
    END) AS nullValue,
    SUM(CASE
        WHEN health = 'good' THEN 1
    END) AS good,
    SUM(CASE
        WHEN health = 'critical' THEN 1
    END) AS critical,
    SUM(CASE
        WHEN health = 'deceased' THEN 1
    END) AS deceased,
    SUM(CASE
        WHEN health = 'cured' THEN 1
    END) AS cured
FROM
    covid_19.patient;
    
-- On the 15/03 patient are mostly in good shape.
-- Difficult to give other conclusions because of NULL values.
    
    
-- What was the percentage of deceased cases who had more than 60 Years old ?
SELECT 
    (SUM(CASE
        WHEN status = 'deceased' THEN 1
    END) / COUNT(status)) * 100 AS percentage_of_old_deceased
FROM
    covid_19.patient
WHERE
    birth_year <= 2020 - 60;
    
-- the percentage of deceased cases for people aged of 60 Years old or more is 36 % .


-- What was the percentage of deceased cases who had between 60 & 65 Years old ?
SELECT 
    (SUM(CASE
        WHEN status = 'deceased' THEN 1
    END) / COUNT(status)) * 100 AS percentage_of_old_deceased
FROM
    covid_19.patient
WHERE
    birth_year BETWEEN 2020 - 65 AND 2020 - 60;
    
-- the percentage of deceased cases for people between 60 & 65 Years old is 33 % .


-- What was the percentage of deceased cases who had more than 80 Years old ?
SELECT 
    (SUM(CASE
        WHEN status = 'deceased' THEN 1
    END) / COUNT(status)) * 100 AS percentage_of_old_deceased
FROM
    covid_19.patient
WHERE
    birth_year <= 2020 - 80;
    
-- the percentage of deceased cases for people aged of 80 Years old or more is 62 % .

-- we can see a strong correlation between deceased rate and age.
    
    
    
-- what was the percentage of old people (>=60 years old) in hospital ?
SELECT 
    (SUM(CASE
        WHEN status = 'hospital' THEN 1
    END) / COUNT(status)) * 100 AS percentage_of_old_in_hospital
FROM
    covid_19.patient
WHERE
    birth_year <= 2020 - 60;
    
-- In hospital, we can observe that 53 % have more than 60 years old.



-- what was the percentage of male in hospital ?
SELECT 
    (SUM(CASE
        WHEN sex = 'male' THEN 1
    END) / COUNT(sex)) * 100 AS percentage_of_male_in_hospital
FROM
    covid_19.patient
WHERE
    status = 'hospital';
    
-- Studies annonce that man are mostly affected than woman. There is no evidence 
-- of this on the Dataset. We will try an other thing later.


-- What was the percentage of people with good health in hospital ?
SELECT 
    (SUM(CASE
        WHEN health = 'good' THEN 1
    END) / COUNT(health)) * 100 AS percentage_of_good_in_hospital
FROM
    covid_19.patient
WHERE
    status = 'hospital';

-- The percentage of people with good health in hospital was 88 %



-- What was the percentage of people with critical health in hospital ?
SELECT 
    (SUM(CASE
        WHEN health = 'critical' THEN 1
    END) / COUNT(health)) * 100 AS percentage_of_critical_in_hospital
FROM
    covid_19.patient
WHERE
    status = 'hospital';

-- In this dataset, there is 9 %  of critical cases in hospital for covid 19.


-- What was the percentage of male in hopital with critical health ?
SELECT 
    (SUM(CASE
        WHEN sex = 'male' THEN 1
    END) / COUNT(sex))*100 as hospital_critical_percentage_of_male
FROM
    covid_19.patient
WHERE
    status = 'hospital' 
    AND health = 'critical';

-- result is 50 %
-- There is a lack of data, so we can't confirm that males are more than females 
-- in a critical situation at hospital.
    
    
-- Conclusion:

-- To conclude there are a lot of true facts resulting of this Dataset. 
-- This dataset is not perfect and old (published 2 month ago), 
-- that's why we can't draw precise result but we have the general trend.
-- So, in this conclusion I will try to resume the main points with certainties.

-- 1) Principle factors of pandemic trigger are : contact with patient, visit to Italy,
--    and Mulhouse gethering.

-- 2) The most affected region of France are: Grand-Est & Ile-De-France.

-- 3) The percentage of deceased cases for people aged of 60 Years old or more is higher
-- 	  than normal.

-- 4) The percentage of deceased cases for people aged of 80 Years old is very high.
--    So, deceased risk increase with age.

-- 5) There is 50 % old (> 60 y) and 50 % young (< 60 y) in hospital. 

-- 6) People are mostly with good status in hospital.




