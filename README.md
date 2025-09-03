# AE-Table-Generation-from-ADaM-ADSL-ADAE-Datasets

This project demonstrates how to generate **Adverse Event (AE) summary tables** using **ADaM datasets (ADSL and ADAE)**, which are commonly required in **Clinical Study Reports (CSR)**.  

The workflow replicates regulatory-compliant safety reporting by:  
- Using **ADSL (Subject-Level Analysis Dataset)** to derive treatment population counts.  
- Using **ADAE (Adverse Events Analysis Dataset)** to summarize adverse events by subject, treatment arm, and severity.  
- Producing formatted **AE incidence tables** similar to those submitted in regulatory filings.  


**SAS Procedures Used**:  
  - `PROC FREQ` → AE counts & percentages  
  - `PROC MEANS` / `PROC SUMMARY` → treatment population totals  
  - `PROC REPORT` → CSR-style AE summary tables  
