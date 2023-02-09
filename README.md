# KSQLDB: Kafka Connect Overview

## Running Locally
We're deploying the following components with Docker compose:

- Zookeeper
- Kafka
- ksqlDB server (With Kafka Connect)
- ksqlDB CLI
- Schema Registry (To keep the schema of the data)
- MySQL
- Redis

## KSQLDB and Kafka Connect
The KsqlDB server will run also Kafka Connect, so that we can create source and sink connectors.
There are a couple of things to consider in the deployment:
 1. We need to install the connectors required for our components. In this case we will use JDBC Source Connector for MySQL and Redis Sink Connector for Redis.
 2. We also need to add the MySQL Driver to our ksqldb-server container.
 3. The file [run.sh](files/ksqldb-server/run.sh) contains all the commands to install the connectors and copy the MySQL driver to the right location.
 4. In the [ksqldb-server](files/ksqldb-server) folder we also have the [ksql-server.properties](files/ksqldb-server/ksql-server.properties) which is quite simple, but it also points to the [connect.properties](files/ksqldb-server/connect.properties) which is a bit more complex.
 5. In the [ksqldb-cli](files/ksqldb-cli) folder we have the SQL scripts that we will run manually to create the connectors to get data from MySQL into Kafka and from Kafka into Redis

## MySQL deployment
The MySQL instance will have a database called `football`. Inside that DB, there will be a table called `players` and there will be `10` players already inserted in it.
The init script can be found here: [init.sql](files/mysql/init.sql). This script creates the db, the table and the data.

## Start the containers
To start running all the containers, just run:
```sh
docker-compose up &
```
Then run the following to connect to use the `ksql-cli`:
```sh
docker-compose exec ksqldb-cli ksql http://ksqldb-server:8088
```

## Create the connectors
Once we are logged in to the ksqldb-cli, we can create the connectors that are found in the script [all.sql](files/ksqldb-cli/all.sql).

First create the MySQL Source Connector:
```sql
CREATE SOURCE CONNECTOR mysql_source_connector
WITH (
  'connector.class' = 'io.confluent.connect.jdbc.JdbcSourceConnector',
  'connection.url' = 'jdbc:mysql://mysql:3306/football',
  'connection.user' = 'root',
  'connection.password' = 'root',
  'table.whitelist' = 'players',
  'mode' = 'incrementing',
  'incrementing.column.name' = 'id',
  'topic.prefix' = '',
  'key'='id'
);
```
This tells KsqlDB that we want to create a connector that will read data from the `players` table and will insert it into kafka. Because we declared the converter in the [connect.properties](files/ksqldb-server/connect.properties) file, we don't need to specify the converters here.

Then we can verify that our connector was created by running:
```sql
SHOW CONNECTORS;
```
By default, Kafka Connect will create a new topic and will call it the same name that the table has.
We can verify that the `players` topic was created in kafka with this command:
```sql
SHOW TOPICS;
```

Now let's create the Redis Sink Connector. Run this script:
```sql
CREATE SINK CONNECTOR redis_sink WITH (
  'connector.class'='com.github.jcustenborder.kafka.connect.redis.RedisSinkConnector',
  'tasks.max'='1',
  'topics'='players',
  'redis.hosts'='redis:6379',
  'key.converter'='org.apache.kafka.connect.converters.ByteArrayConverter',
  'value.converter'='org.apache.kafka.connect.converters.ByteArrayConverter'
);
```
This creates a new Redis Sink Connector that will get the data from the `players` topic and put it into Redis.
Notice that we define the converters for key and value as `ByteArrayConverter`, since we want to store the Avro into Redis. Since Avro is a binary format, we can use the `ByteArrayConverter` to save it into Redis as a Byte Array.

## Verify the data is now in Redis
To do this, connect to the redis command line tool running this in a new terminal:
```shell
docker-compose exec redis redis-cli
```

Once logged in to the Redis server select the database 1 with this command:
```sh
SELECT 1
```
Finally, you can run the command to get the value corresponding to the key 1:
```sh
GET 1
```

You should see something like this:
```
"\x00\x00\x00\x00\x01\x02\x18Lionel Messi\x12Paris Saint-Germain\x16Argentinian"
```
Some of it is not readable. But because we have some string values, we can make sense of it and we know that this information belongs to the first record in our table, which is "Lionel Messi".
