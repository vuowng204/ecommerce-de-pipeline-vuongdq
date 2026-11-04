"""
DAG: Olist E-commerce ELT Pipeline
Flow: Postgres -> dlt (S3/Redshift) -> dbt run -> dbt test
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.amazon.aws.operators.s3 import S3DeleteObjectsOperator

clean_state = BashOperator(
    task_id='clean_dlt_state',
    bash_command='rm -rf /home/airflow/.dlt/pipelines/ecommerce-de-pipiline || true',
)
# Cấu hình mặc định
default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'email_on_failure': False, # Đổi thành True nếu có SMTP
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='olist_ecommerce_elt',
    default_args=default_args,
    description='Ingest Olist from Postgres, load to Redshift via dlt, transform with dbt',
    schedule='@daily', # Chạy hàng ngày
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['ecommerce', 'olist', 'dlt', 'dbt'],
) as dag:

    # Task 1: Ingest dữ liệu bằng dlt
    ingest_dlt = BashOperator(
        task_id='ingest_postgres_to_redshift',
        # Chạy từ thư mục gốc của project
        bash_command='cd /opt/airflow/project && python -m ingestion.pipeline',
        # Truyền thêm biến môi trường nếu cần
        env={
            'PYTHONPATH': '/opt/airflow/project',
        }
    )

    # Task 2: Chạy dbt models
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /opt/airflow/project/dbt_ecommerce && dbt run --profiles-dir .',
    )

    # Task 3: Chạy dbt tests
    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='cd /opt/airflow/project/dbt_ecommerce && dbt test --profiles-dir .',
    )

    # Thiết lập thứ tự chạy
    clean_state >> ingest_dlt >> dbt_run >> dbt_test