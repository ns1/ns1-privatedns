# NS1 Helm Chart

## Configuration

The NS1 infrastructure consists of six services:
- Data
- Core
- DNS
- Dist
- DHCP
- XFR

Each service has it's own configuration block, but they share many of the same
configuration options.

The following tables lists the configurable parameters of the NS1 DDI chart and their default values.

### Global

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `imagePullSecret` | Reference to a secret to be used when pulling images | `docker-creds` |
| `bootstrap` | Boolean value indicating whether to perform an initial bootstrap process after the installation is complete. Setting this to true will create a configmap called ns1-bootstrap-credentials holding initial credentials. This is a blocking operation - the Helm install will not complete until the bootstrap is complete, which requires the deployment to be healthy.  It's recommended to use this in conjunction with the `--timeout` Helm flag set to at least 10 minutes. | `true` |

### Data
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `data.name` | Name to be used for the various data resources. | `data` |
| `data.replicas` | Number of data replicas to run. This should be 1, 3, or 5. | `3` |
| `data.image.name` | The name of the image to use for the data container. | `nsone/standalone_data` |
| `data.image.tag` | The tag of the image to use for the data container. | `2.3.1` |
| `data.image.pullPolicy` | The pull policy for the image. | `IfNotPresent` |
| `data.livenessProbe.initialDelaySeconds` | How long to wait for the data pods to come up before beginning health checks. | `120` |
| `data.livenessProbe.failureThreshold` | How many failed healthchecks are tolerated prior to restarting the pod. | `5` |
| `data.livenessProbe.periodSeconds` | How often to execute healthchecks. | `15` |
| `data.storage.className` | The type of storage to use for the persistent volume claim that the data service uses. | `default` |
| `data.storage.size` | The size of storage to request per data replica. | `5Gi` |
| `data.popID` | The ID of the PoP. | `default_pop` |
| `data.enableOpsMetrics` | Enables operational metrics. | `false` |
| `data.exposeOpsMetrics` | Exposes operational metrics. | `false` |
| `data.startupFlags` | Additional flags to pass to the startup command of the data container. | `{}` |
| `data.resources` | CPU/memory resource requests/limits. | `{}` |
| `data.nodeSelector` | Node labels for pod assignment. | `{}` |
| `data.tolerations` | Node tolerations for pod assignment. | `[]` |
| `data.affinity` | Node affinity for pod assignment. | `{}` |

### Core
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `core.name` | Name to be used for the various core resources. | `core` |
| `core.replicas` | Number of core replicas to run. | `3` |
| `core.image.name` | The name of the image to use for the core container. | `nsone/standalone_core` |
| `core.image.tag` | The tag of the image to use for the core container. | `2.3.1` |
| `core.image.pullPolicy` | The pull policy for the image. | `IfNotPresent` |
| `core.livenessProbe.initialDelaySeconds` | How long to wait for the core pods to come up before beginning health checks. | `30` |
| `core.livenessProbe.failureThreshold` | How many failed healthchecks are tolerated prior to restarting the pod. | `3` |
| `core.livenessProbe.periodSeconds` | How often to execute healthchecks. | `15` |
| `core.popID` | The ID of the PoP. | `default_pop` |
| `core.apiHostname` | The hostname of the NS1 API. | `api.example.com` |
| `core.portalHostname` | The hostname of the NS1 portal. | `portal.example.com` |
| `core.nameServers` | A comma-separated list of nameservers. | `example1.com,example2.com` |
| `core.hostMasterEmail` | An email address for the host master. | `example@email.com` |
| `core.enableOpsMetrics` | Enables operational metrics. | `false` |
| `core.enableWebTLS` | Whether the portal should require TLS. | `false` |
| `core.startupFlags` | Additional flags to pass to the startup command of the core container. | `{}` |
| `core.resources` | CPU/memory resource requests/limits. | `{}` |
| `core.nodeSelector` | Node labels for pod assignment. | `{}` |
| `core.tolerations` | Node tolerations for pod assignment. | `[]` |
| `core.affinity` | Node affinity for pod assignment. | `{}` |

### DNS
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `dns.image.name` | The name of the image to use for the DNS container. | `nsone/standalone_dns` |
| `dns.image.tag` | The tag of the image to use for the DNS container. | `2.3.1` |
| `dns.image.pullPolicy` | The pull policy for the image. | `IfNotPresent` |
| `dns.pops[#].name` | Name to be used for the various DNS resources. | `dns` |
| `dns.pops[#].replicas` | Number of DNS replicas to run at this PoP. | `3` |
| `dns.pops[#].livenessProbe.initialDelaySeconds` | How long to wait for the DNS pods to come up before beginning health checks. | `30` |
| `dns.pops[#].livenessProbe.failureThreshold` | How many failed healthchecks are tolerated prior to restarting the pod. | `3` |
| `dns.pops[#].livenessProbe.periodSeconds` | How often to execute healthchecks. | `15` |
| `dns.pops[#].popID` | The ID of the PoP. | `default_pop` |
| `dns.pops[#].coreService` | The name of the Kubernetes service for core or for a dist service. | `core` |
| `dns.pops[#].operationMode` | DNS operational mode. | `authoritative` |
| `dns.pops[#].enableOpsMetrics` | Enables operational metrics. | `false` |
| `dns.pops[#].startupFlags` | Additional flags to pass to the startup command of the DNS container. | `{}` |
| `dns.pops[#].resources` | CPU/memory resource requests/limits. | `{}` |
| `dns.pops[#].nodeSelector` | Node labels for pod assignment. | `{}` |
| `dns.pops[#].tolerations` | Node tolerations for pod assignment. | `[]` |
| `dns.pops[#].affinity` | Node affinity for pod assignment. | `{}` |

