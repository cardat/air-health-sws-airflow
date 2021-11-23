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
    'install_R_packages',
    default_args=def_args,
    description='Install R packages from an R installation script',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['data', 'sync', 'R', 'installation'],
) as dag:

    PATH_TO_INSTALL_SCRIPT = "/mnt/data/repos/air-health-sws-airflow/test_scripts/install.R"

    task = BashOperator(
        task_id="installing_R_packages_using_script",
        bash_command="""
            set -euo pipefail;
            echo "Installing R packages using";
            echo "{{ params.path_print }}";
            Rscript "{{ params.path }}"
        """,
        params={
            'path': os.path.basename(PATH_TO_INSTALL_SCRIPT),
            'path_print': PATH_TO_INSTALL_SCRIPT,
        },
        cwd=os.path.dirname(PATH_TO_INSTALL_SCRIPT),
    )
