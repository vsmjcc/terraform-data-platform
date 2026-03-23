"""
S2S Shopify Orders Enriched: executa o Glue orders-s2s-enriched.
Lê a tabela Silver B2S de orders e gera visão refinada S2S.

Saída: mesma convenção que customers-s2s — `silver_enriched.<GLUE_TABLE>` com Location
`.../domain=silver_enriched/source=conformed/dataset=<GLUE_TABLE>` (via catálogo Glue;
fallback no script usa o bucket da tabela fonte).
"""
from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator

from utils.notifiers import (
    slack_fail_task,
    slack_success_task,
    slack_fail_dag,
    slack_success_dag,
)


GLUE_JOB_NAME = "orders-s2s-enriched"

TZ = pendulum.timezone("America/Sao_Paulo")

default_args = {
    "owner": "data-eng",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "on_failure_callback": [slack_fail_task],
    "on_success_callback": [slack_success_task],
}


with DAG(
    dag_id="orders-s2s-enriched",
    description="S2S - Enriquecimento Shopify Orders (Silver B2S -> Silver Enriched).",
    start_date=pendulum.datetime(2026, 3, 1, tz=TZ),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    default_args=default_args,
    on_failure_callback=[slack_fail_dag],
    on_success_callback=[slack_success_dag],
    tags=["glue", "shopify", "orders", "s2s", "silver_enriched"],
) as dag:

    orders_s2s_enriched = GlueJobOperator(
        task_id="orders_s2s_enriched",
        job_name=GLUE_JOB_NAME,
        region_name="us-east-1",
        aws_conn_id="aws_default",
        script_args={
            "--SOURCE_GLUE_DATABASE": "silver_commerce",
            "--SOURCE_GLUE_TABLE": "orders",
            "--GLUE_DATABASE": "silver_enriched",
            "--GLUE_TABLE": "orders_enriched",
            "--MODE": "{{ dag_run.conf.get('MODE', 'overwrite') if dag_run else 'overwrite' }}",
            # opcional: pode ser usado em backfill
            "--FROM_ORDER_DATE": "{{ dag_run.conf.get('DATE_FROM', '') if dag_run else '' }}",
            "--TO_ORDER_DATE": "{{ dag_run.conf.get('DATE_TO', '') if dag_run else '' }}",
        },
        wait_for_completion=True,
        verbose=True,
    )

    orders_s2s_enriched

