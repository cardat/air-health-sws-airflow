import os

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
    'sync_dags',
    default_args=def_args,
    description='Sync dags from one or more folders to Airflow dags folder',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['dags', 'sync'],
) as dag:
    
    REPO_ROOT = "/mnt/data/repos"
        
    # Fill the dictionary with <path to my folder DAGS> : <path to Airflow DAGS>
    dags_to_sync = {
        os.path.join(REPO_ROOT, "air-health-sws-airflow", "dags", "airflow-simple-server"): "/opt/airflow/dags/",
    }
    
    for dag_path, path in dags_to_sync.items():
        task = BashOperator(
            task_id=f"syncing_{dag_path.replace('/', '__').replace('.','_')}",
            bash_command="""
                set -euo pipefail;
                echo "Syncing";
                echo "{{ params.dag_path }}"
                echo "to";
                echo "{{ params.dest_path }}";
                rsync -r "{{ params.dag_path }}" "{{ params.dest_path }}"
            """,
            params={
                'dest_path': path if path[-1] != "/" else path[:-1],
                'dag_path': dag_path if dag_path[-1] == "/" else dag_path + "/",
            }
        )
