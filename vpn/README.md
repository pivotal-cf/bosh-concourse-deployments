# BOSH Concourse VPN

Concourse teams are mapped one to one to particular GitHub teams. For example: The `google_cpi` team on Concourse has an equivalent GitHub team that will allow only members of that GitHub team to authenticate on Concourse.

The [BOSH CPI](https://bosh-cpi.ci.cf-app.com) and [BOSH Core](https://main.bosh-ci.cf-app.com/) Concourse instances are firewalled and can only be accessed via the BOSH Concourse VPN.

Authentication to the VPN is handled via SSOCA/GitHub through the same GitHub teams that are used to authenticate to Concourse.

## Requirements

### OpenVPN 2.4+

- OS X: `brew install openvpn`
- Ubuntu/Debian and RHEL/CentOS/Fedora: Follow the instructions [here](https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos)
- Windows: Download and install from this [page](https://openvpn.net/index.php/open-source/downloads.html)

### ssoca

Binaries and checksums available from https://vpn-bosh-cpi.ci.cf-app.com


## Connecting to Concourse through the VPN

Follow the platform-specific instructions to setup and connect. Once connected to the VPN, traffic to the [BOSH CPI](https://bosh-cpi.ci.cf-app.com) and [BOSH Core](https://main.bosh-ci.cf-app.com/) Concourse deployments will be routed through the VPN.

### Linux/Mac

1. To configure `ssoca` for the first time:
    
    ```
    ssoca -e bosh-cpi env add https://vpn-bosh-cpi.ci.cf-app.com
    ```

2. Once configured, initiate the VPN connection:
    
    ```
    ssoca -e bosh-cpi openvpn connect --sudo
    ```

**Tip**: if you use [Tunnelblick](https://tunnelblick.net/) you may want to create a profile to allow you to connect/disconnect from Tunnelblick UI instead of through the terminal ([details](https://dpb587.github.io/ssoca/service/openvpn/create-tunnelblick-profile-cmd#usage-details)).


### Windows

1. To configure `ssoca` for the first time, download [our CA Certificate](ssoca_ca_cert.pem) and:
    
    ```
    ssoca -e bosh-cpi env add https://vpn-bosh-cpi.ci.cf-app.com --ca-cert=ssoca_ca_cert.pem
    ```
    
2. Once configured, start PowerShell as Administrator and initiate the VPN connection:

    ```
    ssoca -e bosh-cpi openvpn connect
    ```
