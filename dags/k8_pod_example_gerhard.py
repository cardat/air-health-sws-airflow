from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from airflow.utils.dates import days_ago

from kubernetes.client import models as k8s

from datetime import timedelta


default_args = {
    'owner': 'sergio',
    'depends_on_past': False,
    'email': ['sergio.pintaldi@sydney.edu.au'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1)
}

with DAG(
    'k8_pod_example_gerhard',
    default_args=default_args,
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['test', 'kubernetes', 'pod']
) as dag:
    t = KubernetesPodOperator(
        #########################################################
        # airflow k8s pod operator settings
        #########################################################
        # The ID specified for the task.
        task_id="pod_hello_task",
        # is_delete_operator_pod=True,
        get_logs=True,
        # labels={"foo": "bar"},
        # in_cluster=True,
        # Name of task you want to run, used to generate Pod ID.
        name="pod_hello_task",
        #########################################################
        # k8s pod config below
        #########################################################
        # cmds is optional ... depends on container to run
        cmds=["bash", "-cx"],
        # cmd arguments
        arguments=["echo", "10", "echo pwd"],
        # not 100% sure whether namespace is required, but should be airflow-car
        namespace="airflow-car",
        # image="alpine:3.10",
        image="srggrs/pipeline-image:latest",
        image_pull_policy="IfNotPresent",
        # image_pull_secrets=["sergio-dockerhub-credentials"],
        image_pull_secrets=[k8s.V1LocalObjectReference('sergio-dockerhub-credentials')],
        # it's always good to specify minimum resource requirements (this helps the k8s scheduler)
        resources=k8s.V1ResourceRequirements(
            requests={"cpu": "0.1"},
        ),
        # env_vars=[
        #     k8s.V1EnvVar(name="ST_AUTH_VERSION", value=HARVESTER_VARS["ST_AUTH_VERSION"]),
        #     k8s.V1EnvVar(name="OS_AUTH_URL", value=HARVESTER_VARS["OS_AUTH_URL"]),
        # ],
        security_context=k8s.V1PodSecurityContext(run_as_user='rstudio'),
    )
