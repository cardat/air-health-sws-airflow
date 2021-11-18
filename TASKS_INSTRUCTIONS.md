# Instructions to set up various tasks in Airflow

## Task to sync Cloudstor folders to Airflow machine (remote or local)

1. Make sure [`duck`](https://duck.sh/) is installed in the machine

2. Generate Cloudstor app password for the WebDAV API, see [instructions](https://support.aarnet.edu.au/hc/en-us/articles/236034707-How-do-I-manage-change-my-passwords-)

3. Save the username and password into variables in Airflow.

4. Look at the DAG [`sync_cloudstor_data_example.py`](/air-flow-local-test/dags/sync_cloudstor_data_example.py) to see how you can pass a list of folder to sync.

Alternatives to `duck` exist both in Python ([`cloudstor`](https://github.com/underworldcode/cloudstor), [`webdav`](https://github.com/ezhov-evgeny/webdav-client-python-3)) and R ([`cloudstoR`](https://github.com/cran/cloudstoR)) worlds but seems you need to write a bit of code to perform a sync, and some of the current sync functions for Python `cloudstor` package do not work for Cloudstor shared folders.

## Task to sync a GitHub repo to Airflow machine (remote or local)

1. Set up a SSH key-pair as [described here](https://confluence.atlassian.com/bitbucketserver/creating-ssh-keys-776639788.html).

2. Add GitHub in the list of the known hosts as [described here](https://serverfault.com/questions/856194/securely-add-a-host-e-g-github-to-the-ssh-known-hosts-file).

3. Look at the DAG [`sync_repo_example.py`](/air-flow-local-test/dags/sync_repo_example.py).

## Task run a R script

1. Install R into the server. E.g. for Ubuntu 18.04 follow [these instructions](https://cloud.r-project.org/).

2. Run the DAG with the R task
