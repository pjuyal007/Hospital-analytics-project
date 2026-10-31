USE hospital_analytics;
-- first we will calculate important kpis and basic analysis for all tables 

-- =====================================================
-- patients table                                      
-- =====================================================
SELECT * FROM patients LIMIT 5;
-- total patients
SELECT  COUNT(*) AS total_patients  FROM patients;
-- average patient age 
SELECT AVG(
    TIMESTAMPDIFF(
        YEAR,
        birth_date,
        COALESCE(death_date, CURDATE())
    )
) AS average_patient_age
FROM patients
WHERE birth_date IS NOT NULL;
-- patient gender distribution
SELECT
    gender,
    COUNT(*) AS patient_count
FROM patients
GROUP BY gender
ORDER BY patient_count DESC;

-- count of patients based on age group

WITH age_values AS (SELECT patient_id,first_name,last_name,TIMESTAMPDIFF(YEAR,birth_date,COALESCE(death_date, CURDATE())
        ) AS age
    FROM patients
),
age_segment as (
SELECT patient_id,first_name,last_name,
CASE WHEN age between 0 and 17 THEN 'Children' 
 WHEN age between 18 and 34 THEN 'young adults' 
 WHEN age between 35 and 49 THEN 'adults' 
 WHEN age between 50 and 64 THEN 'older adult' 
 WHEN age >=65 THEN 'seniors'ELSE 'unknown' END AS age_group 
 FROM age_values)
 SELECT age_group,COUNT(patient_id)AS total_patients FROM age_segment GROUP BY age_group;
 
 -- death patients count and rate 
 SELECT COUNT(death_date) AS recorded_deaths,COUNT(*) AS total_patients,ROUND(100.0 * COUNT(death_date) / NULLIF(COUNT(*), 0),2) AS recorded_death_percentage
FROM patients;
 
-- patients distribution by state or city 
SELECT city ,count(*) AS total_patients FROM patients GROUP BY city  ORDER BY COUNT(patient_id) DESC;

-- average healthcare expenses and coverage
SELECT
    ROUND(AVG(healthcare_expenses),2) AS average_expenses,
    COUNT(healthcare_expenses) AS expense_records,
    ROUND(AVG(healthcare_coverage),2) AS average_coverage,
    COUNT(healthcare_coverage) AS coverage_records
FROM patients;

-- total health_expenses and total_health_coverage 
SELECT SUM(healthcare_expenses) AS total_healthcare_expenses,SUM(healthcare_coverage) AS total_healthcare_coverage FROM patients;

-- patients distribtion by marital status
SELECT marital_status,COUNT(patient_id) AS total_patients
FROM patients
GROUP BY marital_status;

-- invalid birth death date combination
SELECT birth_date as invalid_birth_dates FROM patients where birth_date>death_date OR birth_date is null ;

-- data validation
SELECT * FROM patients WHERE gender is null;
SELECT * FROM patients WHERE birth_date is null;
SELECT * FROM patients WHERE zip is null;
SELECT * FROM patients WHERE marital_status is null;
WITH age_values AS (SELECT *,TIMESTAMPDIFF(YEAR,birth_date,death_date) AS age FROM patients)
SELECT * FROM age_values WHERE age<0;

-- patients distribution by race and ethnicity
SELECT race,count(*) AS number_of_patients FROM patients GROUP BY race;
SELECT ethnicity , count(*) AS number_of_patients FROM patients GROUP BY ethnicity;
SELECT race ,ethnicity , count(*) AS number_of_patients FROM patients GROUP BY race,ethnicity;


-- =====================================================
-- allergies table 
-- =====================================================

SELECT * FROM allergies limit 10;

-- AVG allergies time in days 
SELECT allergy_description,ROUND(AVG(TIMESTAMPDIFF(DAY,allergy_start_date,coalesce(allergy_stop_date,curdate()))),0) AS avg_duration_in_days 
FROM allergies GROUP BY allergy_description;

-- types of allergies
-- gives us name of distinct_allergies
SElECT distinct(allergy_description) FROM allergies;

