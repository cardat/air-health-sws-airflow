import docker

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.docker_operator import DockerOperator
from airflow.utils.dates import days_ago

from datetime import timedelta
from docker.types import Mount


def_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['sergio.pintaldi@sydney.edu.au'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
}

def build_workflow_img(img_path, repo='airflow-pipeline', img_tag_suffix='test'):
    '''
    function to built R docker image with custom packages
    '''
    # get docker client
    client = docker.from_env()

    # get list of current images and check if image has been already built
    images = client.images.list()
    image_full_tag = f"{repo}:{img_tag_suffix}"

    img, logs = client.images.build(
        path=img_path,
        tag=image_full_tag,
        forcerm=True
    )
    build_logs = [x.get('stream', '') for x in logs]
    print(''.join(build_logs))

    pass


with DAG(
    'first_build_and_run_R_docker_pipeline_cloudstor',
    default_args=def_args,
    description='First test for running R pipeline from Docker reading and writing to/from Cloudstor',
    schedule_interval=None,
    start_date=days_ago(2),
    tags=['first', 'R', 'docker', 'cloudstor'],
) as dag:

    img_tag = 'my_image_of_today'
    
    # built docker image with python
    t0 = PythonOperator(
        task_id='build_R_image',
        python_callable=build_workflow_img,
        op_kwargs={
            'img_path': '/home/srg/Documents/Projects/air-health-with-apache-air-flow/test_scripts/',
            'img_tag_suffix': img_tag
        }
    )
    
    # run R code using the built docker image
    t1 = DockerOperator(
        task_id='first_R_task_docker_pipeline',
        image=f'airflow-pipeline:{img_tag}',
        container_name='first_R_task_docker_pipeline',
        user='rstudio',
        auto_remove=True,
        command='''
            /bin/bash -eu -c '
            Rscript /home/rstudio/test_scripts/00_main_cloudstor.R \
            -u "sergio.pintaldi@sydney.edu.au" -p "{{ var.value.cloudstor_password }}" \
            -r "test airflow/input data/GlobalGWRwUni_PM25_GL_201601_201612-RH35-NoNegs_AUS_20180618.tif" \
            -s "test airflow/input data/spatial_boundaries/sa22016_case_studyV2.shp" \
            -o "test airflow/test" \
            -f "test_output" \
            '
        ''',
        mounts=[
            Mount(
                '/home/rstudio',
                '/home/srg/Documents/Projects/air-health-with-apache-air-flow',
                type='bind',
            )
        ],
    )

    # set task priority
    t0 >> t1
