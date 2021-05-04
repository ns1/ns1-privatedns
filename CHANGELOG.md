## 3.3.3 (May 4, 2021)
- New Features
  - DHCP: Update utilization stats now include gateway/broadcast IP addresses
  - DHCP: Search address by prefix includes target’s parent
  - DHCP: DHCP now stores DUID and client ID in lease object
  - DNS: Allow the use of multiple XFR containers
  - DNS: Set up batch transfers for zone updates
  - DNS: Display zone serial number
  - DNS: Portal now shows an alert re. hijacking risk when removing a domain
  - DNS: Portal now expose the SOA name server field
  - IPAM: Display gateway and broadcast addresses in IPAM
  - System: Added a database backup integrity check
  - System: Improved debug log file collection 
  - System: DDI now supports SSO - MVP
  - System: Email address and username can have special characters

- What’s fixed?
  - DNS: Fixed issue whereby query limits are being ignored
  - DNS: Fixed issue where you cannot add a reverse zone using the portal
  - DNS: DDNSD updates become unhealthy after pruner runs
  - DNS: Primary zone can not be configured for zone transfers
  - DNS: Edit filter chain after creating a A record results in blank page
  - DHCP: NS1 DDNS, zone handle used instead of domain when zone is in a view
  - DHCP: Fixed issue where the list search doesn’t stop
  - DHCP: Scopes option box shows the wrong ScopeGroup name
  - DHCP: Allow for creation of an address as a gateway
  - DHCP: Cannot set lease duration option in the scope UI
  - DHCP: Fixed issue which resulted in a blank page on reservation all lease tab
  - DHCP: Improved IPAM address insert performance
  - DHCP: Lease time and related renew/rebind timers have API/UI limitation and are incorrectly stored in KEA
  - Security: Fixed OpenSSL Vulnerability - updates for LibSSL and OpenSSL 
  - System: Updated health check for minimum disk 
  - System: Added SAML endpoints
  - System: Updated disk containers health check message
  - System: Fixed issue whereby DIST container would become healthy after failing snapshot
  - System: Added default values for Core, Data, Dist service definitions in the bootstrap wizard
  - System: Fixed issue whereby you couldn’t get to the monitor container from the service types panel
  - System: The services types health check page initially shows incorrect data
  - System: The UI is not updating even though it is being polled
  - System: Request being sent to the wrong definition ID is not triggering an error
  - System: Wrong container is displayed after configuring multiple core containers
  - System: Added DIST container rebalance timer

## 3.2.6 (March 19, 2021)
- New Features
  - CORE: Automate debug collection from a DDI install

- What’s fixed?
  - CORE: Fixed a post-upgrade issue where data replication from DIST to the DNS service was not complete
  - CORE: Fixed a data restore issue
  - CORE: OpenSSL/LibSSL have been patched to address CVE-2020-1971
  - DHCP: Fixed an issue where the Scope’s Option tab showed an incorrect ScopeGroup name
  - DNS: Fixed an issue where a secondary zone  configured with a TSIG key would not show this key in the AP or UI, instead showing the zone as if no TSIG key was configured

## 3.2.5 (February 19, 2021)
- What’s fixed?
  - DHCP: Allow reservations with same identifier but in different subnets
  - DHCP: Fixed an issue where creating a custom DHCP option definition would trigger the API and UI to respond with an Internal Server Error
  - DHCP: Fixed an issue where it was not possible to select array when creating a custom DHCP option
  - DHCP: Fixed an issue where saving a Scope Group with a large number of Scopes and Reservations could fail with a 504 gateway timeout
  - DHCP: IPAM get next endpoint returns an address already in use
  - DHCP: Scope group “Match Client ID” checkbox is out of sync with default value
  - DNS: Fixed an issue where you cannot modify the nameserver associated with a DNS service if there is a view associated with it
  - DNS: Fixed an issue where an ACL/View erroneously could prevent DNS resolution
  - IPAM: Fixed an issue where subnets were not enclosed correctly
  - Portal: Validate totp minlength to prevent causing backend 401 error
  - Portal: Fixed an issue where a record could not be cloned to the root of any zone
  - Portal: Fixed an issue where the portal becomes unresponsive when viewing a DHCP scopes range
  - Portal: Fixed an issue where multiple calls to an endpoint were made where only one is needed
  - Portal: Persist show reserve zones checkbox
  - Portal: Optimized Template view for large IPAM dataset
  - System: Fixed slow response from portal - API returning code 500 
  - System: Fixed an issue which results in possible data loss during certain types of primary failover
  - System: Fixed an issue where the oplog will fill up entire disk over time
  - System: Fixed an issue where the services endpoint would not show a service definition with a Scope Group attached
  - System: Fixed issue with Dist going unhealthy during stress testing
  - System: Fixed an issue with the upgrade database migrations

- Known Issues:
  - DHCP: An invalid configuration is possible where DHCP reservations are made outside a Scope definition
  - DHCP: After API import of a large number of Scopes, subsequent initial DHCP configuration deployment takes 3+ hrs


