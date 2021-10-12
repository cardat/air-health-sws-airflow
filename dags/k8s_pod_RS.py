from airflow import DAG
from datetime import datetime, timedelta
from airflow.contrib.operators.kubernetes_pod_operator import KubernetesPodOperator
#from airflow import configuration as conf

default_args = {
    'owner': 'Rosie',
    'start_date': datetime(2021, 10, 7)
}

dag = DAG('k8s_pod_RS',
          default_args=default_args
)


with dag:
    k = KubernetesPodOperator(
        name="airflow-test-pod",
        task_id="task-one",
        cmds=['echo'],
        namespace="airflow-car",
        image="hello-world",
        get_logs=True
    )
