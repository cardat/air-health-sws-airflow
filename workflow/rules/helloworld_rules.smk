
rule hello_world:
    output: "helloworld.out"
    shell: "echo Hello World > /opt/airflow/dags/sync/output/helloworld.out"
    # shell: " sh /opt/airflow/dags/sync/scripts/helloworld.sh > /opt/airflow/dags/sync/output/helloworld.out"
