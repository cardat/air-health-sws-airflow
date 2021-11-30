from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.bash import BashOperator

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
    'run_R_script_example',
    default_args=def_args,
    description='Run an R script',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['R', 'example'],
) as dag:
    task = BashOperator(
        task_id="run_R_script_example_task",
        bash_command="""
            Rscript -e 'message("Hello world!")'
        """
    )
