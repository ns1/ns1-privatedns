## 2.3.0 (Jan 31, 2020)
- New Features
   - NS1 DDNS Implementation: a filter to on-demand synthesized dynamic records from DHCP leases
- Feature Enhancements
   - DNS: limit record pagination parameter in the v1/zones api endpoint to system limit of 10,000
   - DHCP: enabled API to set lease lifetime (valid-lifetime) at scope level, previously only available at scope group level
   - DHCP: simplified DHCP HA configuration parameter dhcp_peers setting to an array of container hostnames, previously an array of paired container names and hostnames
   - DHCP: changed default always-send to false, DHCP now returns only those options that are requested by a client
   - DHCP:    API support to prevent selecting Scope Groups which are already in use
- What’s fixed?
   - DNS: API performance improvements to record creation, previously a large number of record creation caused the API response times to deteriorate 
   - DHCP: loss of DHCP4 configuration on service restart
   - DHCP:    resolved regression in the ability to specify a custom port for dhcp_peers
   - System: ensure supd logs information to its log file
- Known issues
   - DHCP: the interface parameter is not set on pools limiting IPv6 subnet selection to subnets bound to the interface only
   - DHCP: Leases in pools not configured for NS1 DDNS are placed in the digest table
   - Portal: Domain Controller Port field is highlighted as invalid by default when a user specifies Domain Controller Host Address and AD Domain Name

## 2.2.3 (Jan 24, 2020)
- What's fixed?
   - DHCP: Custom DHCP options can now be removed from a scope
   - DHCP: Fixed several issues around updating reservations
   - DHCP: Fixed an issue where updating a scope would stop it from propagating via the Dist container
- Known Issues
   - DHCP: HA settings ignore custom port for the dhcp_peers option
   - DHCP: Lease renewals do not show up in the portal
   - DHCP: Setting a new dhcp_service_def_id in a dhcp container will not update the DHCP service. Workaround: Restart the DHCP container
## 2.2.2 (Jan 10, 2020)
- What's fixed?
   - DHCP: Fixed issue where portal would not let you use a custom option type with an IP address field
   - DHCP: Fix DHCP high availability (HA) so that it properly load balances and fails over as expected
   - DHCP: Fix DHCP propagation via distribution (Dist) containers when custom options are in use
   - DHCP: Validation now prevents deleting a custom option if it’s applied to a scope group, scope or reservation; to remove a custom option, the objects using it must be modified first
   - DCHP: Fixed an issue where scopes were being removed when updated. To explicitly remove a scope from a scope group, set its scope_group_id to 0
   - DHCP: Fixed an issue where the portal would fail validating correct custom options
   - HA-Data: Running system in HA mode should no longer fill up disk
   - HA-Data: Resolved an issue where database migrations were not applied on first run and Primary flag was lost
   - System: Fixed an issue where services attempted to listen on IPv4 and IPv6 when IPv6 was manually disabled
   - Containers: core and dist containers will now shutdown and restart cleanly
