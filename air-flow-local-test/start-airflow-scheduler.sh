#!/usr/bin/env bash
set -euo pipefail

export AIRFLOW_HOME=$(pwd)
echo "Airflow install folder: ${AIRFLOW_HOME}"

AIRFLOW_PYTHON_PATH=${CONDA_EXE%"bin/conda"}envs/airflow/bin
export PATH="$AIRFLOW_PYTHON_PATH:$PATH"
airflow scheduler