-- total number of distinct_allergies
SElECT count(distinct(allergy_description)) FROM allergies;

-- total allergy records 
SELECT count(*) AS total_allergy FROM allergies WHERE allergy_description IS NOT NULL;

-- number of uniwue patietns with recorded allergies
SELECT COUNT(DISTINCT(patient_id)) FROM allergies WHERE allergy_description IS NOT NULL;

-- allergies with missing stop date vs allergies with recorded duration
SELECT count(*) AS total_allergies,
SUM(CASE WHEN allergy_stop_date IS NOT NULL THEN 1 ELSE 0 END) AS recorded_allergies,
SUM(CASE WHEN allergy_stop_date IS NULL THEN 1 ELSE 0 END) AS allegies_without_end_date
FROM allergies WHERE allergy_description  IS NOT NULL;


-- =====================================================
--  careplans table
-- =====================================================

SELECT * FROM careplans LIMIT 5;

-- unique names  careplans(types of careplans)
SELECT distinct(care_plan_description) FROM careplans;

-- total careplans records
SELECT count(care_plan_description) AS total_careplans FROM careplans WHERE care_plan_code IS NOT NULL;

-- total unique patients having care plans
SELECT count(distinct(patient_id))  AS total_patients_with_careplans FROM careplans;

-- average careplan duration in days 
SELECT care_plan_description,ROUND(AVG(TIMESTAMPDIFF(DAY,careplan_start_date,careplan_stop_date)),0)  AS average_careplan_duration 
FROM careplans GROUP BY care_plan_description ORDER BY average_careplan_duration DESC;

-- number of careplan by description
SELECT coalesce(care_plan_description,"unknown"),COUNT(*) AS number_of_plans
FROM careplans 
GROUP BY care_plan_description;


-- =====================================================
--  conditions table
-- =====================================================

SELECT * FROM conditions LIMIT 5;

-- total conditions records
SELECT count(*) AS total_conditions_records FROM conditions WHERE condition_description IS NOT NULL;

-- types of conditions 
SELECT count(distinct(condition_description)) AS total_unique_conditions FROM conditions;

-- avg condition_duration 
SELECT round(avg(timestampdiff(day,condition_start_date,condition_stop_date)),0) AS average_condition_duration
FROM conditions WHERE condition_stop_date IS NOT NULL AND condition_start_date<condition_stop_date;

-- avg condition duration by condition_description
SELECT condition_description,ROUND(AVG(TIMESTAMPDIFF(DAY,condition_start_date,condition_stop_date)),0) AS avg_condition_duration 
FROM conditions 
WHERE condition_stop_date IS NOT NULL AND condition_start_date<condition_stop_date
GROUP BY condition_description;

-- unique patients with recorded condition
SELECT COUNT(DISTINCT(patient_id)) AS patient_count FROM conditions WHERE condition_description IS NOT NULL;

-- most frequently recorded condition
SELECT condition_description,COUNT(*) AS  most_frequent_condition FROM conditions WHERE condition_description IS NOT NULL 
GROUP BY condition_description
ORDER BY most_frequent_condition DESC;

-- conditions with missing stop date
SELECT SUM(case when condition_stop_date IS NULL then 1 ELSE 0 END) as conditions_with_missing_stop_dates
,round(avg(timestampdiff(day,condition_start_date,condition_stop_date)),0) AS average_condition_duration
FROM conditions;



-- =====================================================
-- devices table
-- =====================================================

SELECT * FROM devices LIMIT 5;

-- total device records 
SELECT COUNT(*) FROM devices;

-- total number of devices
SELECT count(distinct(device_description)) AS total_devices FROM devices;

-- number of unique patients per device
SELECT device_description,count(distinct(patient_id)) AS unique_patient_per_device FROM devices GROUP BY device_description;

-- total records by device description
SELECT device_description,count(*) AS total_records FROM devices  GROUP BY device_description;


-- =====================================================
-- encounters  table
-- =====================================================
SELECT * FROM encounters LIMIT 20;

