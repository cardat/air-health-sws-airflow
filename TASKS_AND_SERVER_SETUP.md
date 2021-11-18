# Instructions to set up Airflow and related workflows on a remote server

This instructions are essentially for a pre-production stage Airflow platform with associatied workflows. It consists of two main parts:

1. Installation of Airflow and other OS dependencies.

2. Setting up tasks within Airflow to run R scripts and related tasks (e.g. sync a repo and/or data).

## Installation of Airflow on a remote server

1. Follow the [`Server Install instructions`](/SERVER_INSTALL.md) to install Airflow.

2. Install all the OS dependencies required by the tasks, see [`Tasks Instructions`](TASKS_INSTRUCTIONS.md) (e.g. `duck`, `git`, etc.).

## Run your tasks "automagically"

1. Manually copy the workflow to sync a repo into Airflow machine. See an example of such: [`sync_repo_example.py`](/air-flow-local-test/dags/sync_repo_example.py). And change the scheduling to suits needs (e.g. every 5 min).

2. Set up a workflow or copy an existing one to sync saved/committed workflows from a local folder (ideally the repo synced by step 1) into the `dags` folder of Airflow in the server. See example [`sync_dags_example.py`](/air-flow-local-test/dags/sync_dags_example.py).

3. Start the workflow that sync Cloudstor data into Airflow server.

4. Run your pipeline workflow.
