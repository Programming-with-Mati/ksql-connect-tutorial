#! /bin/bash

COMPONENT_DIR="/home/appuser"
CONNECT_PROPS="/etc/ksqldb-server/connect.properties"
CONFLUENT_HUB="/home/appuser/bin/confluent-hub"

# install the jdbc connector
$CONFLUENT_HUB install confluentinc/kafka-connect-jdbc:10.0.0 \
  --component-dir $COMPONENT_DIR \
  --worker-configs $CONNECT_PROPS \
  --no-prompt

# install the redis sink connector
$CONFLUENT_HUB install jcustenborder/kafka-connect-redis:latest \
  --component-dir $COMPONENT_DIR \
  --worker-configs $CONNECT_PROPS \
  --no-prompt

# Copy the MySQL driver to the right location
cp /etc/ksqldb-server/mysql-connector-j-8.0.32.jar /home/appuser/confluentinc-kafka-connect-jdbc/lib

# start the ksqldb server
ksql-server-start /etc/ksqldb-server/ksql-server.properties