-- total encounter records 
SELECT COUNT(encounter_id) AS total_records  FROM encounters;
 
-- total numbers of patients encounter(total number of patients visited)
-- distinct let us ignore same patient visited multiple times 
SELECT count(distinct(patient_id)) AS total_patients_visited_till_now FROM encounters;

--  average encounter_duration in minutes for every patient
-- we can also get the name using joins 
SELECT patient_id ,ROUND(AVG(timestampdiff(minute,encounter_start_date,encounter_stop_date)),0) AS avg_encounter_duration
FROM encounters  GROUP BY patient_id  ;

-- number of encounters by year, month and both
SELECT count(encounter_id) AS number_of_encounters,YEAR(encounter_start_date) AS encounter_year
FROM encounters
GROUP BY encounter_year;

SELECT count(encounter_id) AS number_of_encounters,monthname(encounter_start_date) AS encounter_month
FROM encounters
GROUP BY encounter_month
ORDER BY number_of_encounters DESC;

SELECT count(encounter_id) AS number_of_encounters,CONCAT(YEAR(encounter_start_date)," ",monthname(encounter_start_date)) AS encounter_year_month
FROM encounters
GROUP BY encounter_year_month
ORDER BY number_of_encounters DESC;

-- encounter with missing encounter_stop_date
SELECT COUNT(encounter_id) AS missing_stop_dates FROM encounters WHERE encounter_stop_date IS NULL;

-- count of patients by encounter class
SELECT encounter_class,count(patient_id) AS no_of_patients
FROM encounters GROUP BY encounter_class;

-- patients by encounter_description
SELECT encounter_description,count(patient_id)  FROM encounters
GROUP BY encounter_description ;

-- no of patient by their reason of visit
-- we will handle null value for reason code and descrition here as null can be the reason that the visit was normal visit 
SELECT coalesce(reason_description,"Normal routine"),coalesce(reason_code,"Normal routine"),
count(patient_id) FROM encounters
GROUP BY reason_description,reason_code;

-- total claim till now 
-- WE will use join later for their names and address and organization names also 

SELECT patient_id,SUM(base_encounter_cost) AS total_charge,
SUM(total_claim_cost)AS claimed,SUM(payer_coverage) AS paid_by_organization , SUM(total_claim_cost-payer_coverage) AS remaining FROM encounters
GROUP BY patient_id
ORDER BY remaining DESC;



-- =====================================================
-- imaging_studies
-- =====================================================

SELECT * FROM imaging_studies LIMIT 5;

-- total imaging studies records
SELECT COUNT(*) AS total_imaging_records FROM imaging_studies WHERE imaging_id IS NOT NULL;

-- total unique patients who received imaging_studies
SELECT COUNT(DISTINCT(patient_id)) AS total_patients_received_imaging_studies FROM imaging_studies;

-- patient by type of modality
SELECT modality_description,COUNT(distinct(patient_id)) AS no_of_patients FROM imaging_studies GROUP BY modality_description;

-- studies by modality and body desription
SELECT bodysite_description,modality_code,modality_description,COUNT(*) AS no_of_studies
FROM imaging_studies
GROUP BY bodysite_description,modality_code,modality_description;

-- patient count according to bodysite_descritption and the service_object pair 
SELECT bodysite_description,sop_description AS service_object_pair_description,count(patient_id) as total_patients FROM imaging_studies
GROUP BY  bodysite_description,sop_description;

-- count of patients according to type of procedure by year month 
SELECT modality_description,concat(year(imaging_date)," ",monthname(imaging_date)) AS mm_yyyy ,COUNT(distinct(patient_id)) AS no_of_patients  
FROM imaging_studies 
GROUP BY modality_description,mm_yyyy
ORDER BY mm_yyyy ;

-- missing imaging dates
SELECT COUNT(*) AS missing_imaging_dates FROM imaging_studies WHERE imaging_date IS NULL;

