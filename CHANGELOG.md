## 1.0.3 (Aug 24, 2018)
- What's Fixed?
   - Config options for forwards now distinguishes between forwards to recursive resolvers and forwards to authoritative servers
   - Fixed action: "Restart In-Memory Database"
   - Fixed inability to delete forwards
   - Fixed inability to configure forwards via CLI

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
