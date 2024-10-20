import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import pyspark.sql.functions as F
from pyspark.sql import Window

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

df = glueContext.create_dynamic_frame.from_catalog(database="tech_challenge_database", table_name="input_files").toDF()

df = df.filter(df.status.isin("delivered", "created"))

def validate_data(df):
    invalid_rows = df.filter(
        df.client_id.isNull() | (df.client_id == "") |
        df.client_name.isNull() | (df.client_name == "") |
        df.order_id.isNull() | (df.order_id == "") |
        df.product_id.isNull() | (df.product_id == "")
    )

    if invalid_rows.count() > 0:
        print(f"Se encontraron {invalid_rows.count()} filas inválidas.")
        invalid_rows.show()
        return None

    valid_df = df.dropna(subset=["client_id", "client_name", "order_id", "product_id"])
    return valid_df

validated_df = validate_data(df)

if validated_df is not None:
    sales_per_client = validated_df.groupBy("client_id", "client_name").agg(
        F.count("order_id").alias("total_sales")
    )

    spending_per_client = validated_df.groupBy("client_id", "client_name").agg(
        F.sum(F.col("product_price") * F.col("product_ccf")).alias("total_spending")
    )

    window_spec = Window.partitionBy("client_id").orderBy(F.desc("product_count"))
    most_sold_products = validated_df.groupBy("client_id", "product_description").agg(
        F.count("product_id").alias("product_count")
    ).withColumn("rank", F.row_number().over(window_spec)) \
        .filter(F.col("rank") == 1) \
        .select("client_id", F.col("product_description").alias("most_sold_product"))

    final_df = sales_per_client.join(spending_per_client, on=["client_id", "client_name"]) \
        .join(most_sold_products, on="client_id")

    final_df.show()

    final_df.write.mode("overwrite").format("parquet").save("s3://your_output_bucket/final_sales_report/")
else:
    print("Existen datos invalidos, no se pudo completar el procesamiento.")

