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
    'pipeline_test_script',
    default_args=def_args,
    description='Run the test script pipeline given a file location with the code',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['data', 'R', 'pipeline', 'test_script'],
) as dag:

    PIPELINE_PATH = "/mnt/data/repos/air-health-sws-airflow/test_scripts/00_main.R"
    DATA_RASTER = "/mnt/data/repos/air-health-sws-airflow/data_demo/air_pollution/GlobalGWRwUni_PM25_GL_201601_201612-RH35-NoNegs_AUS_20180618.tif"
    DATA_SHAPE = "/mnt/data/repos/air-health-sws-airflow/data_demo/spatial_boundaries/sa22016_case_studyV2.shp"
    OUT_PATH = "/mnt/data/repos/air-health-sws-airflow/data_demo"
    OUT_FILE = "ap_w_boundaries"

    task = BashOperator(
        task_id="Running_00_main",
        bash_command="""
            set -euo pipefail;
            Rscript "{{ params.path }}" -r "{{ params.data_path_raster }} \
            -s "{{ params.data_path_shape }}" \
            -o "{{ params.out_path }}" -f "{{ params.out_file }}"
        """,
        params={
            'path': os.path.basename(PIPELINE_PATH),
            'data_path_raster': DATA_RASTER,
            'data_path_shape': DATA_SHAPE,
            'out_path': OUT_PATH,
            'out_file': OUT_FILE
        },
        cwd=os.path.dirname(PIPELINE_PATH),
    )
