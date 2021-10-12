from airflow import DAG
from airflow.contrib.operators.kubernetes_pod_operator import KubernetesPodOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.utils.dates import days_ago

from datetime import timedelta


default_args = {
    'owner': 'sergio',
    'depends_on_past': False,
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1)
}

with DAG(
    'kube_pod_example',
    default_args=default_args,
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['first', 'test', 'kubernetes', 'pod']
) as dag:
    start = DummyOperator(task_id='run_this_first')

    passing = KubernetesPodOperator(
        task_id="passing-task",
        namespace='default',
        image="Python:3.6",
        image_pull_secrets=['sergio-dockerhub-credentials'],
        cmds=["Python","-c"],
        arguments=["print('hello world')"],
        labels={"foo": "bar"},
        name="passing-test",
        get_logs=True
    )

    failing = KubernetesPodOperator(
        task_id="failing-task",
        namespace='default',
        image="ubuntu:1604",
        image_pull_secrets=['sergio-dockerhub-credentials'],
        cmds=["Python","-c"],
        arguments=["print('hello world')"],
        labels={"foo": "bar"},
        name="fail",
        get_logs=True
    )

    start >> passing
    start >> failing