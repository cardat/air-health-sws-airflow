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
