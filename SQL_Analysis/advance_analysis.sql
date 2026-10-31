USE hospital_analytics;



-- WHAT TO FIND : number of patients with recorded allergies (not having null in allergy description) by allergy and most frequent allergy 
-- TABLES AND COLUMN WE NEED: (allergies,patients),(allergy_description,patient_id) 
-- APPROACH:  use left join and keep allegies as left as there are patients  with no allergies will make our analysis inconsistent
SELECT a.allergy_description,COUNT(DISTINCT(p.patient_id)) AS number_of_patients 
FROM allergies a LEFT JOIN patients p ON p.patient_id=a.patient_id 
GROUP BY a.allergy_description ORDER BY number_of_patients DESC;

-- if you want to find all patients even with null allergy description

SELECT coalesce(a.allergy_description,"Unknown"),COUNT(DISTINCT(p.patient_id)) AS number_of_patients 
FROM patients P LEFT JOIN allergies a ON p.patient_id=a.patient_id 
GROUP BY COALESCE(a.allergy_description,"Unknown") ORDER BY number_of_patients DESC;



-- WHAT TO FIND : number of unique allergies recorded according to age group 
-- TABLES AND COLUMN WE NEED: patients and allergies (patient_id,birth_date,death_date,allergies_description)       
-- APPROACH: 
WITH age_values AS (SELECT patient_id,TIMESTAMPDIFF(YEAR,birth_date,COALESCE(death_date, CURDATE())
        ) AS age
    FROM patients
),
age_segment as (
SELECT patient_id,
CASE WHEN age between 0 and 17 THEN 'Children' 
 WHEN age between 18 and 34 THEN 'young adults' 
 WHEN age between 35 and 49 THEN 'adults' 
 WHEN age between 50 and 64 THEN 'older adult' 
 WHEN age >=65 THEN 'seniors'ELSE 'unknown' END AS age_group 
 FROM age_values)
 SELECT age_group,COUNT(distinct(allergy_description))AS no_of_allergies FROM age_segment ag RIGHT JOIN allergies a  ON ag.patient_id=a.patient_id
 GROUP BY age_group;


-- WHAT TO FIND : number of visits of each patients
-- TABLES AND COLUMN WE NEED: patients and encounters (first_name,last_name,encounter_id) 
-- APPROACH: use left join on patients and encounters for finding all patients and number of thier encounters and 
-- we can also use limit 5 to find top 5 most visiting patietns 
SELECT  p.patient_id,p.first_name, p.last_name, COUNT(e.encounter_id) AS number_of_visits FROM patients p LEFT JOIN encounters e ON p.patient_id=e.patient_id
GROUP BY p.patient_id,p.first_name, p.last_name
ORDER BY number_of_visits DESC;


SELECT * FROM patients p JOIN encounters e ON p.patient_id=e.patient_id
LIMIT 10; 

-- WHAT TO FIND : count of patients by thier reason for visit and then their money spent ,how much is claimed and how much is returned 
-- TABLES AND COLUMN WE NEED: encounters(reason_description,patient_id,base_encounter_cost,total_claim_cost,payer_coverage) 
-- APPROACH: use  encounters for finding all patients and  reason of their visiting
-- we will fill reason description null values as procedural visit or genral visit  as for every null reason description 
SELECT COALESCE(reason_description,"Unknown") AS reason_description,COUNT(patient_id) AS number_of_patients,
SUM(base_encounter_cost) AS total_visit_cost,SUM(total_claim_cost) AS cost_claimed,SUM(payer_coverage) AS covered_till_now
FROM encounters
GROUP BY reason_description;

-- as we have to use this age segmenatation cte in multiple queries so we will create a view for it 

CREATE view age_segmentation  AS 
WITH age_values AS (SELECT patient_id,TIMESTAMPDIFF(YEAR,birth_date,COALESCE(death_date, CURDATE())
        ) AS age
    FROM patients
),
age_segment as (
SELECT patient_id,
CASE WHEN age between 0 and 17 THEN 'Children' 
 WHEN age between 18 and 34 THEN 'young adults' 
 WHEN age between 35 and 49 THEN 'adults' 
 WHEN age between 50 and 64 THEN 'older adult' 
 WHEN age >=65 THEN 'seniors'ELSE 'unknown' END AS age_group 
 FROM age_values) 
 SELECT * FROM age_segment;
 
 
-- WHAT TO FIND : no of visit by age group
-- TABLES AND COLUMN WE NEED: patients(patients_id,birth_date,death_date),encounters(encounter_id)
-- APPROACH: use age segmentation view  and find number of visits by age_group  

SELECT vag.age_group,COUNT(e.encounter_id) AS no_of_visits FROM age_segmentation vag RIGHT JOIN encounters e  ON vag.patient_id=e.patient_id
 GROUP BY age_group;

-- WHAT TO FIND : total patients ,their healthcare expenses and covered till now by encounter_class
-- TABLES AND COLUMN WE NEED: patients(patients_id,healthcare_expenses,healthcare_coverage),encounters(encounter_class)
-- APPROACH: apply grouping on encounter class and apply count on patient_id and sum on expenses and covered

