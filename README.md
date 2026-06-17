# NBA Defense Analytics Project

## Overview

This project analyzes the relationship between regular-season team performance metrics and playoff success in the NBA from 2006–2025. The primary goal was to investigate whether strong defensive performance is a reliable predictor of deep playoff runs and championship success.

The project was inspired by the long-standing basketball phrase:

**“Defense wins championships.”**

This analysis attempts to evaluate how true that statement is using historical team data, advanced metrics, and playoff results.

---

## Research Question

* Does strong defense significantly improve playoff success?
* Is defensive performance a stronger predictor of championships than offensive performance?
* Which team metrics are most associated with deep postseason runs?

---

## Project Workflow

### 1. Data Collection

Historical NBA regular-season statistics and playoff results were collected using a custom Python web scraper from Basketball Reference.

### 2. Data Cleaning & Preparation

Raw data was cleaned, standardized, and transformed for analysis.

Key preprocessing steps included:

* Cleaning multi-level table headers
* Parsing hidden HTML tables
* Normalizing historical franchise names
* Extracting playoff series outcomes using regex
* Merging playoff and regular-season datasets

### 3. SQL Analysis

SQL was used to clean, aggregate, and analyze the merged dataset.

Queries explored relationships between:

* Defensive Rating (DRtg)
* Offensive Rating (ORtg)
* Net Rating (NRtg)
* Four Factors metrics
* Playoff advancement

### 4. Data Visualization

Query outputs were exported into Tableau to build interactive dashboards for analysis.

---

## Technical Challenges

This project involved several real-world data engineering challenges:

* Some Basketball Reference tables were hidden inside HTML comments and required BeautifulSoup parsing before extraction.
* Playoff data was not structured in clean tabular form and required regex-based parsing.
* Franchise name changes across seasons required normalization for consistent longitudinal analysis.
* Multiple datasets had to be cleaned and merged while preserving season-level integrity.

---

## Tools Used

### Python

* Pandas
* Requests
* BeautifulSoup
* Regex

### Data / Analytics

* SQL
* Tableau

### Version Control

* Git / GitHub

---

## Key Findings

* Strong defensive teams generally performed better in the postseason.
* However, defensive performance alone did not consistently predict championship outcomes.
* Teams with strong **overall balance**—particularly high Net Rating (NRtg)—performed best.
* Championship teams were typically elite in both offensive and defensive efficiency.

### Conclusion

The data suggests that defense plays a major role in playoff success, but the phrase **“defense wins championships”** is somewhat overstated.

A more accurate conclusion is:

**The best championship teams are usually elite on both offense and defense, rather than relying heavily on one side of the ball.**

---

## Interactive Dashboard

Tableau Dashboard:
https://public.tableau.com/views/NBADefenseAnalysis/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link