## 3.2.4 (January 26, 2021)
- What’s fixed?
  - DHCP: Batch updates for leases to improve overall performance
  - DHCP: Enable multiple DDNS zones per scope groups for NS1 DDNS
  - DHCP: Relays are not being set when creating a scope
  - DNS: Cannot change DNS Service Group associated with a zone
  - DNS: Cannot create tags with empty string for bot zones and record objects
  - DNS: Fixed handling of non-FQDNs during IXFR
  - DNS: Fixed migration from older versions of DDI that do not have DNS Tagging
  - Monitoring: Target IP does not support private IPv4 addresses
  - Portal: Add secondary zone - primary IPs not being displayed in portal
  - Portal: “By Tags” filter in IPAM networks does not work in portal
  - Portal: Persist show reverse zones checkbox
  - Portal: Performance improvements to support mid-sized deployments
  - System: Resolved an issue where restarting data containers resulted in configured options reverting to bootstrapped values
  - System: Increased max_connections to 200
  - System: Improved handling of search queries with malformed arguments
  - System: server_id and pop_id should only be enabled at the node level
  - System: Resolved an issue where removal of a configuration could cause the container to go out of sync


## 3.2.3 (December 22, 2020)
- New Features:
  - Cloud-sync: AWS RTE53 support for VPC’s, Zones and Records
  - DHCP: Custom Options
  - DHCP: Relay Agent Support
  - DHCP: Ping Check Support - Ping before giving out a lease
  - DHCP: PXE Boot Support
  - DHCP: Support multiple target DNS servers for one zone
  - DHCP: TSIG, GSS-TSIG support
  - DNS: GSS-TSIG support
  - DNS: Tag support for records and zones
  - IPAM: Get Next Subnet and Address
  - Portal: Dashboards for DHCP and DNS
  - System: Service Control Center: Bootstrap support, centralized maintenance of containers
- Feature enhancements:
  - DHCP: On Editing DDNS Settings for the scope group, the existing zone name is now displayed as a value.
  - DHCP: Template CRUD for Scope/Reservation/Pool
  - IPAM/DHCP: Enhancements to metadata tags and corresponding tag inheritance enables efficient search and discovery of IPAM and DHCP assets
  - System: improved the labels and description of configuration options in SCC
  - System: show the associated Service Definition for each container in SCC
- What’s fixed?
  - API: Cannot delete org via the operator key in IPAM/DHCP endpoints
  - API: Creating a zone in a service group fails with error 500
  - API: Show context help on tag restrictions next to tag mgr elements in "create object" modal
  - API: Value of 0 in SOA record results in internal server error
  - API: Setting secondary IP ACL against zone object to CIDR network fails
  - DHCP: Edit DDNS Settings" on the DHCP Scope Group no longer works
  - DHCP: Even though the update is successful, we still log an "unsupported value type"
  - DHCP: Selecting multiple servers as the target for a remote zone causes the UI to not display that anything is configured in the DDNS configuration modal
  - DHCP: Remote server in ALL mode; updating remote servers is serial resulting in delayed updates during 1 server's failure.
  - DHCP: Assigned/planned status is not always honored when creating subnets or changing them in the metadata panel
  - DHCP: No warning message when delete in-use client class
  - DHCP: After loading a large number of DHCP scopes and reservations, the scope group can no longer be displayed. Portal fails with "Internal Server Error".
  - DHCP: Can't remove the last client class from the scope group because  the "submit" button is disabled when the client class list is empty.
  - DHCP: If relays were passed on scope creation those relays are not being set.
  - DHCP: The usage bar and number appearing under the "Usage" tab for both Scope Groups and Scopes show 0%, despite a Scope being completely used by leases.
  - DNS: Fixed an correct response with overlapping tags
  - DNS: Fixed XFR scheduler race condition which results in multiple schedulers being created
  - DNS: Creating a secondary zone automatically enables TSIG
  - DNS: Creating a new zone in UI and uploading file results in unresolvable resource records
  - DNS: DDI no longer supports RDNS stats - error 500
  - DNS: It should not be possible to put two zones with the same FQDN into the same view. This applies to default views as well.
  - DNS: Blocking Inheritance of tags in DNS
  - DNS: Applying a tag in filtered record view applies the tag to the first record (even if it was intended for another record)
  - DNS: Prereq windows appears to send a specially crafted nonsecure update packet which AD  - DNS responds to with noerror, even if updates on zone are secure only.
  - IPAM: Updates to a linked record in the IPAM address update endpoint do not actually update the linked record.
  - IPAM: ipam/address/merge endpoint will set all merged tags to local_tags when some should be considered inherited
  - Monitoring: Cannot set the target "IP address or hostname" field of a new monitor to a private IPv4 address.
  - Monitoring: Update status locally
  - Portal: Portal window goes blank when selecting (viewing) a client class with a vendor-encapsulated-options-space Option associated with it.
  - Portal : Scope edit settings UI fails
  - Portal: When using the ALL update strategy for remote servers on a DDNS remote zone, the logs only show that one server is updated multiple times.
  - Portal: Dashboard, fix View DHCP permissions when user is not authorized
  - Portal: Dashboards, LPS without scope groups
  - Portal: Can't return to the TAGs tab after clicking on ANSWERS tab
  - Portal:  Hyphens still ignored by portal
  - System: IP whitelisting on team not applied
  - System: HAProxy timing out when migrator/upgrade and restore tasks take too long
  - System: SCC: Service Definitions don’t work after global values
  - System: SCC: Node specific “Clear All” in the UI does not work
  - System: SCC: Disable node specific config options
