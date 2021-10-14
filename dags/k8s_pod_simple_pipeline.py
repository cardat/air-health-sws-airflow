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
    'k8s_pod_simple_pipeline',
    default_args=default_args,
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['test', 'kubernetes', 'pod']
) as dag:
    t = KubernetesPodOperator(
        task_id="pod_run_pipeline",
        # is_delete_operator_pod=True,
        get_logs=True,
        # labels={"foo": "bar"},
        name="pod_run_pipeline",
        cmds=["bash", "-eucx"],
        arguments=[
            "cd /opt/airflow/dags/sync",
            "&&"
            '''
            Rscript test_scripts/00_main_cloudstor.R \
            -u "TBC" -p "TBC"
            -r "test airflow/input data/GlobalGWRwUni_PM25_GL_201601_201612-RH35-NoNegs_AUS_20180618.tif" \
            -s "test airflow/input data/spatial_boundaries/sa22016_case_studyV2.shp" \
            -o "test airflow/test output folder" \
            -f "test_output"
            '''
        ],
        namespace="airflow-car",
        image="srggrs/pipeline-image:latest",
        image_pull_policy="IfNotPresent",
        # image_pull_secrets=["sergio-dockerhub-credentials"],
        image_pull_secrets=[
            k8s.V1LocalObjectReference('sergio-dockerhub-credentials')
        ],
        # it's always good to specify minimum resource requirements (this helps the k8s scheduler)
        resources=k8s.V1ResourceRequirements(requests={"cpu": "0.25"}),
        # env_vars=[
        #     k8s.V1EnvVar(name="ST_AUTH_VERSION", value=HARVESTER_VARS["ST_AUTH_VERSION"]),
        #     k8s.V1EnvVar(name="OS_AUTH_URL", value=HARVESTER_VARS["OS_AUTH_URL"]),
        # ],
        security_context=k8s.V1PodSecurityContext(run_as_user=1000),
    )
