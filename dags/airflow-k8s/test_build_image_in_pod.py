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
)

vol_mount_init = k8s.V1VolumeMount(
    name="repo-files",
    mount_path="/tmp",
)

vol_mount = k8s.V1VolumeMount(
    name="repo-files",
    mount_path="/home/user/src",
    read_only=True
)

init_env_vars = [
    k8s.V1EnvVar(
        name='GIT_SYNC_REPO',
        value='https://github.com/cardat/air-health-sws-airflow.git'
    ),
    k8s.V1EnvVar(name='GIT_SYNC_ROOT', value='/tmp/git'),
    k8s.V1EnvVar(name='GIT_SYNC_DEST', value='repo'),
    k8s.V1EnvVar(name='GIT_SYNC_BRANCH', value='main'),
    # k8s.V1EnvVar(
    #     name='GIT_SSH_KEY_FILE',
    #     value='/etc/secret-volume/gitSshKey'
    # ),
    # k8s.V1EnvVar(name='GIT_SYNC_SSH', value='true'),
    k8s.V1EnvVar(name='GIT_KNOWN_HOSTS', value='false'),
    k8s.V1EnvVar(name='GIT_SYNC_ONE_TIME', value='true'),
    k8s.V1EnvVar(
        name='GIT_SYNC_USERNAME',
        value_from=k8s.V1EnvVarSource(secret_key_ref=k8s.V1SecretKeySelector(
            key='user',
            name='sergio-github-credentials',
        ))
    ),
    k8s.V1EnvVar(
        name='GIT_SYNC_PASSWORD',
        value_from=k8s.V1EnvVarSource(secret_key_ref=k8s.V1SecretKeySelector(
            key='password',
            name='sergio-github-credentials',
        ))
    ),
]

init_container = k8s.V1Container(
    name="sync-my-repo",
    image="k8s.gcr.io/git-sync/git-sync:v3.3.4",
    env=init_env_vars,
    volume_mounts=[vol_mount_init],
    image_pull_policy="IfNotPresent",
)

with DAG(
    'test_build_image_in_pod',
    default_args=default_args,
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['test', 'kubernetes', 'pod']
) as dag:
    t = KubernetesPodOperator(
        task_id="build_docker_image",
        # is_delete_operator_pod=True,
        get_logs=True,
        # labels={"foo": "bar"},
        name="build_docker_image",
        cmds=["img"],
        volumes=[volume],
        volume_mounts=[vol_mount],
        arguments=[
            'build --help'
            # '--workdir /home/user/src/test_scripts'
            # ' -t srg:latest .'
        ],
        init_containers=[init_container],
        namespace="airflow-car",
        image="r.j3ss.co/img:latest",
        image_pull_policy="IfNotPresent",
        image_pull_secrets=[
            k8s.V1LocalObjectReference('sergio-dockerhub-credentials')
        ],
        resources=k8s.V1ResourceRequirements(requests={"cpu": "0.25"}),
        security_context=k8s.V1PodSecurityContext(run_as_user=1000),
        # annotations={
        #     'container.apparmor.security.beta.kubernetes.io/img': 'unconfined',
        #     'container.seccomp.security.alpha.kubernetes.io/img': 'unconfined',
        # },
    )
