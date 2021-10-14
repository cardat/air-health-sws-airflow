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


# volume = k8s.V1Volume(empty_dir={}, name="airflow-dags")
secret_volume = k8s.V1Volume(
    name="github-secret",
    secret=k8s.V1LocalObjectReference('gitsync-ssh ')
)

secret_vol_mount = vol_mount = k8s.V1VolumeMount(
    name="github-secret",
    mount_path="/etc/secret-volume",
    read_only=True
)

# vol_mount = k8s.V1VolumeMount(
#     name="airflow-dags",
#     mount_path="/workspace",
#     read_only=True
# )

# init_container = k8s.V1Container(
#     name="sync-my-repo",
#     image="ubuntu:16.04",
#     env=init_environments,
#     volume_mounts=init_container_volume_mounts,
#     command=["bash", "-cx"],
#     args=["echo 10"],
# )

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
        volumes=[secret_volume],
        volume_mounts=[secret_vol_mount],
        arguments=[
            "cd /etc/secret-volume && ls -alsh && cat *",
            # "cd /opt/airflow/dags/sync",
            # "&&",
            # 'Rscript test_scripts/00_main_cloudstor.R'
            # ' -u "TBC" -p "TBC"'
            # ' -r "test airflow/input data/GlobalGWRwUni_PM25_GL_201601_201612-RH35-NoNegs_AUS_20180618.tif"'
            # ' -s "test airflow/input data/spatial_boundaries/sa22016_case_studyV2.shp"'
            # ' -o "test airflow/test output folder"'
            # ' -f "test_output"'
        ],
        # init_containers=[init_container],
        namespace="airflow-car",
        image="srggrs/pipeline-image:latest",
        image_pull_policy="IfNotPresent",
        image_pull_secrets=[
            k8s.V1LocalObjectReference('sergio-dockerhub-credentials')
        ],
        resources=k8s.V1ResourceRequirements(requests={"cpu": "0.25"}),
        security_context=k8s.V1PodSecurityContext(run_as_user=1000),
    )