- Known issues
   - DHCP: Custom complex options must follow specific rules for record types, added to article "Managing custom DHCP Options" (https://help.ns1.com/hc/en-us/articles/360040708334-Managing-custom-DHCP-options)
   - DHCP: Option schemas are not displayed in scope’s metadata side pane of the portal
   - HA-Data: Data container Web UI is not displaying correctly in clustered mode
   - DHCP: Reservations cannot be updated after creation; the workaround is to create the reservation with all options and settings desired via the API
   - DHCP: Reservations created in the portal do not display DHCP options and other settings; workaround is to add options and other settings when creating the reservation via API call
   - DHCP: Custom options with an array of integers cannot currently be applied in the portal; a workaround is to apply an array of integers to a scope group, scope or reservation by the API
   - DHCP: Custom options with a hex data type is currently not supported; this data type will be replaced with binary data type in a future patch version and hex data types will be effectively deprecated
## 2.2.1 (Dec 13, 2019)
- What's New?
   - Data: Data containers can now be deployed in a clustered mode
   - RBAC: Active Directory support
   - DNS: Improved zone file imports to be more robust with larger imports
   - DNS: DNAME record support
   - DHCP: It is now possible to define custom options and add them to scopes
   - DHCP: Now supports the use of a DHCP relay
   - IPAM: Many QoL fixes in the UI
   - IPAM: 'Type' field has been renamed 'Status' and 'Assignment' has become 'Assigned'
   - Metrics: Data propagation metrics have been added
   - API: It is now possible to see Service Group and Organization relationship
- What's fixed?
   - DHCP: Scope groups and scopes should properly update when using a dist container
   - DHCP: Renewed leases should now appear in the UI
   - DHCP: Multiple reservations in the same scope for the same device is no longer possible
   - DHCP: echo-client-id option will now be applied to scope if set
   - DHCP: Host reservations should now be honored
   - DNS: Record level metrics are available again
   - DNS: Zone level stats can now be expanded (API)
   - IPAM: Filtering should now work properly on IPAM and DHCP pages
- Known issues
   - DHCP: Creating a complex dhcp option type and using it on a scope does not work and prevents new options from working
   - DHCP: When using custom options AND dhcp is connected to dist, the presence of custom options stops scopes from updating
   - DHCP: optiondef api allows you to delete a custom option even if it is in use
   - DHCP: HA does not sync properly resulting in split brain
   - DHCP: HA can not be set up via container UI
   - DHCP: It is not possible to remove custom options using the UI
   - AD RBAC: AD user is able to observe IPAM and DHCP pages even if assigned Team mapped to AD group does not have permissions for IPAM and DHCP
   - DNS: Failed zone import keeps the zones in the system

## 2.1.1 (Sept 20, 2019)
- What's fixed?
   - (NS1 portal) View lease information via the portal (previously viewable via API only).
   - (Configuration) Automatic bootstrapping form validation.
   - (Configuration) Ability to update container configuration settings via CLI or API, even if it was initially configured via the web interface.
   - (Configuration) Ability to specify a port for core_host (DNS and DHCP containers), data_host (CORE container), data_peers (DATA container) and dhcp_peers (DHCP container) in the form of hostname:port. Note: If no port is supplied, it will default to 5353.
   - Ability to add host reservations without specifying a specific IP address.
   - Added missing replication metrics for DIST and CORE containers. 
   - Fixed “Generate Runtime Report” action for DHCP containers. (DDI only)
   - DHCP option data types. (DDI only)
   - Miscellaneous bugs fixes and UI/UX enhancements.
- Known issues
   - (NS1 portal) In the Zones page, aggregate record counts indicate only one record, even when more than one record is present.
   - (NS1 portal) Operator users signed into the portal are unable to access IPAM and DHCP page and functionality. Current workaround: Sign in as an application user of the organization, or perform actions via API.
   - API calls for uploading zone files with the async option enabled (i.e. ?async=true) return an internal server error.

## 2.1.0 (Aug 19, 2019)
- What's New?
   - For the latest Installation & Setup Guide, visit: https://help.ns1.com/hc/en-us/articles/360034124053
   - Renamed `web` to `core` container
   - Renamed `cache` to `dist` (distribution) container to disambiguate its function
   - Increased password complexity requirements
   - Enhanced security for API key secrets
   - Added new database layer for increased capacity and protections for referential integrity
   - Extended portal navigation to include IPAM and DHCP pages
   - Added ability to create and manage IP address objects including split, merge, bulk delete
   - Added ability to search and filter subnets
   - Added IPAM user-defined metadata in the form of tags and custom attributes
   - Added ability to create and modify DHCP server and scope settings and options
   - Added view and manage permissions for IPAM and DHCP
   - Improved performance of container configuration daemon to reconfigure in seconds
   - Added support for customized data replication across networks
- Known Issues
   - A zone in two or more networks cannot be re-pooled; the workaround is to delete the zone and recreate it with new network pool value(s); zones in a single network pool can be re-pooled without this workaround
   - A /32 or /128 host currently assigned with a reservation cannot be deleted from the IPAM interface; the workaround is to delete the corresponding reservation first before deleting the address objects
   - Container configuration web interface: Configuration lists do not allow reconfiguration; instead of using the web interface to modify these lists, the workaroud is to use the CLI or HTTP REST API configuration (e.g. docker exec -it dns supd run --data_service_defs 1-10); this is applicable to lists of data_peers in the data container and data_service_defs in the dns and dist containers.
   - Multiple scope groups should not be assignable to a single DHCP service. If this action is taken, the DHCP service (Service Definition) will be returned multiple times in the dropdown for scope & reservation assignment and or when editing settings on the DHCP service.
   - Creating a zone w/o a service group or corresponding DNS pool existing returns a 500 error; workaround the limitation by creating a service group, associating it with the organization, and defining a DNS pool.
   - Automatic bootstrap default operator username has invalid characters; workaround the limitation by removing capitalization for the operator's username before submitting the form.
   
## 1.1.1 (Apr 18, 2019)
- What's New?
   - Added ability to configure zone and record pagination limits (i.e. beyond 2500) of `web` containers
   - Miscellaneous UI and UX improvements to configuration pages
- What's Fixed?
   - Fixed issue with `web` container health checks resulting in false positives
   - Fixed issue where operator users logged into the portal could not create users, apikeys, or teams on behalf of an organization
   - API and In-Memory database no longer need to be restarted after a `data` container failover event
   - Miscellaneous UI bugs in the NS1 portal

## 1.1.0 (Nov 2, 2018)
- What's New?
   - Added failover support for data container; operate a "primary" and one or more "replica" data containers to achieve this configuration
   - Added `data cache` container to act as a local copy of `data` at the edge for very distributed deployments
   - Added support for Promethius as a target for exporting operational metrics
   - Added TLS options for exporting operational metrics to other systems
   - Added Cost filter to supported filters in Traffic Management category
   - Added action to `Restore Main Database` in the `data` container's configuration page
   - Added json support to supd commit endpoint allowing scripting of configuration changes across many containers at once
   - Added ability to view real-time stream of container logs in the supd web UI
   - Added more actions to restart individual container services
   - Miscellaneous UI and UX improvements to configuration pages
- What's Fixed?
   - Fixed issue with data container hostname; see 1.0.3 Known Issues
   - Fixed issue with recursor caching of zones for which the system is authoritative
   - Fixed issue with GeoIP file upload missing the option for ASN `.mmdb` files
   - Miscellaneous UI bugs in the NS1 portal
- Known Issues
   - `dns` containers in `Recursive Resolver` mode does not support ECS client subnet; this means for zones which the system is authoritative certain filters (Geotarget, Geofence, and Netence filters) ignore client IP

## 1.0.4 (Sept 21,2018)
- What's Fixed?
   - Allow creation of RFC 1918 reverse DNS zones for private IPs

## 1.0.3 (Aug 24, 2018)
- What's Fixed?
   - Config options for forwards now distinguishes between forwards to recursive resolvers and forwards to authoritative servers
   - Fixed action: "Restart In-Memory Database"
   - Fixed inability to delete forwards
   - Fixed inability to configure forwards via CLI
- Known Issues
   - Once a data container hostname is set it cannot be changed internally or the data will be unreadable; we recommend operators keep the hostname the same after first standing up the data container

## 1.0.2 (Aug 8, 2018)
- What's Fixed?
   - Bugs squished with filter chain configuration
   - Password change endpoints and 2fa re-enabled for portal users

## 1.0.1 (Aug 1, 2018)
- What's Fixed?
   - Actions no longer clear changes made to configuration manager
   - Added per process operational metrics
   - Miscellaneous UI bugs in the NS1 portal
- Known Issues
   - Password changes must be performed via API call; these functions are unavailable in the portal interface at this time; see section 11.6 Reset a User’s Password

## 1.0.0 (Jul 25, 2018)

- What's New?
   - First generally available version of Private DNS
   - Added certificate management for unified transport layer security
   - Added Basic Authentication credentials to access container configuration, initialized to ns1/private
   - Added operators, organizations, teams, users, and API keys
   - Added bootstrap, operator, and organization endpoints for multi-tenant support
   - Added recursive resolver mode and support for zone forwards to dns container
   - Added cache containers for scalability, resiliency, and performance improvement at the edge of distributed networks
   - Added axfr support for secondary zones