- Known Issues:
  - Database: Any sufficiently populated database will start exhibiting massive CPU usage spikes every 30 seconds.
  - Monitoring: Currently, unless running in net=host, the monitor container will advertise its docker IP to the rest of the cluster to connect to due to it being unaware of the actual host IP.
 

## 3.2.1 (November 11, 2020)
- New Features:
  - API: new next address endpoint able to retrieve next available subnet of a specified size.
  - DHCP: ability to configure a ICMP or ARP ping check before issuing an IP in a lease.
  - DHCP: it is now possible to assign multiple target DNS servers to a remote zone
  - DHCP: DHCP Option templates for Scope Groups.
  - DHCP: remote servers can now be configured for TSIG updates.
  - Monitoring: HA for monitoring edge containers.
  - System: Service Control Center (SCC): improved bootstrapping wizard and service health checks and operator portal.
  - Portal: new landing page with dashboards for: QPS, monitoring, DNS/DHCP/IPAM activity.
  - Portal: IPAM/DHCP tagging with inheritance.
- Feature enhancements:
  - Portal: extended search functionality.
- What’s fixed?
  - DHCP: resolved an issue where restricting a subnet to a specific Client Class did not work.
  - DNS: Fixed an issue where changing the DNS network resulted in a server error
  - IPAM: splitting a subnet in IPAM creates local tags when it should inherit them.
  - Monitoring: the target IP address of a monitoring task can now be a private IPv4 address.
  - Portal: resolved an issue where option codes could not be re-used in separate DHCP
  - System: Resolved an issue where health checks could report invalid state.
 option spaces.
  - Portal: resolved an issue where the DHCP filter was not available in the list of filters.
  - Portal: Bootstrap portal does not force password length validation.
- Known Issues:
  - IPAM: merging two subnets in IPAM creates local tags when it should inherit them.


## 3.1.5 (November 10, 2020)
- What's fixed?
  - DHCP: Fixed an issue where lease may have been lost when the Core container goes unhealthy
  - DHCP: It is now possible to disassociate a Service Definition from a Scope Group that has active leases
  - DNS: Fixed an issue where the DHCP filter was no longer available
  - DNS: Fixed an issue where changing the DNS network resulted in a server error
  - Portal: Fixed an issue where DHCP and IPAM tabs in the Portal were missing after first bootstrap
  - System: Fixed an issue where multiple Core containers could not reach the database when the Data containers are configured in Manual Failover mode
  - API:  When omitted, the manage_auth_tags permission is now added by default and set to true when creating a user or key


## 3.1.4 (October 22, 2020)
- New Features
  - DHCP: It is now possible to configure match-client-id on Scopes and Scope Groups. This allows client-class selection to use a combination of both the client identifier and the MAC address or just the MAC address
- Feature Enhancements
  - DHCP: it is now possible to delete a Scope and its associated DHCP reservations in one operation after confirmation
  - DHCP: the DHCP reservation workflow now supports DNS Views for host and reverse record
  - DHCP: NS1 DDNS now supports DNS views
  - DNS: Improved performance of DNS API endpoints
  - DNS: Improved performance of AD DDNS updates
  - IPAM: Portal optimized when fetching the next available addresses
  - Portal: Initial bootstrapping wizard now requires passwords to be entered twice and match
  - Portal: can now create DHCP reservations based on MAC, Client ID, DUID or Circuit ID
  - Portal: it is now possible to search for subnets by starting octets
  - Portal: it is now possible to search for subnets by one or more tag and tag:value pairs
  - Portal: It is now possible to specify a relay address on a Scope
- What’s Fixed
  - DNS: Fixed a potential connection leak in the DNS container
  - DNS: the MNAME for a DNS zone which is contained in a DNS view now reflects the correct nameserver
  - IAM: Fixed users and apikeys endpoints to set ‘manage_auth_tags’ to true unless explicitly set to false per API convention
  - IAM: Fixed Internal Server Error when creating API keys with only a name in the request body
  - Portal: Fixed an issue where Option 43 could not be applied to a ScopeGroup or Client Class
  - Portal: Fixed several UI issues related to Client Classes
  - Portal: Fixed an issue where DHCP Reservations could not be removed in the DHCP tab
  - Portal: DHCP Standard options checkbox now responds correctly
  - Portal: nameservers are now shown correctly for a DNS zone contained in a DNS view
  - Monitoring: Operational metrics are now correctly being collected for the monitor container
  - System: Fixed an issue where services attempted to listen on IPv4 and IPv6 when IPv6 was manually disabled
  - System: Corrected the /v1/network endpoint to return DNS service definitions instead of Service Groups. Fixed several locations in the Portal which uses that endpoint
  - System: Fixed inability to use hyphens in data_host hostnames.
  - System: Fixed an issue where the supd UI could not be displayed
