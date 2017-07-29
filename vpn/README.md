# BOSH CPI VPN

Concourse teams are mapped one to one to particular GitHub teams. For example: The `google_cpi` team on Concourse has an equivalent GitHub team that will allow only members of that GitHub team to authenticate on Concourse.

The main Concourse instance at https://bosh-cpi.ci.cf-app.com is firewalled and can only be accessed via the BOSH CPI VPN.

Authentication to the VPN is handled via SSOCA/GitHub through the same GitHub teams that are used to authenticate to Concourse.

## Requirements

- OpenVPN client

## Connecting to Concourse through the VPN

1. Navigate to https://vpn-bosh-cpi.ci.cf-app.com/ and follow the instructions on the page in order to authenticate to ssoca.

2. To initiate a connection to OpenVPN using the ssoca token do:=
```bash
ssoca openvpn connect --sudo
```

3. Once connected to the VPN all traffic to bosh-cpi.ci.cf-app.com will be routed to the secure VPN gateway.
