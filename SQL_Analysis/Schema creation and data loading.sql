CREATE DATABASE IF NOT EXISTS hospital_analytics;
USE hospital_analytics;

-- =====================================================
-- Synthea EHR dataset: MySQL schema (16 tables)
-- Tables are created here and we will load data in these tables through data we have in our notebook using pandas 
-- =====================================================

-- 1. PAYERS
CREATE TABLE payers (
    payer_id                CHAR(36) PRIMARY KEY,
    payer_name                    VARCHAR(150),
    address                 VARCHAR(150),
    city                    VARCHAR(100),
    state_headquartered     VARCHAR(50),
    zip                     VARCHAR(10),
    phone                   VARCHAR(30),
    amount_covered          DECIMAL(18,2),
    amount_uncovered        DECIMAL(18,2),
    revenue                 DECIMAL(18,2),
    covered_encounters      INT,
    uncovered_encounters    INT,
    covered_medications     INT,
    uncovered_medications   INT,
    covered_procedures      INT,
    uncovered_procedures    INT,
    covered_immunizations   INT,
    uncovered_immunizations INT,
    unique_customers        INT,
    qols_avg                DECIMAL(12,6),
    member_months           INT
);

-- 2. ORGANIZATIONS
CREATE TABLE organizations (
    organization_id    CHAR(36) PRIMARY KEY,
    organization_name  VARCHAR(255),
    address            VARCHAR(255),
    city               VARCHAR(100),
    state              VARCHAR(50),
    zip                VARCHAR(10),
    latitude           DECIMAL(10,7),
    longitude          DECIMAL(11,7),
    phone              VARCHAR(50),
    revenue            DECIMAL(18,2),
    utilization        INT
);

-- 3. PATIENTS
CREATE TABLE patients (
    patient_id              CHAR(36) PRIMARY KEY,
    birth_date              DATE,
    death_date              DATE,
    social_security_number  VARCHAR(20),
    drivers                 VARCHAR(30),
    passport                VARCHAR(30),
    prefix                  VARCHAR(10),
    first_name              VARCHAR(100),
    last_name               VARCHAR(100),
    suffix                  VARCHAR(10),
    maiden_name             VARCHAR(100),
    marital_status          VARCHAR(20),
    race                    VARCHAR(30),
    ethnicity               VARCHAR(50),
    gender                  VARCHAR(10),
    birthplace              VARCHAR(255),
    address                 VARCHAR(255),
    city                    VARCHAR(100),
    state                   VARCHAR(50),
    county                  VARCHAR(100),
    zip                     VARCHAR(10),
    latitude                DECIMAL(10,7),
    longitude               DECIMAL(11,7),
    healthcare_expenses     DECIMAL(15,2),
    healthcare_coverage     DECIMAL(15,2)
);

-- 4. PROVIDERS
CREATE TABLE providers (
    provider_id      CHAR(36) PRIMARY KEY,
    organization_id  CHAR(36),
    provider_name             VARCHAR(150),
    gender           VARCHAR(10),
    speciality       VARCHAR(100),
    address          VARCHAR(255),
    city             VARCHAR(100),
    state            VARCHAR(50),
    zip              VARCHAR(10),
    latitude         DECIMAL(10,7),
    longitude        DECIMAL(11,7),
    utilization      INT,
    FOREIGN KEY (organization_id)
        REFERENCES organizations(organization_id)
);

-- 5. ENCOUNTERS
CREATE TABLE encounters (
    encounter_id          CHAR(36) PRIMARY KEY,
    encounter_start_date  DATETIME,
    encounter_stop_date   DATETIME,
    patient_id            CHAR(36),
    organization_id          CHAR(36),
    provider_id              CHAR(36),
    payer_id                 CHAR(36),
    encounter_class       VARCHAR(30),
    encounter_code                  VARCHAR(50),
    encounter_description           VARCHAR(255),
    base_encounter_cost   DECIMAL(12,2),
    total_claim_cost      DECIMAL(12,2),
    payer_coverage        DECIMAL(12,2),
    reason_code           VARCHAR(50),
    reason_description    VARCHAR(255),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (organization_id)
        REFERENCES organizations(organization_id),
    FOREIGN KEY (provider_id)
        REFERENCES providers(provider_id),
    FOREIGN KEY (payer_id)
        REFERENCES payers(payer_id)
);

