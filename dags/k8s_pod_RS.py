from airflow import DAG
from datetime import datetime, timedelta
from airflow.contrib.operators.kubernetes_pod_operator import KubernetesPodOperator
from airflow import configuration as conf

default_args = {
    'owner': 'Rosie',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

namespace = conf.get('kubernetes', 'NAMESPACE')

# This will detect the default namespace locally and read the
# environment namespace when deployed to Astronomer.
#if namespace =='default':
#    config_file = '/usr/local/airflow/include/.kube/config'
#    in_cluster=False
#else:
#    in_cluster=True
#    config_file=None

dag = DAG('k8s_pod_RS',
          schedule_interval='@once',
          default_args=default_args)

# This is where we define our desired resources.
compute_resources = \
  {'request_cpu': '100m',
  'request_memory': '4Mi',
  'limit_cpu': '100m',
  'limit_memory': '4Mi'}

with dag:
    k = KubernetesPodOperator(
#        namespace=namespace,
        namespace="airflow-car",
        image="hello-world",
        labels={"foo": "bar"},
        name="airflow-test-pod",
        task_id="task-one",
        startup_timeout_seconds=300,
        #in_cluster=in_cluster, # if set to true, will look in the cluster, if false, looks for file
        in_cluster=True, # if set to true, will look in the cluster, if false, looks for file
        cluster_context='docker-for-desktop', # is ignored when in_cluster is set to True
        config_file=config_file,
        resources=compute_resources,
        is_delete_operator_pod=True,
        get_logs=True)
