import os

from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.bash import BashOperator
from airflow.models import Variable

from datetime import timedelta


def_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['admin@myemail.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    'pipeline_NRDE_CBA',
    default_args=def_args,
    description='Run the NRDE CBA pipeline given a file location with the code',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['data', 'R', 'pipeline', 'NRDE'],
) as dag:

    PIPELINE_PATH = "/mnt/data/repos/air-health-sws-airflow/NRDE_CBA_scripts/NRDE_CBA_main.R"
    DATA_ROOT = "/mnt/data/cloudstor-data/Shared/"

    task = BashOperator(
        task_id="Running_NRDE_CBA_main",
        bash_command="""
            set -euo pipefail;
            Rscript "{{ params.path }}" -d "{{ params.data_path }}"
        """,
        params={
            'path': os.path.basename(PIPELINE_PATH),
            'data_path': DATA_ROOT,
        },
        cwd=os.path.dirname(PIPELINE_PATH),
    )
