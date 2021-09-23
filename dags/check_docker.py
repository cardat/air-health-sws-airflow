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
    'check_docker',
    default_args=def_args,
    description='check docker in TERN Airflow',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['first', 'test', 'docker']
) as dag:
    t1 = BashOperator(
        task_id='check_docker_task',
        bash_command='which docker && docker ps -a ',
    )