- Known issues
  - DHCP: Disassociating a service definition from a scope group with active leases fails



## 3.1.3 (September 25, 2020)
- New Features
  - DHCP: Added the ability to specify DHCP relay IP addresses on a scope for subnet selection
  - Portal: It is now possible to create custom option space and encapsulate them
  - Portal: DHCP Client Class Match management
- Feature Enhancements
  - API: IPAM search endpoint can now sort by prefix and mask
  - API: IPAM search endpoint can now filter on multiple masks
  - API: Increased performance of all the IPAM insert endpoints
  - Portal: Increased performance of IPAM, DHCP and DNS portal
  - System: Added new exportable metrics to track internal connection state
  - System: Added new health check for stale data to detect propagation issues in Dist containers
  - XFR: Increased performance and scaling of XFR service
- What’s Fixed
  - API: Increased default rate limit for zones and records
  - API: Fixed an issue where users associated with a team do not correctly inherit tags_deny from a group
  - API: Fixed an issue where record Level Permission No Longer Working on Paged Records
  - DHCP: It is now possible to change the Reservation Identifier on a reservation
  - DNS: Fixed an issue where the DNS container would send a SERVFAIL when the client edns udp payload size is 0
  - System: Fixed an issue where the Data container configuration would not save properly during the bootstrap wizard
  - System: Fixed an issue where cluster mode health checks could hang indefinitely and use up resources
  - System: Fixed an issue where the Core container could sometimes report healthy after boot too early
  - System: 5 node HA Data cluster mode now works properly
  - System: Health checks for the Data and Core containers will no longer show as “Unhealthy” before bootstrap
  - System: Fixed an issue where the Dist container would suddenly permanently stop replicating data from core
  - System: HA Data Cluster mode no longer incorrectly requires the environment variable DATA_PRIMARY to be set
- Known issues
  - API: "manage_auth_tags": true is not added by default to empty permissions body, this prevents adding auth tags when API convention says it should be allowed
  - DHCP: Windows presents an error that states “Changing the Primary Domain DNS name of this computer failed” when joining a Windows domain


## 3.1.2 (September 14, 2020)
- New Features
  - DHCP: Added the ability to configure decline-probation-period (API only)
  - Portal: Added management of DHCP Option Spaces
- Feature Enhancements
  - DHCP: Client classes can now be associated with multiple scope groups, and vice versa
  - System: Removed spurious HAProxy warnings from logs
  - System: Removed spurious TSDB health warnings from logs
  - System: Improved long term stability of the Core container while under load
  - System: Added an improved health check for the monitoring process
  - System: Added an improved health check for the API process
  - System: Increased performance of the control plane
  - System: Auto-generated certificates are now ECDSA
  - System: Added more logging to the Data container while in HA mode
  - Monitoring: Added the ability to configure max_reconnect_attempts and reconnect_backoff_interval to allow for connectivity issues on container startup
- What’s Fixed
  - API: Fixed an issue that caused updating a team to fail, if the users were in the body of the message and not permissions
  - API: Fixed an issue that caused the API to return 404 when trying to reset a password
  - API: Existing TSIG is retained when making unrelated updates to a zone
  - API: Fixed an issue where deleting a data source with feeds caused a 500 error
  - DNS: Fixed an issue where adding new zones would fail when using multiple organizations
  - DNS: Fixed an issue with incorrect mname in SOA record being set when not selecting a network for a zone
  - System: It is now possible to use “strict mode” when using custom transport certificates
  - System: Fixed an issue where API connections were not cleanly closed and could add up
  - Monitoring: Fixed an issue where the monitor container would fail to connect to Core
  - Portal: Fixed an issue where invite URL’s would redirect to the login page
  - Portal: Fixed an issue where DNS service definitions would appear in the Service Definition dropdown on the DHCP Scope Group configuration modal
  - Portal: Fixed an issue where creating a zone without a Network selected still resulted in a network being selected
- Known issues
  - DNS: Adding a Data Feed to a record which does not have a Network associated to it will fail
  - DHCP: Empty Option Spaces can only be deleted via the API
  - DHCP: New lease information may be lost if the Core container restarts or dies
  - Portal: It is not possible to click the “Show Standard Options” checkbox when viewing DHCP Options
  - Portal: It is not possible to create a custom option with an option code that exists in any other option space
  - Portal: No nameservers are shown on the nameservers tab


## 3.1.0 (August 14, 2020)
- New Features
  - DNS: dynamic DNS updates – both unsigned and GSS-TSIG signed– are now supported; delivered as part of our AD integration
  - DNS: DNS views are now supported using ACLs to control read and updates access, support use cases such as split-horizon DNS
  - DNS: DHCID records are now supported
  - Portal: ACLs are now available, allowing access rights to be specified using source subnets, IP ranges, TSIG keys or GSS-TSIG identities
  - Portal: new bootstrap wizard to easily configure the containers
  - Portal: DNS views can be ordered through a drag and drop process
