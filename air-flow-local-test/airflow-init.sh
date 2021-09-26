#!/usr/bin/env bash

export AIRFLOW_HOME=$(pwd)
AIRFLOW_PYTHON_PATH=${CONDA_EXE%"bin/conda"}envs/airflow/bin

# initialize the database
"${AIRFLOW_PYTHON_PATH}"/airflow db init

"${AIRFLOW_PYTHON_PATH}"/airflow users create \
    --username airflow \
    --firstname airflow \
    --lastname airflow \
    --role Admin \
    --email admin@myemail.com
