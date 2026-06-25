import os
from pathlib import Path

import pandas as pd
import psycopg2
from dotenv import load_dotenv


load_dotenv(Path(__file__).resolve().parent / ".env", override=True)


def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "gestao_academica"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", ""),
    )


def get_connection_settings():
    return {
        "DB_HOST": os.getenv("DB_HOST", "localhost"),
        "DB_PORT": os.getenv("DB_PORT", "5432"),
        "DB_NAME": os.getenv("DB_NAME", "gestao_academica"),
        "DB_USER": os.getenv("DB_USER", "postgres"),
    }


def run_query(query, params=None):
    connection = get_connection()
    try:
        dataframe = pd.read_sql_query(query, connection, params=params)
        return dataframe
    finally:
        connection.close()


def execute_command(query, params=None):
    connection = get_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(query, params)
            affected_rows = cursor.rowcount
        connection.commit()
        return affected_rows
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


def call_procedure(procedure_name, params=None):
    connection = get_connection()
    try:
        parameters = params or []
        placeholders = ", ".join(["%s"] * len(parameters))
        query = f"CALL {procedure_name}({placeholders})"
        with connection.cursor() as cursor:
            cursor.execute(query, parameters)
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()