- Feature Enhancements
  - DHCP: Remote server can now be configured for nonsecure, nonsecure followed by secure, or secure only updates
- Known issues
  - DHCP: disassociating a service definition from a Scope Group fails when there are outstanding leases
  - DNS: setting only an update ACL on a view will disallow all reads
  - Portal: unchecking the Network on a zone results in an incorrect MNAME in the SOA record
  - Portal: “invalid keytab” error message will carry over on modal between DNS and Security tab
  - Portal: saving a zone with a view selected but no network, results in the network being checked


## 2.5.6 (July 31, 2020)
- New Features
  - DHCP: custom option spaces enabling sub-options to be created for options in the standard option space; API only.
- Feature Enhancements
  - DHCP: Leases persist upon DHCP container restart when using a persistent data volume in docker
  - Portal: DHCP Remote server can now be configured with nonsecure, nonsecure then secure, and secure only updates, in line with Microsoft AD DNS
  - Portal: Domain names can now contain underscores
- What’s fixed?
  - API: The /service endpoint now includes DNS service definitions
  - DHCP: Reduced load on the data layer when adding new leases to the system
  - DNS: Fixed an issue where a DNAME record did not properly occlude non-apex records
  - Portal: Dark mode tooltips are easier to read
  - Portal: Fixed an issue when visiting to the login page would immediately present an “Unauthorized” error message
  - System: Fixed an issue that prevented changing the number of DNS processes in the DNS container to a lower value
  - System: Fixed an issue where logging in the DNS container would hang
- Known issues
  - Portal: Service definitions with duplicate names will not properly display


## 2.5.5 (July 24, 2020)
- New Features
  - Portal: Added hotkeys for navigation and common tasks (e.g. create zone) in DNS interfaces; view available hotkeys by pressing ? and opening the hotkey menu
- Feature Enhancements
  - Portal: Updated interface pages for DNS to improve navigation, reduce negative space, and consistency of experience with IPAM and DHCP pages
  - DHCP: DHCP DDNS update behavior is now configurable per remote server as secure-only, unsecure-then-secure, or unsecure-only (API only)
  - DHCP: Added a revised leases page to the Portal improving readability
  - System: Reduced the DHCP container image size by 58%
  - DHCP: It is now possible to assign multiple IPv6 addresses and reservations per hardware ID within a scope
- What’s fixed?
  - DHCP: Fixed an issue where removing a DHCP service definition and its association to a Scope Group would not remove the DHCP configuration from the DHCP container
  - DHCP: Fixed an issue where a large number of leases over a short amount of time could lock up the data container
  - DNS: Fixed an issue that caused the Geotarget Country filter to stop working over time when using geographic subdivisions
  - IPAM: Fixed error response issue where creating an address object without the status parameter returned an internal server error
  - Monitor: Ping monitor now works as expected
  - Portal: Fixed issue with Unauthorized errors appearing at the login page after bootstrapping
  - System: Fixed an issue where the management interface would not serve TLS upon first boot, even if configured properly
  - System: Fixed an issue where selecting only view permissions on IMAP/DHCP would result in a view that was not read only
  - System: Internal services have had hyphens removed from their names and are now more CA friendly
  - System: Fixed an issue where failed 2FA login attempts were logged as successful logins in the Activity Log
  - System: Fixed an issue which caused a large amount of spurious logging from all containers
  - System: Fixed an issue which prevented operators from resetting 2FA for users
  - System: Fixed an issue that prevented Strict Transport security from working properly when using custom settings
  - System: Fixed activity log entries for management of accounts’ two factor authentication (2FA)
  - System: Fixed service proxy connection leak
  - System: Fixed an issue where data containers would not restart correctly if in clustered mode
- Known issues
  - API: Scope Group names are not unique per organization which may lead to confusion
  - Portal: DHCP leases tab requires a refresh in order to display the correct leases
  - Portal: Visiting the portal login page shows an unauthorized error message before login. Workaround: Close message and login
  - System: Database restore can sometimes hang. Workaround: Manually stop these services before restore - seed_db, seed_tsdb, mem_db, timeseries_db, main_mq, telegraf - using sv force-stop <service name>
  - System: Database restoration from a lower version, then upgrading the database will not work as expected.

## 2.5.3 (June 19, 2020)
- Feature Enhancements
  - API: The records API now requires record type along with the record name when requesting a paginated set of records
  - API: The GET /ipam/address/:id/adjacent route now distinguishes between a bad prefix and no adjacent addresses upon error
  - DHCP: Reduced the amount of spurious logs generated by the DHCP container
  - Monitoring: Logging is more consistent with the rest of the applications
  - Monitoring: It is now possible to disable TLS verification on HTTP jobs
  - System: Updated to the latest GEO country codes across the product