-- 6. ALLERGIES
CREATE TABLE allergies (
    allergy_start_date  DATE,
    allergy_stop_date   DATE,
    patient_id          CHAR(36),
    encounter_id        CHAR(36),
    allergy_code                VARCHAR(50),
    allergy_description         VARCHAR(255),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- 7. CAREPLANS
CREATE TABLE careplans (
    care_plan_id         CHAR(36) PRIMARY KEY,
    careplan_start_date  DATE,
    careplan_stop_date   DATE,
    patient_id           CHAR(36),
    encounter_id         CHAR(36),
    care_plan_code                 VARCHAR(50),
    care_plan_description          VARCHAR(255),
    reason_code          VARCHAR(50),
    reason_description   VARCHAR(255),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- 8. CONDITIONS
CREATE TABLE conditions (
    condition_start_date  DATE,
    condition_stop_date   DATE,
    patient_id            CHAR(36),
    encounter_id          CHAR(36),
    condition_code        VARCHAR(50),
    condition_description VARCHAR(255),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- 9. DEVICES
CREATE TABLE devices (
    device_start_date  DATETIME,
    device_stop_date   DATETIME,
    patient_id         CHAR(36),
    encounter_id       CHAR(36),
    device_code        VARCHAR(50),
    device_description VARCHAR(255),
    udi                VARCHAR(255),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- 10. IMAGING STUDIES
CREATE TABLE imaging_studies (
    imaging_id            CHAR(36) PRIMARY KEY,
    imaging_date          DATETIME,
    patient_id            CHAR(36),
    encounter_id          CHAR(36),
    bodysite_code         VARCHAR(50),
    bodysite_description  VARCHAR(150),
    modality_code         VARCHAR(20),
    modality_description  VARCHAR(100),
    sop_code              VARCHAR(50),
    sop_description       VARCHAR(255),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- 11. IMMUNIZATIONS
CREATE TABLE immunizations (
    immunization_date  DATETIME,
    patient_id         CHAR(36),
    encounter_id       CHAR(36),
    immunization_code  VARCHAR(50),
    immunization_description VARCHAR(255),
    base_cost          DECIMAL(12,2),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- 12. MEDICATIONS
CREATE TABLE medications (
    medication_start_date  DATETIME,
    medication_stop_date   DATETIME,
    patient_id             CHAR(36),
    payer_id               CHAR(36),
    encounter_id           CHAR(36),
    medication_code        VARCHAR(50),
    medication_description VARCHAR(255),
    base_cost              DECIMAL(12,2),
    payer_coverage          DECIMAL(12,2),
    dispenses              INT,
    total_cost             DECIMAL(12,2),
    reason_code            VARCHAR(50),
    reason_description     VARCHAR(255),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (payer_id)
        REFERENCES payers(payer_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- 13. OBSERVATIONS
CREATE TABLE observations (
    observation_date  DATETIME,
    patient_id        CHAR(36),
    encounter_id      CHAR(36),
    observation_code  VARCHAR(50),
    observation_description     VARCHAR(255),
    observation_value           VARCHAR(255),
    observation_units           VARCHAR(50),
    observation_type            VARCHAR(30),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- 14. PAYER TRANSITIONS
CREATE TABLE payer_transitions (
    patient_id     CHAR(36),
    payer_id       CHAR(36),
    start_year     INT,
    end_year       INT,
    ownership      VARCHAR(50),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (payer_id)
        REFERENCES payers(payer_id)
);

-- 15. PROCEDURES
CREATE TABLE procedures (
    procedure_date      DATETIME,
    patient_id          CHAR(36),
    encounter_id        CHAR(36),
    procedure_code      VARCHAR(50),
    procedure_description VARCHAR(255),
    base_cost           DECIMAL(12,2),
    reason_code         VARCHAR(50),
    reason_description  VARCHAR(255),
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- 16. SUPPLIES
CREATE TABLE supplies (
    supply_date       DATETIME,
    patient_id      CHAR(36),
    encounter_id    CHAR(36),
    supply_code         VARCHAR(50),
    supply_description  VARCHAR(255),
    quantity     INT,
    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),
    FOREIGN KEY (encounter_id)
        REFERENCES encounters(encounter_id)
);

-- checking if data is loaded perfectly

select * from allergies limit 5;
select * from careplans limit 5;
select * from conditions limit 5;
select * from devices limit 5;
select * from encounters limit 5;
select * from imaging_studies limit 5;
select * from immunizations limit 5;
select * from medications limit 5;
select * from observations limit 5;
select * from patients limit 5;
select * from payer_transitions limit 5;
select * from payers limit 5;
select * from procedures limit 5;
select * from providers limit 5;
select * from supplies limit 5;
