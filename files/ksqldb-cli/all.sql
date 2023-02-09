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

CREATE SINK CONNECTOR redis_sink WITH (
  'connector.class'='com.github.jcustenborder.kafka.connect.redis.RedisSinkConnector',
  'tasks.max'='1',
  'topics'='players',
  'redis.hosts'='redis:6379',
  'key.converter'='org.apache.kafka.connect.converters.ByteArrayConverter',
  'value.converter'='org.apache.kafka.connect.converters.ByteArrayConverter'
);
