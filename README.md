# Web-Scrapping-for-arXiv.org
Using R to check the update of the CS papers and get the meta data of the papers from arXiv.org.

#### This is a project of building a pipeline to access the data from the webpage https://arxiv.org/list/cs/new, which updates and shares the new submitted papers from the Computer Science arXiv, which is currently hosted by Cornell University. The meta data would be scrapped down and updated to a table called "cs_paper_meta" in postgreSQL database. Moreover, to track the update of the paper, Apache Airflow is used to schedule the R script overtime with a sample DAG file.

### Prerequsites of the project
1. R with package rvest, stringr, RPostgreSQL
2. PostgreSQL
3. Apache Airflow
