import os

from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.bash import BashOperator
from airflow.models import Variable

from typing import List
from cloudstor import cloudstor
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

def read_cloudstor_paths(file_path: str) -> List[str]:

    paths = []

    with open(file_path, 'r') as fp:
        paths = fp.readlines()

    return paths


with DAG(
    'sync_cloudstor_data',
    default_args=def_args,
    description='Sync data periodically from Cloudstor',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['data', 'sync'],
) as dag:

    DATA_ROOT = "/mnt/data/cloudstor-data"
    CLOUDSTOR_ROOT = "davs://cloudstor.aarnet.edu.au/plus/remote.php/webdav"

    c = cloudstor(
        private=True,
        username=Variable.get("cloudstor_user", default_var="None"),
        password=Variable.get("cloudstor_psw", default_var="None")
    )

    paths_to_sync = read_cloudstor_paths("/mnt/data/repos/air-health-sws-airflow/cloudstor-data-paths.txt")

    for f in list(set(paths_to_sync)):

        # check if file or folder
        if c.is_file(f):
            # prepare parameter for remote file
            remote_path = f
            basedir = os.path.dirname(DATA_ROOT + remote_path)
            path_mkdir = basedir
        elif c.is_dir(f):
            # prepare parameter for remote folder
            remote_path = f + "/" if f[-1] != "/" else f
            basedir = os.path.dirname(DATA_ROOT + remote_path[:-1])
            path_mkdir = DATA_ROOT + remote_path
        else:
            raise ValueError("Expected Cloudstor file or path")

        task = BashOperator(
            task_id=f"dowload_{f.replace('/', '__')}",
            bash_command="""
                set -euo pipefail;
                echo "Syncing";
                echo "{{ params.cloudstor_path }}"
                echo "to";
                echo "{{ params.out_path_print }}";
                mkdir -p "{{ params.out_path_mkdir }}" && \
                duck -u "{{ var.value.cloudstor_user }}" \
                -p "{{ var.value.cloudstor_psw }}" -e compare \
                -d "{{ params.cloudstor_path }}" "{{ params.out_path_basedir }}"
            """,
            params={
                'out_path_mkdir': path_mkdir,
                'out_path_print': DATA_ROOT + remote_path,
                'out_path_basedir': basedir,
                'cloudstor_path': CLOUDSTOR_ROOT + remote_path
            }
        )
