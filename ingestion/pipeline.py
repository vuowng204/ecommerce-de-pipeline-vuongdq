import os
import dlt 
from dlt.sources.sql_database import sql_database #dùng để nhập mô-đun nguồn cơ sở dữ liệu từ thư viện dlt (data load tool).để tự động hóa quá trình trích xuất dữ liệu (Extract) từ các cơ sở dữ liệu quan hệ (như PostgreSQL)
from dotenv import load_dotenv

load_dotenv()

# Danh sách các bảng để lưu vào Redshift,cần lưu ý FK để tránh lỗi.
OLIST_TABLES =[
    "product_category_name_translation",
    "customers",
    "sellers",
    "geolocation",
    "products",
    "orders",
    "order_items",
    "order_payments",
    "order_reviews",
]

# Định nghĩa một hàm có tên là build_pipeline,kiểu dữ liệu trả về (Type Hint),hàm này sẽ trả về một đối tượng kiểu dlt.Pipeline.
def build_pipeline() -> dlt.Pipeline:
    """Khởi tạo dlt pipeline với S3 staging và Redshift destination."""
    return dlt.pipeline(
        pipeline_name="ecommerce-de-pipiline",
        destination="redshift",
        staging="filesystem", # dùng để nhập mô-đun nguồn cơ sở lên s3 rồi copy vào redshift
        dataset_name="raw_olist", # Schema đích trên Redshift
        dev_mode=False,  # Tắt dev_mode để không tự xóa schema khi chạy lại 
    )

# Hàm lấy dữ liệu từ postgress
def get_postgres_source():
    con_str = os.getenv("POSTGRES_CONNECTION_STRING")
    return sql_database( #Đây là hàm "nhà máy" của dlt. Nó reflect schema từ Postgres và tạo mỗi bảng thành một resource (có thể yield từng dòng).
        credentials=con_str,
        schema="public",
        table_names=OLIST_TABLES,

        backend="pyarrow",  #dùng PyArrow thay vì SQLAlchemy → nhanh hơn nhiều
        chunk_size=100000,  # đọc 100k dòng mỗi batch
    ) 

def run_ingestion() -> None:
    """Chạy toàn bộ quá trình ingest."""
    pipeline = build_pipeline()
    source = get_postgres_source()

    print("Bắt đầu ingest từ Postgres → S3 → Redshift...")

    # Chạy pipeline: replace toàn bộ bảng đích
    # loader_file_format="parquet" giúp nén tốt và load nhanh hơn CSV

    load_info=pipeline.run(
        source,
        write_disposition="replace",
        loader_file_format="parquet",
    )
    
    print("\n✅ Ingest hoàn tất!")
    print(load_info)


if __name__ == "__main__":
    run_ingestion()