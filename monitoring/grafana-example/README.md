# Example Setup of Grafana Dashboard

## Procedure

### Set up an external InfluxDB

```
# the name 'ns1-external-influxdb' will be used as the host name in the 'ns1' docker network.
docker run --rm -it --network ns1 --name ns1-external-influxdb -p 8086:8086 influxdb
```

### Enable sending external metrics

1. Start your DDI containers:
```
docker-compose up -d core data dns
```

2. Configure telegraf to send metrics to your external InfluxDB:
```
docker-compose exec data supd run \
  --telegraf_output_influxdb_data_host http://ns1-external-influxdb:8086 \
  --telegraf_output_influxdb_database ns1-metrics
```

3. Verify the connection is established
```
docker run --rm -it --network ns1 influxdb influx --host ns1-external-influxdb --execute 'SHOW DATABASES'
name: databases
name
----
_internal
ns1-metrics
```

### Set Up Example Dashboard on Grafana

1. Create a new InfluxDB datasource called "Private DNS Metrics" pointing to the external InfluxDB 
2. Create a new dashboard and select the import JSON option - upload the file in this directory for an example dashboard
3. Create/ modify / delete panels to the dashboard
