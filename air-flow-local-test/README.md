# Local Airflow + Docker Getting Started

## Installation

The instructions and installation scripts are valid for Unix like OS (Mac, Linux). Windows users can try running them from the linux subsystem terminal.

1. Install docker for your own OS
2. Install airflow (assumed you have conda/anaconda already installed):

    a. Open a terminal and run the installation script:

        cd air-flow-local-test
        ./install.sh

    b. Run the initialisation script:

        ./airflow-init.sh


## Running Airflow

1. Run the following command to start Airflow Scheduler:

        ./start-airflow-scheduler.sh

2. In __another terminal__, start Airflow Webserver:

        ./start-airflow-webserver.sh

3. Open the Browser at [http://localhost:8080](http://localhost:8080) and login with `airflow` as username and password

## Running script reading/writing from/to Cloudstor

Read [__Cloudstor read/write__](../README.md#cloudstor-readwrite) to generate your Cloudstor username and password. `first-built-and-run-R-docker-pipeline-cloudstor.py` reads and writes from/to Cloudstor. In order to run it, add an Airflow variable through the interface (_Admin > Variables_ menu) and name it `cloudstor_psw`. You need to change the username and paths of the input and output data to match the ones in your Cloudstor (see [`00_main_cloudstor.R`](../test_scripts/00_main_cloudstor.R)).
