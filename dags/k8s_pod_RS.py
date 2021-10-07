from airflow import DAG
from datetime import datetime, timedelta
from airflow.contrib.operators.kubernetes_pod_operator import KubernetesPodOperator
from airflow import configuration as conf

default_args = {
    'owner': 'Rosie',
    'start_date': datetime(2021, 10, 7)
}

#namespace = conf.get('kubernetes', 'NAMESPACE')

dag = DAG('k8s_pod_RS',
          default_args=default_args
)

# This is where we define our desired resources.
compute_resources = \
  {'request_cpu': '100m',
  'request_memory': '4Mi',
  'limit_cpu': '100m',
  'limit_memory': '4Mi'}

with dag:
    k = KubernetesPodOperator(
        name="airflow-test-pod",
        task_id="task-one",
        namespace="airflow-car",
        image="hello-world",
        startup_timeout_seconds=300,
        resources=compute_resources,
        get_logs=True
    )
