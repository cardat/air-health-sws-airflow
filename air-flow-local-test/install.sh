#!/usr/bin/env bash
set -euo pipefail

export AIRFLOW_HOME=$(pwd)
echo "Airflow install folder: ${AIRFLOW_HOME}"

if [[ -f "${AIRFLOW_PYTHON_PATH}/python" ]]; then
  echo "Conda environment already installed"
else
  echo "Creating conda enviroment for airflow . . ."
  conda create -n airflow python=3.8.11 -y
fi

# AIRFLOW_VERSION=2.1.2
AIRFLOW_PYTHON_PATH=${CONDA_EXE%"bin/conda"}envs/airflow/bin
# echo "${AIRFLOW_PYTHON_PATH}"
PYTHON_VERSION="$($AIRFLOW_PYTHON_PATH/python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
# # echo "${PYTHON_VERSION}"
# # For example: 3.6
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
# # For example: https://raw.githubusercontent.com/apache/airflow/constraints-2.1.2/constraints-3.6.txt
echo "Installing airflow . . ."
"${AIRFLOW_PYTHON_PATH}"/pip install "apache-airflow[docker]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
"${AIRFLOW_PYTHON_PATH}"/pip install airflow-code-editor

