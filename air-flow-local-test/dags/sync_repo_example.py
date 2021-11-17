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
    'sync_repo_example',
    default_args=def_args,
    description='Sync one or more repositories destination paths',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['data', 'sync', 'repo'],
) as dag:
    
    REPO_ROOT = "/mnt/data/repos"
        
    # Fill the dictionary with <repo url> : <path to destination>
    repos_to_sync = {
        "git@github.com:cardat/air-health-sws-airflow.git": os.path.join(REPO_ROOT, "air-health-sws-airflow")
    }
    
    for repo, path in repos_to_sync.items():
        task = BashOperator(
            task_id=f"syncing_{repo.replace('/', '__').replace(':', '_').replace('@', '_at_').replace('.','_')}",
            bash_command="""
                set -euo pipefail;
                echo "Syncing";
                echo "{{ params.repo }}"
                echo "to";
                echo "{{ params.dest_path }}";
                mkdir -p "{{ params.dest_path }}" && \
                [[ -d "{{ params.dest_path }}"  && -L "{{ params.dest_path }}" ]] && \
                cd "{{ params.dest_path }}" && git pull || git clone --depth 1 "{{ params.repo }}" "{{ params.dest_path }}"
            """,
            params={
                'dest_path': path,
                'repo': repo,
            }
        )
