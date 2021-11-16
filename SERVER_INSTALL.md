# Instructions to set up a simple instance of Airflow on a remote server

## Installation

1. Download and install miniconda on the server:
    a. SSH into the server
    b. Visit the latest release from [their servers](https://docs.conda.io/en/latest/miniconda.html).
    c. Copy link (e.g. mouse right-click "Copy Link") of suitable installer for your OS.
    d. In the terminal download the installer with:
        ```bash
        wget <paste link here>
        ```
    e. Execute the installer: `chmod u+x <installer file> && ./<installer file>`

2. Copy over [`install.sh`](/air-flow-local-test/install.sh) to the server, via SSH.

3. Login to he server vis SSH and run `./install.sh`

## Start Airflow platform

The minimal platform include the webserver to run the dashboard and the scheduler, which execute the task on the local server. A more complex installation with additional Airflow services can be used. For more details about this I recommend inspecting the docker-compose file provided by the [Airflow documentation](https://airflow.apache.org/docs/apache-airflow/stable/start/docker.html) (it has a list of services to run a more robust version of the Airflow platform).

### Initialise Airflow

Airflow need to be initialised before running the platform and this operation need to be done __ONCE__!

Initialise airflow by copying the [`airflow-init.sh`](/air-flow-local-test/airflow-init.sh) script and executing it:

```bash
./airflow-init.sh
```

### Run Airflow main services

Since two main services need to be run via the terminal, there are two options here:

1. Use a tool like `screen` or `tmux` to split your terminal into sub-terminal with multiple panels. I personally recommend `tmux`.

2. Open two terminals and SSH into the remote server.

The advatages of the first option is that you can "disconnect"/"detach" from the sub-terminal and the command will be still running there without stopping. Instead when logging out of the server or close the terminals, in option 2, anything running there will be halted (e.g. airflow webserver and/or scheduler will terminate).


You can install `screen` or `tmux` via the OS package manager (e.g. `apt-get install tmux`).

In this instructions I will use `tmux` to run the main Airflow services.

Steps:

1. Login via SSH into the remote server.

2. Start `tmux` and split the terminal into 2 panels (e.g. top and bottom):

    ```bash
    $: tmux
    ```
    within `tmux` press `CTRL + B` then `"` to split into top and bottom panels. You can move from top to bottom by `CTRL + B` then `top arrow` or `bottom arrow`.

3. Copy [`start-airflow-scheduler.sh`](/air-flow-local-test/start-airflow-scheduler.sh) to the server and start Airflow scheduler in one panel:

    ```bash
    ./start-airflow-scheduler.sh
    ```

4. Copy [`start-airflow-webserver.sh`](/air-flow-local-test/start-airflow-webserver.sh) to the server and start Airflow webserver in another panel:

    ```bash
    ./start-airflow-webserver.sh
    ```

__NOTES__: For more info on the Airflow local platform see [official documentation](https://airflow.apache.org/docs/apache-airflow/stable/start/local.html).
