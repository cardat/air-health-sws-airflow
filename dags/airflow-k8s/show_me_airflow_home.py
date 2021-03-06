from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago

from datetime import timedelta


def_args = {
    'owner': 'sergio',
    'depends_on_past': False,
    'email': ['sergio.pintaldi@sydney.edu.au'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    'show_me_airflow_home',
    default_args=def_args,
    description='show me AIRFLOW_HOME in TERN Airflow',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['first', 'test']
) as dag:
    t1 = BashOperator(
        task_id='show_folders',
        bash_command='env && echo "${AIRFLOW_HOME}" && find "${AIRFLOW_HOME}" -type d -print ',
    )
