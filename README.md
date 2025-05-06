# 📊 Netflix ELT Data Pipeline Project

A complete ELT (Extract, Load, Transform) pipeline for analyzing Netflix’s global content catalog using SQL and structured modeling techniques. This project demonstrates building analytical tables, cleaning and transforming raw data, and enabling insights into platform content trends.

---

## 🚀 Project Overview

This project is focused on turning unstructured Netflix data into a structured format for analysis. It follows the ELT paradigm:

- **Extract**: Load the raw Netflix dataset from Kaggle.
- **Load**: Insert into normalized tables with `CREATE TABLE` and `INSERT INTO`.
- **Transform**: Perform SQL operations to derive analytics-ready tables and insights.

---

## 🔧 Tech Stack

- **SQL (Standard/BigQuery-style)**  
- **Data Modeling (Star Schema)**  
- **Jupyter Notebook**  
- **Pandas (optional preprocessing)**  

---

## 📁 Dataset

- Source: [Netflix Dataset on Kaggle](https://www.kaggle.com/shivamb/netflix-shows)

Includes fields like `title`, `type`, `director`, `cast`, `country`, `release_year`, `rating`, and `listed_in`.

---

## 🛠️ Key Features

- Designed **normalized schemas** for dimensional analysis.
- Used SQL for **transformation logic** (e.g., `CASE`, `JOIN`, `DATE`, `SUBSTRING`, window functions).
- Created **dimension and fact tables** for:
  - Genres  
  - Countries  
  - Durations  
  - Content Type  
  - Release Year  
- Identified **platform trends**: genre popularity, regional distributions, and temporal shifts in content.

---

## 📌 Author

**Aman Dubey**  
📫 [LinkedIn](https://www.linkedin.com/in/aman-dubey01)