- What’s fixed?
  - API: It is now possible to change a Service Definition’s name without supplying its properties
  - API: The GET /zones/:zone/dnssec route now returns the correct data
  - API: Multiple fixes regarding the /dhcp/scopegroup endpoint
  - API: Reverted to previous default values for rate limits
  - API: IPAM search now properly filters based on the tag provided
  - DHCP: Fixed an issue where restarting the DHCP container may cause it to stop handing out leases
  - DDNS: Creating duplicate DDNS zones in a single scope group is now prevented
  - DNSSEC: Performing a KSK rollover now works as expected
  - Portal: It is now possible to untoggle DHCPv6 in a scope group
  - Portal: Fixed an issue when editing a remote server's KDC FQDN causes the remote DNS to reset to 127.0.0.1
  - Portal: Fixed an issue when creating a remote zone using the same FQDN but different scope groups causes duplicate entries
  - Portal: The DDNS reverse zone page now displays correctly for /16 or larger scopes
- Known issues
  - Monitoring: API validation prevents creation of jobs to monitor private IP addresses (RFC 1918, RFC 4193, etc.)
  - Monitoring: monitoring_edge containers cannot deploy downstream of distribution (dist) containers; workaround is to configure monitoring_edge containers connecting directly to core containers
  - Portal: No objects appear if a user only has the View IPAM/DHCP permission without Manage IPAM/DHCP
  - Portal: Activity log incorrectly shows a successful login even if it was not successful when using 2 Factor Authentication

## 2.5.2 (June 4, 2020)
- Feature Enhancements
  - System: Reduced core container’s size on disk by 5.36%
  - Monitoring: HTTP monitoring jobs support specification of a Host to check Virtual Hosts and SAN certificates
  - Portal:  Principals with the same SPN are disambiguated by showing the Principal ID and Key type
  - Portal: Principals now show a friendly name for name and encryption type
  - Portal: Remote Servers from the DHCP Remote Servers tab can now be deleted
  - Portal: Various UI improvements
  - Portal: Multiple improvements to handling Service Principals in Keytab upload
  - DHCP: Custom DHCP option definition no longer require a description
  - DHCP: AD DNS allows for configuration of a qualifying suffix which appends to the hostname if the DHCP client provides no domain
- What’s fixed?
  - Portal: Fixed the Bootstrap UI creation of Service Groups and Service Definitions
- Known issues
  - System: The system will output a large volume of logs related to internal health checks
  - Portal: Scope groups cannot be created with DHCPv6 enabled in the portal; to bypass this issue, create scope groups via the API
  - Portal: Custom DHCP Option keys cannot contain uppercase characters; to work around the issue keys must be in all lowercase characters
  - Portal: The Remote Server modal window does not allow switching between Secure and Insecure modes
  - API: IPAM search endpoints currently return all address objects disregarding the query parameters for tags and non-existent network identifiers

## 2.5.1 (May 22, 2020)
- New Features
  - Monitoring: We are proud to provide you with a preview of our eDDI's Monitoring & Alerting feature. If you are familiar with Monitoring in our Managed DNS product, then you will feel at home. The eDDI Monitoring & Alerting feature includes the ability to create ICMP, TCP and HTTP service checks and feed monitor status back into eDDI, allowing for intelligent traffic management. Please refer to https://help.ns1.com/hc/en-us/categories/360001657654-Monitoring for instructions; a new monitoring-compose.yml and terraform resources are available in our GitHub repository.
  - AD DDNS: Connect remote servers, remote zones and Scope Groups to configure NS1 DHCP to send insecure- or GSS-TSIG secured DDNS updates to a Microsoft DNS server on behalf of a DHCP client
  - IAM: Tag-based permissions allow granular access control of IPAM and DHCP resources (API only)
- Feature Enhancements
  - DNS: Added validation and controls to prevent requests removing required configurations of filter chains
  - IAM: Team names now allow special characters < > and &
  - Portal: Usernames can now be up to 64 characters in length
  - System: Container disk space footprint reduced by as much as 33%
- What’s fixed?
  - Security: Recursive resolver has been patched to prevent CVE-2020-12662 and CVE-2020-12663 (NXNSAttack)
  - API: Character validation of usernames is now working as expected
  - API: Made response consistent with other DELETE methods for the v1/ipam/address/{id}/pool/{id} endpoint
  - API: Fixed issue with API pagination for a domain with multiple record types where records could be truncated from the next page’s list
  - API: Service definitions no longer require the properties field when created
  - DHCP: Fixed an issue where lease information did not appear under scopes in the portal
  - DHCP: Fixed an issue where DHCP options would sometimes fail to apply to leases
  - DHCP: Fixed an issue where an extra, blank scope could be generated when adding a subnet to a scope group
- Known issues
  - AD DDNS: GSS-TSIG updates fails when using principal with AES256-SHA1 encryption
  - DHCP: Updates are poorly formatted when sending to an AD DNS server where the DHCID record exists
  - System: Enabling strict communication between containers causes inter-container connectivity to fail
  - Portal: Creating a new Remote Connection after creating one will pre-populate the fields with the existing info.
  - Portal: Bootstrap UI does not create DHCP service group and definition