SELECT e.encounter_class,count(distinct(p.patient_id)) AS total_patients,SUM(p.healthcare_expenses) AS total_expenses,SUM(p.healthcare_coverage) AS total_covered
FROM patients p LEFT JOIN encounters e ON p.patient_id=e.patient_id
GROUP BY e.encounter_class;


-- WHAT TO FIND : patients immunized based on age group 
-- TABLES AND COLUMN WE NEED: patients(birth_date,death_date),immunization(patients_id)     
-- APPROACH: use view for age segmentation  and then join it with immunization to get total people immunized

 SELECT vag.age_group,COUNT(distinct(i.patient_id)) AS no_of_people_immunized FROM age_segmentation vag JOIN immunizations i  ON vag.patient_id=i.patient_id
 GROUP BY vag.age_group;

-- WHAT TO FIND : Distribution of number of conditions for each age group
-- TABLES AND COLUMN WE NEED: our view for age segment and table condition (condition_description)
-- APPROACH: use view for age segmentation and then group by condition  description to find count of conditionsfor each age group

SELECT vag.age_group,COUNT(distinct(c.condition_description)) AS conditions_by_age FROM age_segmentation vag  JOIN conditions c  ON vag.patient_id=c.patient_id
GROUP BY vag.age_group
ORDER BY conditions_by_age DESC ;

-- WHAT TO FIND : top 3 most frequent condition
-- TABLES AND COLUMN WE NEED: patients(patient_id),condition (condition_description)
-- APPROACH: count unque patients as same patient can have same condition multiple times and then group by condition_escription

SELECT c.condition_description , count(distinct(p.patient_id)) AS no_of_patients FROM
patients p LEFT JOIN conditions c ON p.patient_id=c.patient_id
GROUP BY c.condition_description
ORDER BY no_of_patients DESC
LIMIT 3;
-- Top 3 most frequent conditons 
# 'Viral sinusitis (disorder)', '743'
# 'Acute viral pharyngitis (disorder)', '492'
# 'Acute bronchitis (disorder)', '464'



-- WHAT TO FIND : most frequent medicne prescribed
-- TABLES AND COLUMN WE NEED: patients(patient_id),medications (medication_description)
-- APPROACH: count distinct patients and group by medication description

SELECT medication_description, COUNT(distinct(p.patient_id)) AS total_patients FROM patients p JOIN medications m ON p.patient_id=m.patient_id  
GROUP BY m.medication_description
ORDER BY total_patients DESC;

-- WHAT TO FIND : total cost of medicines and payer_coverage till now  across diffrent age group
-- TABLES AND COLUMN WE NEED: view(age_segmentation),medications (base_cost)
-- APPROACH: count distinct patients and group by medication description
SELECT vag.age_group,SUM(m.base_cost) AS medication_cost,SUM(payer_coverage) AS cost_covered FROM age_segmentation vag JOIN medications m ON vag.patient_id=m.patient_id
GROUP BY vag.age_group
ORDER BY medication_cost DESC;


SELECT * FROM organizations o JOIN providers P ON o.organization_id=p.organization_id limit 10;

-- WHAT TO FIND : organization name and number of treatment providers there
-- TABLES AND COLUMN WE NEED: oganizaitons(organization_name),providers (provider_id)
-- APPROACH: group by organization name and sum the provider id as it is unique for each row 
SELECT o.organization_name , count(p.provider_id) AS total_treatment_providers
FROM organizations o JOIN providers p ON  o.organization_id=p.organization_id
GROUP BY o.organization_name
ORDER BY total_treatment_providers DESC;


-- WHAT TO FIND : organization name and number of patients treated and their total claimed cost and amount covered till now 
-- TABLES AND COLUMN WE NEED: oganizaitons(organization_name),providers(speciality),encounters(claim and coverage)
-- APPROACH: perform multiple join on organizations and providers and encounters group by organization name and speciality 
-- and calculate total_patients , total_cost they claimed and coverage till now 

SELECT o.organization_name ,p.speciality, count(e.patient_id) AS total_patients,COALESCE(SUM(e.total_claim_cost),0) AS total_claimed_cost,
COALESCE(SUM(e.payer_coverage),0) AS total_covered_cost
FROM organizations o  LEFT JOIN providers p ON  o.organization_id=p.organization_id  LEFT JOIN encounters e ON p.provider_id=e.provider_id
GROUP BY o.organization_name,p.speciality;
-- other then general practice there is no other speciality provided by organizations

-- WHAT TO FIND : organization name count of male and female providers there 
-- TABLES AND COLUMN WE NEED: oganizaitons(organization_name),providers(gender,provider_id)
-- APPROACH: perform  join on organizations and providers group by  name 
-- and calculate total males and females in organizations , total_staff_count 

