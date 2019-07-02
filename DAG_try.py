from airflow import DAG
from airflow.operators.docker_operator import DockerOperator
from datetime import datetime, timedelta
import os

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2019, 7, 1, 17, 30),
    'email_on_failure': True,
    'email_on_retry': True,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'schedule_interval': '@hourly'
}

dag = DAG(
    dag_id='r-script',
    default_args=default_args)

test = DockerOperator(
    api_version='auto',
    image='rocker/r-ver',
    network_mode='bridge',
    volumes=[os.path.join(os.environ['DOCKER_VOLUME_BASE'], 'input', 'rscript') + ':/root/rscript'],
    command='Rscript R-Script-for-Scrapping-Paper-Information-from-Archive.R -d',
    task_id='run-r-script',
    working_dir='~/Downloads/Web-Scrapping-for-arXiv.org-master',
    dag=dag)