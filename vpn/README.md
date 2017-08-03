# BOSH CPI VPN

Concourse teams are mapped one to one to particular GitHub teams. For example: The `google_cpi` team on Concourse has an equivalent GitHub team that will allow only members of that GitHub team to authenticate on Concourse.

The main Concourse instance at https://bosh-cpi.ci.cf-app.com is firewalled and can only be accessed via the BOSH CPI VPN.

Authentication to the VPN is handled via SSOCA/GitHub through the same GitHub teams that are used to authenticate to Concourse.

## Requirements

- OpenVPN 2.4 client

## Installing OpenVPN 2.4

- OS X: brew install openvpn
- Ubuntu/Debian and RHEL/CentOS/Fedora: Follow the instructions [here](https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos)
- Windows: Download and install from this [page](https://openvpn.net/index.php/open-source/downloads.html)

## Connecting to Concourse through the VPN

1. Navigate to https://vpn-bosh-cpi.ci.cf-app.com and follow the instructions on the page in order to authenticate to ssoca.

2. If not Windows user jump to step 3.
    - On Windows open your prompt command as Administrator.
    - Download the [SSOCA CA Certificate](ssoca_ca_cert.pem)
    - Run SSOCA Windows Client with `--ca-cert` flag:
      ```bash
      ssoca env add https://vpn-bosh-cpi.ci.cf-app.com --ca-cert ssoca_ca_cert.pem
      ```

2. Initiate a connection using the ssoca client to the VPN:
    ```bash
    ssoca openvpn connect --sudo
    ```
    Note: Windows users don't need `--sudo` given they're running their prompt command as Administrator.

3. Once connected to the VPN all traffic to https://bosh-cpi.ci.cf-app.com will be routed through the secure VPN.