### Dist
By default, dist is disabled (i.e. set to `{}` in `values.yaml`).

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `dist.image.name` | The name of the image to use for the dist container. | |
| `dist.image.tag` | The tag of the image to use for the dist container. | |
| `dist.image.pullPolicy` | The pull policy for the image. | |
| `dist.pops[#].name` | Name to be used for the various dist resources. | |
| `dist.pops[#].replicas` | Number of dist replicas to run at this PoP. | |
| `dist.pops[#].livenessProbe.initialDelaySeconds` | How long to wait for the dist pods to come up before beginning health checks. | |
| `dist.pops[#].livenessProbe.failureThreshold` | How many failed healthchecks are tolerated prior to restarting the pod. | |
| `dist.pops[#].livenessProbe.periodSeconds` | How often to execute healthchecks. | |
| `dist.pops[#].popID` | The ID of the PoP. | |
| `dist.pops[#].coreService` | The name of the Kubernetes service for core. | |
| `dist.pops[#].enableOpsMetrics` | Enables operational metrics. | |
| `dist.pops[#].startupFlags` | Additional flags to pass to the startup command of the dist container. | |
| `dist.pops[#].resources` | CPU/memory resource requests/limits. | |
| `dist.pops[#].nodeSelector` | Node labels for pod assignment. | |
| `dist.pops[#].tolerations` | Node tolerations for pod assignment. | |
| `dist.pops[#].affinity` | Node affinity for pod assignment. | |

### DHCP
By default, DHCP is disabled (i.e. set to `{}` in `values.yaml`).

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `dhcp.image.name` | The name of the image to use for the DHCP container. | |
| `dhcp.image.tag` | The tag of the image to use for the DHCP container. | |
| `dhcp.image.pullPolicy` | The pull policy for the image. | |
| `dhcp.pops[#].name` | Name to be used for the various DHCP resources. | |
| `dhcp.pops[#].replicas` | Number of DHCP replicas to run at this PoP. | |
| `dhcp.pops[#].livenessProbe.initialDelaySeconds` | How long to wait for the DHCP pods to come up before beginning health checks. | |
| `dhcp.pops[#].livenessProbe.failureThreshold` | How many failed healthchecks are tolerated prior to restarting the pod. | |
| `dhcp.pops[#].livenessProbe.periodSeconds` | How often to execute healthchecks. | |
| `dhcp.pops[#].hostMode` | Boolean value indicating whether to run in host mode within Kubernetes. | |
| `dhcp.pops[#].popID` | The ID of the PoP. | |
| `dhcp.pops[#].coreService` | The name of the Kubernetes service for core or dist. | |
| `dhcp.pops[#].serviceDefID` | The service definition ID that this DHCP PoP is responsible for. | |
| `dhcp.pops[#].enableOpsMetrics` | Enables operational metrics. | |
| `dhcp.pops[#].startupFlags` | Additional flags to pass to the startup command of the DHCP container. | |
| `dhcp.pops[#].resources` | CPU/memory resource requests/limits. | |
| `dhcp.pops[#].nodeSelector` | Node labels for pod assignment. | |
| `dhcp.pops[#].tolerations` | Node tolerations for pod assignment. | |
| `dhcp.pops[#].affinity` | Node affinity for pod assignment. | |

### XFR
By default, XFR is disabled (i.e. set to `{}` in `values.yaml`).

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `xfr.name` | Name to be used for the various XFR resources. | |
| `xfr.replicas` | Number of XFR replicas to run. | |
| `xfr.image.name` | The name of the image to use for the XFR container. | |
| `xfr.image.tag` | The tag of the image to use for the XFR container. | |
| `xfr.image.pullPolicy` | The pull policy for the image. | |
| `xfr.livenessProbe.initialDelaySeconds` | How long to wait for the XFR pods to come up before beginning health checks. | |
| `xfr.livenessProbe.failureThreshold` | How many failed healthchecks are tolerated prior to restarting the pod. | |
| `xfr.livenessProbe.periodSeconds` | How often to execute healthchecks. | |
| `xfr.popID` | The ID of the PoP. | |
| `xfr.coreService` | The name of the Kubernetes service for core. | |
| `xfr.enableOpsMetrics` | Enables operational metrics. | |
| `xfr.startupFlags` | Additional flags to pass to the startup command of the XFR container. | |
| `xfr.resources` | CPU/memory resource requests/limits. | |
| `xfr.nodeSelector` | Node labels for pod assignment. | |
| `xfr.tolerations` | Node tolerations for pod assignment. | |
| `xfr.affinity` | Node affinity for pod assignment. | |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release -f values.yml .
```
> **Tip**: You can use the default [values.yaml](values.yaml)