-- missing modality values
SELECT COUNT(*) AS missing_modality_values FROM imaging_studies WHERE modality_code OR modality_description IS NULL;


-- =====================================================
-- immunizations
-- =====================================================

SELECT * FROM immunizations LIMIT 5 ;

-- total immunizations records 
SELECT COUNT(*) FROM immunizations ;

-- unique patients immunized
SELECT COUNT(DISTINCT(patient_id)) AS unique_patient_immunized FROM immunizations;

-- Most frquently recoreded immunizatiosn by count
SELECT immunization_description,COUNT(*) AS recording_count FROM immunizations
WHERE immunization_description IS NOT NULL
GROUP BY immunization_description
ORDER BY recording_count DESC;

-- missing immunizations dates and description
SELECT count(*) AS missing_date FROM immunizations WHERE immunization_date IS NULL;
SELECT count(*) AS missing_description FROM immunizations WHERE immunization_description IS NULL;

-- count of patients that got immunized per month by every year 
SELECT immunization_description,concat(year(immunization_date)," ",monthname(immunization_date)) AS immunization_month,
count(distinct(patient_id)) AS people_immunized FROM immunizations
GROUP BY immunization_description,immunization_month
ORDER BY people_immunized DESC;

-- revenue generated by each immunizations 
SELECT immunization_description, SUM(base_cost) AS total_revenue FROM immunizations
GROUP BY immunization_description;

-- =====================================================
-- medications
-- =====================================================
SELECT * FROM medications LIMIT 5;

-- total medications records
SELECT COUNT(*) AS total_medication_records FROM medications WHERE medication_description IS NOT NULL;

-- medicines genearting  revenue from high to low
SELECT medication_description AS medicine , SUM(total_cost) AS revenue_generated
FROM medications
GROUP BY medicine
ORDER BY revenue_generated DESC;

-- medicines and their average duration in days 
SELECT medication_description AS medicine,ROUND(AVG(TIMESTAMPDIFF(DAY,medication_start_date,medication_stop_date)),0) AS avg_medication_duration
FROM  medications WHERE medication_stop_date IS NOT NULL
GROUP BY medicine;



-- count of medications records by payer
SELECT payer_id,COUNT(*) AS medication_records FROM medications
GROUP BY payer_id
ORDER BY medication_records DESC;


-- =====================================================
-- observations
-- =====================================================

SELECT * FROM observations LIMIT 7;

-- total observations
SELECT COUNT(*) AS total_observation_records
FROM observations;

-- number of patients by types of observations
SELECT observation_type,COUNT(patient_id) AS total_patients  
FROM observations
GROUP BY observation_type;

-- patient_count by observation description
SELECT observation_description AS observation_type,COUNT(patient_id) AS patient_count
FROM observations GROUP BY observation_description
ORDER BY patient_count DESC;

-- avg patient weight
SELECT ROUND(avg(observation_value),2) AS avg_weight FROM observations WHERE observation_units ="Kg";

-- missing observation values
SELECT count(*) AS missing_oservation_values FROM observations WHERE observation_value IS NULL;

-- average value by type and units
SELECT observation_type,observation_units,ROUND(avg(observation_value),2) AS avg_value
FROM observations
GROUP BY observation_type,observation_units;

-- =====================================================
-- organizations
-- =====================================================
SELECT * FROM organizations limit 7 ;


-- no of organizations
SELECT COUNT(organization_name) AS no_of_organizations FROM organizations ;

-- count of total organizations based on organization name 
SELECT organization_name,COUNT(*) AS total_organizations
FROM organizations 
GROUP BY organization_name
ORDER BY total_organizations DESC;

-- total utilization or patients_handled by each organization
SELECT organization_name,SUM(utilization) AS patients_handled
FROM organizations
GROUP BY organization_name
ORDER BY patients_handled DESC;

-- organization with missing address
SELECT organization_name FROM organizations WHERE address IS NULL;

-- number of organization present in each city 
SELECT city ,COUNT(organization_id) AS number_of_organizations  FROM organizations
GROUP BY city
ORDER BY number_of_organizations DESC;

