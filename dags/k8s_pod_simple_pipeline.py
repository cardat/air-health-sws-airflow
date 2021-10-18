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

volume = k8s.V1Volume(
    empty_dir={},
    name="repo-files",
    # persistent_volume_claim=k8s.V1PersistentVolumeClaimVolumeSource(
        # claim_name="repo-files"
    # )
)
# secret_volume = k8s.V1Volume(
#     name="github-secret",
#     secret=k8s.V1SecretVolumeSource(secret_name='gitsync-ssh'),
#     # persistent_volume_claim=k8s.V1PersistentVolumeClaimVolumeSource(
#     #     claim_name="github-secret"
#     # )
# )

# secret_vol_mount = k8s.V1VolumeMount(
#     name="github-secret",
#     mount_path="/etc/secret-volume",
#     read_only=True
# )

vol_mount = k8s.V1VolumeMount(
    name="repo-files",
    mount_path="/tmp",
    # read_only=True
)

init_env_vars = [
    k8s.V1EnvVar(
        name='GIT_SYNC_REPO',
        # value='https://github.com/cardat/air-health-sws-airflow.git'
        value='https://github.com/askap-vast/vast-pipeline.git'
    ),
    # k8s.V1EnvVar(name='GIT_SYNC_DEST', value='/workspace'),
    # k8s.V1EnvVar(
    #     name='GIT_SSH_KEY_FILE',
    #     value='/etc/secret-volume/gitSshKey'
    # ),
    # k8s.V1EnvVar(name='GIT_SYNC_SSH', value='true'),
    k8s.V1EnvVar(name='GIT_KNOWN_HOSTS', value='false'),
    k8s.V1EnvVar(name='GIT_SYNC_ONE_TIME', value='true'),
]

init_container = k8s.V1Container(
    name="sync-my-repo",
    # image="openweb/git-sync:latest",
    image="k8s.gcr.io/git-sync/git-sync:v3.3.4",
    env=init_env_vars,
    # volume_mounts=[secret_vol_mount, vol_mount],
    volume_mounts=[vol_mount],
    image_pull_policy="IfNotPresent",
    # command=["bash", "-cx"],
    # args=["echo", "10"],
)

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
        name="run_pipeline",
        cmds=["bash", "-eucx"],
        volumes=[volume],
        volume_mounts=[vol_mount],
        arguments=[
            # "cd /etc/secret-volume && ls -alsh && cat *",
            "ls -alsh /tmp",
            # "cd /opt/airflow/dags/sync",
            # "&&",
            # 'Rscript test_scripts/00_main_cloudstor.R'
            # ' -u "TBC" -p "TBC"'
            # ' -r "test airflow/input data/GlobalGWRwUni_PM25_GL_201601_201612-RH35-NoNegs_AUS_20180618.tif"'
            # ' -s "test airflow/input data/spatial_boundaries/sa22016_case_studyV2.shp"'
            # ' -o "test airflow/test output folder"'
            # ' -f "test_output"'
        ],
        init_containers=[init_container],
        namespace="airflow-car",
        image="srggrs/pipeline-image:latest",
        image_pull_policy="IfNotPresent",
        image_pull_secrets=[
            k8s.V1LocalObjectReference('sergio-dockerhub-credentials')
        ],
        resources=k8s.V1ResourceRequirements(requests={"cpu": "0.25"}),
        security_context=k8s.V1PodSecurityContext(run_as_user=1000),
    )