SELECT o.organization_name ,
SUM(CASE when p.gender = "Male" THEN 1 ELSE 0 END) AS no_of_male,
SUM(CASE when p.gender = "Female" THEN 1 ELSE 0 END) AS no_of_female,
count(p.provider_name) AS total_staff
FROM organizations o LEFT JOIN providers p ON  o.organization_id=p.organization_id
GROUP BY o.organization_name;


-- WHAT TO FIND : provider_name and revenue generated
-- TABLES AND COLUMN WE NEED: oganizaitons(revenue),providers(provider_name)
-- APPROACH: perform  join on organizations and providers group by  name 
-- and calculate total_revenue
SELECT p.provider_name ,
SUM(revenue) AS total_fee
FROM organizations o LEFT JOIN providers p ON  o.organization_id=p.organization_id
GROUP BY p.provider_name
ORDER BY total_fee DESC;

-- IF we have to find top 5 treatment providers who have generated most revenue
WITH ranked AS(
SELECT p.provider_name ,
SUM(revenue) AS total_fee
FROM organizations o LEFT JOIN providers p ON  o.organization_id=p.organization_id
GROUP BY p.provider_name
ORDER BY total_fee DESC),
ranked_2 AS (SELECT *,ROW_NUMBER() OVER ()  AS ranking FROM ranked)
SELECT * FROM ranked_2 WHERE ranking<=5;
-- here we did not need to partiton by or use rank because there we no ties and we have laready grouped the values in irst cte


-- WHAT TO FIND : rank patients by their number of visits 
-- TABLES AND COLUMN WE NEED: patients(id,first_nam,last_name),encounters(encounter_id)
-- APPROACH: perform  join on patients and encounters and then use window function to rank them on basis of number of visit 
-- group by id,first_name,last_name

SELECT  p.patient_id,p.first_name, p.last_name, COUNT(e.encounter_id) AS number_of_visits,
DENSE_RANK() OVER ( ORDER BY COUNT(e.encounter_id) DESC) AS ranked
FROM patients p LEFT JOIN encounters e ON p.patient_id=e.patient_id
GROUP BY p.patient_id,p.first_name, p.last_name;
-- dense_rank because it doe not skip the nect number for ties we can also use row_number here 




-- WHAT TO FIND : total patients and procedures happened by month and year 
-- TABLES AND COLUMN WE NEED: encounters(start_date,patient_id),procedures(procedure_description)
-- APPROACH: perform  join on procedures and encounters and then use group by to group htem by month and year and find count of patients and procedure happened
-- then order by procedure_happend to find month and year when max number of procedure happend
SELECT monthname(e.encounter_start_date) AS encounter_month, year(e.encounter_start_date) AS encounter_year,
count(distinct(e.patient_id))AS total_patients,COUNT(p.procedure_description) AS procedures_happened
FROM encounters e JOIN procedures P ON e.encounter_id=p.encounter_id 
GROUP BY encounter_month,encounter_year
ORDER BY  procedures_happened DESC ;


-- WHAT TO FIND :
-- Explore recorded healthcare expenses, encounter costs,
-- claim costs, and payer coverage in relation to condition descriptions.
-- Distinguish patient-level expenses from encounter-level financial measures.

-- TABLES AND COLUMN WE NEED: 
-- patients: patient_id, first_name, last_name, healthcare_expenses
-- encounters: encounter_id, patient_id, encounter_start_date,
--             base_encounter_cost, total_claim_cost, payer_coverage
-- conditions: patient_id, encounter_id, condition_description
-- APPROACH: 
-- Identify the relationship between patients, encounters, and conditions.
-- Check the number of records at each level before joining.
-- Aggregate patient-level and encounter-level measures appropriately
-- to avoid duplicated totals.
-- Compare the resulting measures by condition description.

WITH joined AS(
SELECT p.patient_id,e.encounter_id,p.first_name,p.last_name,
SUM(p.healthcare_expenses) OVER (PARTITION BY p.patient_id ORDER BY e.encounter_start_date) AS total_health_care_expenses,
COUNT(e.encounter_id)  OVER (PARTITION BY p.patient_id ORDER BY e.encounter_start_date) AS visits,
SUM(e.base_encounter_cost) OVER (PARTITION BY p.patient_id ORDER BY e.encounter_start_date) AS encounter_cost,
SUM(e.total_claim_cost) OVER (PARTITION BY p.patient_id ORDER BY e.encounter_start_date) AS total_claimed,
SUM(e.payer_coverage) OVER (PARTITION BY p.patient_id ORDER BY e.encounter_start_date) AS covered
FROM patients p JOIN encounters e on p.patient_id=e.patient_id)

SELECT j.first_name,j.last_name,
c.condition_description,
SUM(total_health_care_expenses)as total_expense,SUM(visits) AS visits,SUM(encounter_cost) AS cost_per_visit
,SUM(total_claimed) AS total_money_claimed,
SUM(covered) AS money_covered_till_now
FROM joined j JOIN conditions c ON c.patient_id = j.patient_id AND c.encounter_id = j.encounter_id
GROUP BY j.first_name,j.last_name,c.condition_description;
































































































































































































































































































