-- revenue generated by each organizations
SELECT organization_name,SUM(revenue)AS revenue_generated FROM organizations
GROUP BY organization_name
ORDER BY revenue_generated DESC;



-- =====================================================
-- payer_transitions
-- =====================================================
SELECT * FROM payer_transitions LIMIT 7;

-- total payer_transitions records
SELECT COUNT(*) FROM payer_transitions;

-- no.unique payer
SELECT COUNT(DISTINCT(payer_id)) FROM payer_transitions;

-- types of ownership
SELECT distinct(ownership) FROM payer_transitions;

-- patients with transition records 
SELECT COUNT(distinct(patient_id))  AS unique_patients_records FROM payer_transitions WHERE payer_id  IS NOT NULL;

-- record by ownership type
SELECT ownership,count(*) AS total_records FROM payer_transitions
GROUP BY ownership;

-- missing payer_id
SELECT * FROM payer_transitions WHERE payer_id IS NULL;

-- =====================================================
-- payers
-- =====================================================

SELECT * FROM payers LIMIT 5 ;

-- total payer records 
SELECT COUNT(*) AS total_records FROM payers;


 -- payer and revenue generated
 SELECT payer_name AS payer_company, SUM(revenue) AS total_revenue_generated FROM payers
 GROUP BY payer_name;
 
 -- no of insurance company per city
 SELECT city,COUNT(payer_name) AS number_of_companies 
 FROM payers GROUP BY city
 ORDER BY number_of_companies DESC;
 
 -- total covered and uncovered amount
 SELECT SUM(amount_covered) AS amount_covered,SUM(amount_uncovered) AS amount_uncovered FROM payers;
 
 
 -- =====================================================
 -- procedures
 -- =====================================================
 SELECT * FROM procedures LIMIT 8;

-- total procedure records
SELECT COUNT(*) AS total_procedures_records FROM procedures ;

-- count of patient by name of procedure
SELECT procedure_description as procedure_name, COUNT(patient_id) AS no_of_patients FROM 
procedures GROUP BY procedure_name
ORDER BY no_of_patients DESC ;

-- revenue generated by each  procedure
SELECT  procedure_description as procedure_name,SUM(base_cost) AS total_cost FROM 
procedures GROUP BY procedure_description 
ORDER BY total_cost DESC;

-- no of procedures happend by year-month wise
WITH date_procedures AS (SELECT year(procedure_date) AS procedure_year,monthname(procedure_date) AS procedure_month, month(procedure_date) AS month_number,
COUNT(distinct(procedure_description)) AS procedure_happened
FROM procedures
GROUP BY procedure_year,procedure_month,month_number
ORDER BY procedure_year,month_number)
SELECT concat(procedure_year," ",procedure_month) AS procedure_year_month,procedure_happened FROM date_procedures;

-- missing procedure dates
SELECT * FROM procedures WHERE procedure_date IS NULL;


-- =====================================================
-- providers
-- =====================================================

SELECT * FROM providers LIMIT 8;

-- total providers records
SELECT count(*) AS total_records FROM providers;

-- no of treatment_providers by gender
SELECT gender,COUNT(distinct(provider_name)) AS no_of_treatment_providers FROM providers
GROUP BY gender;

-- no of treatment_providers and their speciality
SELECT speciality,COUNT(distinct(provider_name)) AS no_of_treatment_providers
FROM providers
GROUP BY speciality;
 -- no of treatment providers available in each city
 SELECT city,COUNT(distinct(provider_name)) AS no_of_treatment_providers
FROM providers
GROUP BY city;
 
 -- no of treatment providers by gender and speciality
 SELECT gender,speciality,COUNT(distinct(provider_name)) AS provider FROM providers
GROUP BY gender,speciality;

-- providers with missing speciality
SELECT * FROM providers WHERE speciality IS NULL;
 
 --  =====================================================
 -- supplies table
 -- =====================================================
 
 SELECT * FROM supplies;
 
-- it's empty 







































































