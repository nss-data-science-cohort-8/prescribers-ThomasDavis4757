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

-- 3a - Which drug (generic_name) had the highest total drug cost?

SELECT d.generic_name, sum(total_drug_cost)
FROM prescription AS p1
LEFT JOIN drug AS d
ON p1.drug_name = d.drug_name
GROUP BY d.generic_name
ORDER BY sum DESC;

-- INSULIN glargine, hum.rec.anlog (just insulin?) had the highest total drug cost.

-- 3b - Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

SELECT d.generic_name, ROUND(sum((p1.total_drug_cost / p1.total_claim_count) * p1.total_day_supply),2) AS total_cost_per_day
FROM prescription AS p1
LEFT JOIN drug AS d
ON p1.drug_name = d.drug_name
GROUP BY d.generic_name
ORDER BY total_cost_per_day DESC;

-- 4a -  For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

SELECT *
from drug;


SELECT drug_name, CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' ELSE 'neither' END AS drug_type
FROM drug;

-- 4b - Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT  d.drug_type, SUM(p1.total_drug_cost)
FROM prescription AS p1
LEFT JOIN(
	SELECT drug_name, CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' ELSE 'neither' END AS drug_type
	FROM drug
) AS d
ON p1.drug_name = d.drug_name
GROUP BY drug_type
ORDER BY sum DESC;


-- 5a - How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

-- STRING_SPLIT('YourTextToSplit', ' ')

SELECT COUNT(DISTINCT(cbsa)) 
from cbsa
WHERE split_part(cbsaname, ', ',2) = 'TN';

-- There are 6 CBSA's in tennessee.

-- 5b - Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT c.cbsaname, SUM(population)
FROM cbsa as c
LEFT JOIN population AS p
ON c.fipscounty = p.fipscounty
WHERE p.population IS NOT NULL
GROUP BY cbsaname
ORDER BY SUM(COALESCE(p.population, 0))DESC
LIMIT 1;

SELECT c.cbsaname, SUM(population)
FROM cbsa as c
LEFT JOIN population AS p
ON c.fipscounty = p.fipscounty
WHERE p.population IS NOT NULL
GROUP BY cbsaname
ORDER BY SUM(COALESCE(p.population, 0))
LIMIT 1;

-- Nashville-Davidson-Murfreesboro-Franklin TN has the largest combined population with 1,830,410, and Morristown, TN had the smallest population with 116,352.

-- 5c - What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.


SELECT p.population, fc.county
FROM(
	SELECT *
	FROM population AS p
	EXCEPT
	SELECT *
	FROM (
		SELECT cb.fipscounty, pop.population
		FROM cbsa as cb
		LEFT JOIN population AS pop
		ON cb.fipscounty = pop.fipscounty
		) AS c
) AS p
LEFT JOIN fips_county AS fc
ON fc.fipscounty = p.fipscounty
ORDER BY population DESC
LIMIT 1;

-- The largest county not in the CBSA is sevier with 95,523


-- 6 - a Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.


SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000


-- 6b -  For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT  d.drug_name, p1.total_claim_count, d.opioid_drug_flag
FROM prescription AS p1
LEFT JOIN drug AS d
ON p1.drug_name = d.drug_name
WHERE total_claim_count >= 3000

-- 6c - Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT  d.drug_name, p1.total_claim_count, d.opioid_drug_flag, p1.npi, p2.nppes_provider_last_org_name AS last_name, p2.nppes_provider_first_name AS first_name
FROM prescription AS p1
LEFT JOIN drug AS d
ON p1.drug_name = d.drug_name
LEFT JOIN prescriber AS p2
ON p1.npi = p2.npi
WHERE total_claim_count >= 3000;



-- 7a - First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


SELECT p.npi, d.drug_names
FROM(
	SELECT DISTINCT(npi)
	FROM prescriber
	WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE'
) AS p
CROSS JOIN (
	SELECT DISTINCT(drug_name) AS drug_names
	FROM drug
	WHERE opioid_drug_flag = 'Y'
) AS d


-- 7b - Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p1.npi, p1.drug_names, p2.total_claim_count
FROM(
	SELECT p.npi, d.drug_names
	FROM(
		SELECT DISTINCT(npi)
		FROM prescriber
		WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE'
	) AS p
	CROSS JOIN (
		SELECT DISTINCT(drug_name) AS drug_names
		FROM drug
		WHERE opioid_drug_flag = 'Y'
	) AS d
) AS p1
LEFT JOIN prescription AS p2
ON p1.npi = p2.npi AND p1.drug_names = p2.drug_name

-- 7c - Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT p1.npi, p1.drug_names, COALESCE(p2.total_claim_count, 0) AS total_claim_count
FROM(
	SELECT p.npi, d.drug_names
	FROM(
		SELECT DISTINCT(npi)
		FROM prescriber
		WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE'
	) AS p
	CROSS JOIN (
		SELECT DISTINCT(drug_name) AS drug_names
		FROM drug
		WHERE opioid_drug_flag = 'Y'
	) AS d
) AS p1
LEFT JOIN prescription AS p2
ON p1.npi = p2.npi AND p1.drug_names = p2.drug_name