## 2.5.0 (May 8, 2020)
- New Features
  - API: Added bulk operations endpoints for IPAM and DHCP tagging at scale
  - DHCP: Support for Client Classes via API added
  - Portal: Remote DNS server and Service Principal Management for use with GSS-TSIG / AD DNS available in the Portal
- Feature Enhancements
  - API: IPAM/DHCP tag data model has changed to consolidate tags, inherited tags and key/value pairs into tags, extending tag inheritance to network, subnet, pool, scope group, scope and reservation
- What’s fixed?
  - API: Character validation of usernames is now working as expected
  - DNS: increased maximum NX TTL value from 10,800 to 86,400
  - System: Removed spurious log messages for disabled health checks
  - System: Database upgrade utility no longer outputs a spurious error when completing successfully
  - System: It is now possible to delete a Service Definition
- Known issues
  - DHCP: Updates are poorly formatted when sending to an AD DNS server where the DHCID record exists
  - DHCP: Both DHCID and A/PTR records must already exist in order for updates to proceed. As a result, current behavior is that AD DNS returns NXRRSET on update query (and update fails) when prereq is included but either DHCID or A/PTR records do not exist.
  - API: ipam/address/{id}/adjacent and ipam/address/{id}/adjacent?previous=true routes may not return valid addresses
  - API: Requesting a zone with a large amount of records and a high record limit will return a 500 internal server error

## 2.4.5 (May 29, 2020)
- What’s fixed?
  - Security: Recursive resolver has been patched to prevent CVE-2020-12662 and CVE-2020-12663 (NXNSAttack)

## 2.4.4 (May 11, 2020)
- Feature Enhancements
  - Updated our base image software to latest stable release

## 2.4.3 (Apr 24, 2020)
- New Features
  - Portal: IP Ranges for DHCP are now able to be managed via the Portal
- Feature Enhancements
  - System: Email addresses can now be used as usernames to log into the portal
  - Portal: There is now a warning displayed when assembling teams with mixed rights to the same sections (DNS, IPAM, DHCP, user management)
- What’s fixed?
  - System: Fixed an issue where the container management daemon would store a corrupt configuration
  - Portal: It is now possible to see typed characters in the metadata search window
  - Portal: Team names will now be correct in the Team IP Whitelist window
  - Portal: Fixed ‘drag and drop’ operations for Firefox
  - IPAM: It is now possible to create an IP Range that starts at .0
  - IPAM: Fixed an issue where searching for an ipv6 address would fail with a validation error
  - DNS: Fixed an issue where retrieving certain records from the API would return a 500 Internal Server Error
  - DNS: Fixed an issue where updating data feeds with metadata containing geo information would return a 400 Bad Request
  - DNS: The Up data feed now works as expected
  - DNS: The note metadata field on a record will no longer remove ‘\’ characters
- Known issues
  - DHCP: Under heavy load, DHCP pool may be removed and cause DHCP NACKs
  - DHCP: Updating a Scope Group from the API with ‘{}’ will not take effect
  - DHCP: Expired leases may not be properly removed from the dist container
  - Portal: Global search may tack on irrelevant search data
  - Portal: Synthesized PTR records do not display in the wildcard record view for that zone

## 2.4.2 (Apr 10, 2020)
- New Features
  - DNS: Additional ISO-3166-2 country subdivisions are available for geotarget country and geofence country filters; import premium versions of Maxmind’s GeoIP databases to take full advantage of additional geo-steering granularity; all subdivisions can be referenced in the new endpoint v1/metatypes/geo
- Feature Enhancements
  - Portal: Records now show the number of answers they have
  - IPAM: Search now works across all networks
- What’s fixed?
  - DNS: Creating a record with no answers will no longer cause the zones api and portal page to fail
  - DNS: Fixed an issue which prevented configuring DNS forwarding via supd UI and CLI
  - DNS: Fixed a regression where the number of zones in an organization were limited to five thousand
  - DNS: Fixed a regression where the number of records in an organization were limited to one million
  - Portal: Fixed numerous UI issues related to Record Level permissions
  - API: Spaces will now be stripped from the address range when creating an IP range
  - API: Fixed POST requests to /v1/account/apikeys/<apikey> resulting in 500: Internal Server Error responses
- Known issues
  - DHCP: Creating or modifying scope groups without DHCPv4 or DHCPv6 enabled yet passing in parameters for DNS synthesis will result in DHCPv4 being enabled and the .com   TLD chosen as the zone for synthesis; enable DHCPv4 or DHCPv6 to avoid this misconfiguration
  - DNS: Specific countries in the country list without subdivision data return 500: Internal server errors when configured on answers (e.g. Chad, Bermuda, etc.); upcoming fix will respond with 400 response codes instead in these cases

## 2.4.1 (Mar 27, 2020)
- New Features
  - Portal: Record-level permissions are now configurable in the Portal in Account Settings -> Users & Teams
- Feature Enhancements
  - DHCP: Planned subnets and hosts will not be added to DHCP pools
