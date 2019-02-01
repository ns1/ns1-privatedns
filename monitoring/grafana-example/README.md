# Example Setup of Grafana Dashboard

## Procedure

### Expose & Enable Metrics

1. Set `expose_ops_metrics` to `true` at data container
2. In config `enable_ops_metrics` must be `true` on edge containers so that the captured metrics can be sent to the data container
3. Expose the metrics port in the compose file: `- “8686:8686” # Metrics`
4. There are two databases available to query for metrics: `ns1-ops-metrics` and `ns1-app-metrics`
5. The metrics database can then be queried at `http://<host>:8686/` using InfluxDB’s querying language

### Set Up Example Dashboard on Grafana

1. Create a new InfluxDB datasource called "Private DNS Ops Metrics" pointing to the exposed data container
2. Create a new dashboard and select the import JSON option - upload the file in this directory for an example dashboard
3. Create/ modify / delete panels to the dashboard
