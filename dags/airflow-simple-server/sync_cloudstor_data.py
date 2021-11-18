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
    'sync_cloudstor_data',
    default_args=def_args,
    description='Sync data periodically from Cloudstor',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['data', 'sync'],
) as dag:

    DATA_ROOT = "/mnt/data/cloudstor-data"
    CLOUDSTOR_ROOT = "davs://cloudstor.aarnet.edu.au/plus/remote.php/webdav"

    folders_to_sync = [
        "/Shared/Environment_General/ABS_data/ABS_meshblocks/abs_meshblocks_2011_data_provided",
        "/Shared/Environment_General/ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided",
    ]

    for f in list(set(folders_to_sync)):
        remote_path = f
        remote_path = remote_path + "/" if remote_path[-1] != "/" else remote_path

        task = BashOperator(
            task_id=f"dowload_{f.replace('/', '__')}",
            bash_command="""
                set -euo pipefail;
                echo "Syncing";
                echo "{{ params.cloudstor_path }}"
                echo "to";
                echo "{{ params.out_path }}";
                mkdir -p "{{ params.out_path }}" && \
                duck -u "{{ var.value.cloudstor_user }}" \
                -p "{{ var.value.cloudstor_psw }}" -e compare \
                -d "{{ params.cloudstor_path }}" "{{ params.out_path_basedir }}"
            """,
            params={
                'out_path': DATA_ROOT + remote_path,
                'out_path_basedir': os.path.dirname(DATA_ROOT + remote_path[:-1]),
                'cloudstor_path': CLOUDSTOR_ROOT + remote_path
            }
        )
