# Web-Scrapping-for-arXiv.org
Using R to check the update of the CS papers and get the meta data of the papers from arXiv.org.

#### This is a project of building a pipeline to access the data from the webpage https://arxiv.org/list/cs/new, which updates and shares the new submitted papers from the Computer Science arXiv, which is currently hosted by Cornell University. The meta data would be scrapped down and updated to a table called "cs_paper_meta" in postgreSQL database. Moreover, to track the update of the paper, Apache Airflow is used to schedule the R script overtime with a sample DAG file.

### Prerequsites of the project
1. R with package rvest, stringr, RPostgreSQL
2. PostgreSQL
3. Apache Docker and Airflow

### R Script for Scrapping Paper Information from Archive.R/Rmd
These two files are almost the same, both containing the important functions for scrapping the meta data from the website nad updating the database in postgreSQL:
1. get.new.num()
2. get.first.N.paper()
3. get.last.N.paper()
4. get.all.paper()
5. pass.new.submission()
6. main.paper.update()

The difference between them is that the Rmarkdown contains more comments and test code for you to make sure the execution of the code, while the R script only runs the main.paper.update() at the end of th script and will be passed to the DAG file for scheduling.

### DAG_try.py
This is a Python file used for scheduling in Apache Airflow, inspired from the schedular example of the online tutorial https://www.shizidushu.com/2019/03/03/schedule-r-script-with-docker-and-airflow/.  

### NLP and Topic Modeling
The CSV file "paper0628To0702.csv" contains the meta data for 670 new submitted papers from June 28 to July 2. Based on the paper titles and description, text mining and topic modeling using LDA are conducted, where the code file is "NLP and Topic Modeling.R" and the output file is "Output of NLP and Topic Modeling.html". Based on the wordcloud and the topic models, we can see that deep learning with neural network is still the hottest topic. Moreover, the study of the adversarial problem of the graphs or image analysis is one of the most popular topic in the DL study.
