"""
Load Olist CSV vào schema olist (Typed).

FIX: bỏ `HEADER` khỏi COPY (buffer không có header → tránh mất row đầu).
"""
from __future__ import annotations

import argparse
import csv
import io
import os
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

load_dotenv()

TABLES_ORDER = [
    ("product_category_name_translation.csv", "product_category_name_translation"),
    ("olist_customers_dataset.csv", "customers"),
    ("olist_sellers_dataset.csv", "sellers"),
    ("olist_geolocation_dataset.csv", "geolocation"),
    ("olist_products_dataset.csv", "products"),
    ("olist_orders_dataset.csv", "orders"),
    ("olist_order_items_dataset.csv", "order_items"),
    ("olist_order_payments_dataset.csv", "order_payments"),
    ("olist_order_reviews_dataset.csv", "order_reviews"),
]


def get_conn():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=int(os.getenv("POSTGRES_PORT", 5432)),
        user=os.getenv("POSTGRES_USER", "shop"),
        password=os.getenv("POSTGRES_PASSWORD", "shop_pass"),
        dbname=os.getenv("POSTGRES_DB", "shop"),
    )


def load_csv(conn, csv_path: Path, table: str) -> int:
    buffer = io.StringIO()
    writer = csv.writer(buffer, quoting=csv.QUOTE_MINIMAL)

    with csv_path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        _header = next(reader)                     # bỏ header CSV gốc
        for row in reader:
            cleaned_row = [val if val != "" else r"\N" for val in row]
            writer.writerow(cleaned_row)

    buffer.seek(0)

    # ⚠️  BUG FIX: KHÔNG dùng HEADER ở đây. Buffer đã bị bỏ header rồi.
    sql = f"COPY {table} FROM STDIN WITH CSV NULL '\\N'"
    try:
        with conn.cursor() as cur:
            cur.copy_expert(sql, buffer)
        conn.commit()
    except psycopg2.Error as e:
        conn.rollback()
        print(f"❌ Lỗi khi load {table}: {e}")
        raise

    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {table}")
        return cur.fetchone()[0]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", default="data/olist")
    args = parser.parse_args()

    data_dir = Path(args.data_dir)
    conn = get_conn()

    try:
        with conn.cursor() as cur:
            cur.execute("SET session_replication_role = 'replica';")
            for _, table in reversed(TABLES_ORDER):
                cur.execute(f"TRUNCATE {table} CASCADE;")
            cur.execute("SET session_replication_role = 'origin';")
        conn.commit()
        print("[truncate] Đã xóa dữ liệu cũ.")

        for filename, table in TABLES_ORDER:
            csv_path = data_dir / filename
            if not csv_path.exists():
                print(f"[skip] Không tìm thấy {filename}")
                continue

            print(f"Đang load {filename} -> {table} ...")
            n = load_csv(conn, csv_path, table)
            print(f"✅ {table:45s} ({n:,} rows)")

    finally:
        conn.close()


if __name__ == "__main__":
    main()