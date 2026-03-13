FROM apache/airflow:2.10.5-python3.12

USER root

COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

COPY dags /opt/airflow/dags
RUN chown -R airflow:root /opt/airflow/dags

USER airflow
