# Spark Summit 2020

Scaling [R](https://cran.r-project.org/) and [Shiny](https://shiny.rstudio.com/)
applications using RStudio and Databricks.

[![Title Slide](img/title-slide.png)](slides/spark-summit-2020.pdf)

## Requirements
- Development version of `sparklyr`: `remotes::install_github("sparklyr/sparklyr")`
- Follow the [Client setup
instructions](https://docs.databricks.com/dev-tools/databricks-connect.html#client-setup)
for Databricks Connect. 

```
pip install -U databricks-connect
```

## Connecting
### Spark
In order to connect, there must be a local installation of Spark that matches
the version of the Databricks Cluster. This can be installed using
`sparklyr::spark_install()`.

The `SPARK_HOME` environment variable must be set to the output of
`databricks-connect get-spark-home`.

Connect using the following:

```r
library(sparklyr)

spark_home <- [path returned by databricks-connect get-spark-home]

sc <- spark_connect(method = "databricks", spark_home = spark_home)
```

### ODBC
The examples here use the [Spark ODBC driver provided by
Databricks](https://databricks.com/spark/odbc-driver-download). Details for
configuring the driver can be found
[here](https://docs.databricks.com/integrations/bi/jdbc-odbc-bi.html).

For the examples in this repository, a DSN called `databricks` was created in `/etc/odbc.ini`:

```
[databricks]
Driver=Spark 2.6.12
Server=*****************.cloud.databricks.com
HOST=*****************.cloud.databricks.com
PORT=443
SparkServerType=3
Schema=default
ThriftTransport=2
SSL=1
AuthMech=3
UID=token
PWD=***********************************
HTTPPath=sql/protocolv1/o/****************/*******************
```