- What’s fixed?
  - IPAM: Fixed an issue that allowed a user to delete an IPAM network in a different organization
  - System: Database restore now works correctly on HA Data clusters
  - DNS: The system no longer allows you to incorrectly add a zone ending with a ‘.’
  - DDNS: DHCP will now respect the configured zone and prefix if the host provides a FQDN
  - Portal: Multiple style fixes for the search page
  - Portal: A host with a reservation will no longer present the option to set a reservation
  - Portal: A zone with a DHCP filter to a DHCP Scope group should not show entries outside it's domain
- Known issues
  - Portal: A service definition can not be removed from a scope group. Workaround: Use the api
  - DNS: Records with no answers will cause the zones api (and as a result, the Portal zones page) to fail
  - System: Service definitions can not be deleted

## 2.4.0 (Mar 13, 2020)
- New Features
  - DHCP: IP Ranges can now be defined in IPAM as a logical range of addresses within a subnet and can be added to a scope (API only)
  - DNS: Added record-level permissions including record-type and subdomains in a given zone (API only)
  - Portal: Added search page for viewing and filtering search results returned for DNS or IPAM objects
  - Portal: Added “dark mode” which can be toggled via hotkey menu “?”
- Feature Enhancements
  - System: Database backups are now compressed
  - DDNS: Synthesized records now appear in the Portal under the wildcard record they belong to
- What’s fixed?
  - DNS: TLD now allows wildcard records
  - DHCP: Fixed a race condition that could cause the DHCP container to not receive its scopes properly
  - Portal: The window to edit DHCP options is now more spacious
  - IPAM: Improved performance when adding new IPAM objects
  - DNS: asn-routing filter now works properly
- Known issues
  - Portal: Portal hangs while creating a host reservation in the Portal without a zone in the system
  - DHCP: The portal and API do not require one to select a DHCP service when setting scope group options. This will cause unpredictable DHCP behavior. Workaround: Select at least one of DHCPv4 or DHCPv6
  - Portal: Synthesized records for different zones may appear in the wildcard record if the associated DHCP filter is configured with a scope group which updates another zone.

## 2.3.2 (Feb 28, 2020)
- New Features
   - Portal: CSP headers can now be configured for the Portal
- Feature Enhancements
   - System: Updated TLS default version to 1.2; added support TLSv1.3; updated allowed cipher list; set TLS to strict validation by default
DHCP: Improved workflow allowing forward (A/AAAA) and reverse (PTR) creation at time of DHCP reservation
- What’s fixed?
   - DDNS: Fixed an issue where the DHCP filter would fail if the host contained capital letters
   - DDNS: Fixed an issue where the v1/filtertypes endpoint did not show the DHCP filter
   - System: Fixed an issue that would cause system instability when performing Docker lifecycle events on the Core and Dist containers
   - System: Fixed an issue where the database backup action was unable to complete
   - Security: Fixed a potential XSS vulnerability in the zones API endpoint
   - Known issues
   - System: DHCP under load (>100 LPS) causes system-wide instability
   - Portal: AD Login - Domain Controller Port field is highlighted as invalid by default when a user specifies Domain Controller Host Address and AD Domain Name
   - DHCP: Provisioning new DHCP containers after scopes have been added to the system will not work.
   - DNS: TLD zone validation currently does not allow wildcard records; this will be addressed in future versions
   - DNS: API does not allow user to specify a pool for a zone
   - DHCP: DHCPv6 lease renewals delete their leases rather than renew them
   - DHCP: reverse zone created for DHCPv6 reservation is incorrect
   - DDNS: DDNS does not respect zone and prefix set when host sends an FQDN (no hostname sent or hostname is valid)

## 2.3.1 (Feb 14, 2020)
- New Features
   - DNS: Introduced the ability to create single label zones
- Feature Enhancements
   - DDNS: Ability to configure NS1 DNS to synthesize dynamic records from active NS1 DHCP leases in the portal
   - DNS: Support for TLD zones; TLDs allow for single-label name resolution
- What’s fixed?
   - Portal: resolved regression where the network count would always return 0.
   - IPAM: resolved an issue where the adjacent endpoint would return an incorrect next subnet
   - DHCP: Resolved leases in pools not configured for NS1 DDNS are no longer being misrepresented in the database
   - DHCP: replaced invalid option type “hex” with “binary”
   - DHCP: Fixed an issue where adding scopes too quickly would prevent replication through the dist container
   - System: Fixed a memory leak in the replication mechanism
   - System: Fixed an issue where services would not bind to IPv6
   - Security: Fixed a potential XSS vulnerability in the zones API endpoint
- Known issues
   - DDNS: DHCP filter fails when client-provided hostname contains capital letters
   - DHCP: Provisioning new DHCP containers after scopes have been added to the system will not work.
   - DDNS: DHCP filter is not in the list of filtertypes in the api v1/filtertypes endpoint, even though it is a valid filter type
   - DDNS: Selecting the DHCP filter to expand and read usage information results in a blank browser page; adding the DHCP filter to the list of filtertypes will resolve this behavior; workaround is to go back in the browser
   - DNS: TLD zone validation currently does not allow wildcard records; this will be addressed in future versions

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
