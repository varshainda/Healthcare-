create database healthcare;
use healthcare;

-- Imported Data using Import Wizard
select count(*) from patient;
select * from patient;
show columns from patient;

-- Removing Special Characters from column name
Alter table patient
rename column `ï»¿Patient ID` to PatientID;
Alter table doctor
rename column `ï»¿Doctor ID` to DoctorID;
Alter table lab_results
rename column `ï»¿Lab Result ID` to LabResultID;
Alter table treatments
rename column `ï»¿Treatment ID` to TreatmentID;
Alter table visit
rename column `ï»¿Visit ID` to VisitID;

-- Changing DOB datatype
Alter table patient
Modify column DateOfBirth date;

-- Changing Visit Date datatype
Alter table visit
Modify column `Visit Date` date;

-- Adding new column in treatments table for total cost
Alter table treatments
add column Total_Cost double;

SET SQL_SAFE_UPDATES =0;

update treatments
set Total_Cost= `Treatment Cost`+ Cost;

SET SQL_SAFE_UPDATES =1;


-- QA Queries
-- 1. Data Count Validation
-- Ensure record counts match between the database and reports.
SELECT COUNT(*) FROM Patient;
SELECT COUNT(*) FROM Visit;
SELECT COUNT(*) FROM Treatments;

-- 2. Data Completeness Check
-- Identify missing or null values in key columns
SELECT * FROM Patient WHERE FirstName IS NULL OR LastName IS NULL;
SELECT * FROM Visit WHERE `Visit Type` IS NULL OR `Visit Date` IS NULL;
SELECT * FROM Treatments WHERE `Treatment Name` IS NULL OR Status IS NULL;
SELECT * FROM LabResult WHERE TestName IS NULL OR Result IS NULL;

-- 3. Data Consistency Check
-- Ensure data relationships are consistent across tables.
SELECT v.VisitID, v.`Patient ID`, p.PatientID
FROM Visit v
LEFT JOIN Patient p ON v.`Patient ID` = p.PatientID
WHERE p.PatientID IS NULL;  -- Should return 0 rows

SELECT t.TreatmentID, t.`Visit ID`, v.VisitID
FROM Treatments t
LEFT JOIN Visit v ON t.`Visit ID` = v.VisitID
WHERE v.VisitID IS NULL;  -- Should return 0 rows

-- 4. Duplicate Records Check
-- Identify duplicate entries in key tables.
SELECT PatientID, COUNT(*)
FROM Patient
GROUP BY PatientID
HAVING COUNT(*) > 1;

SELECT VisitID, COUNT(*)
FROM Visit
GROUP BY VisitID
HAVING COUNT(*) > 1;

-- 5. Dashboard Aggregation Check
SELECT SUM(TreatmentCost) FROM Treatments;  
SELECT AVG(Age) FROM Patient;  

-- 6. Performance Testing (Query Execution Time)
-- Check query performance and optimize if needed.
EXPLAIN ANALYZE
SELECT * FROM Visit WHERE `Visit Date` BETWEEN '2023-01-01' AND '2023-12-31';


-- Healthcare Analysis 
-- KPI
-- 1. Total Patients
   select count(PatientID) as "Total Patients" from patient;
   
-- 2. Total Doctors
   select count(DoctorID) as "Total Doctors" from doctor;
   
-- 3. Total Visits
   select count(VisitID) as "Total Visits" from visit;
   
-- 4. Average Age of Patients
   -- select round(avg(datediff(current_date(),DateOfBirth)/365)) as "Average Age of Patients" from patient;
   select round(avg(Age)) as "Average Age of Patients" from patient;
   
-- 5. Top 5 Diagnosed Conditions
select Diagnosis,count(Diagnosis) as Count from visit
group by Diagnosis
order by Count DESC
limit 5; 

-- 6. Follow-Up Rate
select 
ROUND(SUM(
case
when `Follow Up Required`= 'Yes' then 1
else 0
END)/count(*)*100,1) as "Follow Up Rate(%)" 
from visit;

-- 7.Average Treatment Cost per Visit
select round(avg(`Treatment Cost`)) as "Average Treatment Cost Per Visit($)" from treatments ;

-- 8. Total Lab Test Conducted
select count(LabResultID) as "Total Lab Tests"from lab_results;

-- 9. Percentage of abnormal lab results
select round(sum(
case
when Result='Abnormal' then 1 else 0
end)/count(LabResultID)*100,1) 
as "Abnormal Lab Result %"
from lab_results;

-- 10. Doctor Workload (Avg Patients Per Doctor)
select round(count(distinct VisitID)/count(distinct `Doctor ID`)) as "Doctor Workload" from visit;

-- Patent Visit Summary
SELECT concat(Patient.FirstName," ",patient.LastName) as "Patient Name", Visit.`Visit Date`,Visit.`Reason For Visit`,visit.Diagnosis,Treatments.`Medication Prescribed`,Lab_Results.`Test Name`,Lab_Results.Result
FROM Patient
JOIN Visit ON Patient.PatientID = Visit.`Patient ID`
LEFT JOIN Treatments ON Visit.VisitID = Treatments.`Visit ID`
LEFT JOIN Lab_Results ON Visit.VisitID = Lab_Results.`Visit ID`;








