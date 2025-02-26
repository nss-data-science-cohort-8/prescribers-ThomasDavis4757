SELECT *
FROM prescriber


-- 1a - Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.



SELECT p1.npi, SUM(p2.total_claim_count) AS total_claims
FROM prescriber AS p1
INNER JOIN prescription AS p2
ON p1.npi = p2.npi
GROUP BY p1.npi
ORDER BY total_claims DESC
LIMIT 1;

-- The npi was 1881634483 and the total number of claims overall was 99707.


-- 1b - Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT p1.npi, p1.nppes_provider_first_name, p1.nppes_provider_last_org_name, p1.specialty_description, SUM(p2.total_claim_count) AS total_claims
FROM prescriber AS p1
INNER JOIN prescription AS p2
ON p1.npi = p2.npi
GROUP BY p1.npi,  p1.nppes_provider_first_name, p1.nppes_provider_last_org_name, p1.specialty_description
ORDER BY total_claims DESC
LIMIT 1;

-- The npi was 1881634483, the first name was bruce, the last name was pendley, and the specialty was family practice with 99707 claims. 

--2a - Which specialty had the most total number of claims (totaled over all drugs)?

SELECT SUM(p2.total_claim_count) AS total_claims, p1.specialty_description
FROM prescriber AS p1
INNER JOIN prescription AS p2
ON p1.npi = p2.npi
GROUP BY p1.specialty_description
ORDER BY total_claims DESC
LIMIT 1;

-- Family Practice had the largest number of claims over all types of drugs

-- 2b - Which specialty had the most total number of claims for opioids?

SELECT p1.specialty_description, SUM(p2.total_claim_count) AS total_claims
FROM prescriber AS p1
INNER JOIN prescription AS p2
ON p1.npi = p2.npi
LEFT JOIN drug AS d
ON p2.drug_name = d.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY p1.specialty_description
ORDER BY total_claims DESC;

-- Nurse Practitioner had the most total number of claims for opioids. (Why are there added rows after left merge with drug?)

