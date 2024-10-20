# Descripción de la Arquitectura

La arquitectura definida consiste en un flujo de trabajo integral para el procesamiento y consulta de datos provenientes de archivos CSV, aprovechando diversos servicios de AWS, incluyendo AWS Glue, S3, Lambda, API Gateway y Athena. A continuación, se detalla cada componente y su funcionalidad:

## Ingreso de Datos a S3

Los datos se cargan en un bucket de S3 llamado `my-input-bucket-tech-chall`. Este bucket está configurado para recibir archivos en formato CSV.

## Job de Glue

Se desarrolló un job de AWS Glue que lee datos desde el catálogo, específicamente desde la tabla que mapea el archivo CSV de entrada. Este job incluye un proceso de ETL que valida los datos en el DataFrame antes de continuar con las transformaciones correspondientes. Las transformaciones realizadas incluyen:

- **Ventas totales por cliente**: Conteo de productos vendidos por cliente.
- **Gastos totales por cliente**: Cálculo del gasto total basado en el precio de los productos y la cantidad comprada.
- **Producto más vendido por cliente**: Identificación del producto más comprado por cliente.

Al finalizar las transformaciones, los resultados se almacenan en formato Parquet en un bucket de S3 llamado `my-output-bucket-tech-chall`.

## Crawler de Glue

Se utiliza un crawler de AWS Glue para escanear el contenido del bucket de entrada y crear una tabla en el catálogo de Glue. Este crawler se ejecuta una vez para mapear la estructura de la tabla, y no se requiere su ejecución en cada carga de datos. Si se necesitan actualizaciones en la definición de la tabla, el crawler se puede ejecutar posteriormente para reflejar los cambios en la estructura de los datos.

Además, se implementa otro crawler para mapear la salida del job de Glue, lo que permite que los resultados procesados estén disponibles en el catálogo de Glue para consultas posteriores.

## Notificación de Eventos

El bucket de entrada en S3 está configurado con una notificación de eventos que desencadena la ejecución del job de Glue cada vez que se carga un nuevo archivo CSV. Esto se logra mediante una Lambda function que se activa en respuesta a los eventos de subida al bucket.

## API Gateway

Se implementa un API Gateway que expone tres servicios: `/customers`, `/products` y `/orders`. Cada uno de estos servicios permite a los usuarios consultar los datos procesados mediante una Lambda function, que valida la solicitud y ejecuta consultas en Athena, devolviendo los resultados correspondientes.

Para el acceso seguro a la API, se requiere el uso de una API Key.

## Consideraciones adicionales

- Se han implementado validaciones de datos dentro del job de Glue para garantizar la calidad de los datos.
- Las configuraciones de recursos han sido optimizadas para minimizar costos, utilizando las instancias de Glue adecuadas y asegurando que solo se utilicen recursos cuando sea necesario.

## Infraestructura como Código (IaC)

Todos los componentes de la arquitectura están disponibles para su despliegue mediante **Terraform**, lo que facilita la gestión y la replicación del entorno en diferentes regiones o cuentas de AWS.
