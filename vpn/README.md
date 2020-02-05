# BOSH Concourse VPN

Concourse teams are mapped one to one to particular GitHub teams. For example: The `google_cpi` team on Concourse has an equivalent GitHub team that will allow only members of that GitHub team to authenticate on Concourse.

The [BOSH Core](https://main.bosh-ci.cf-app.com/) Concourse instance is firewalled and can only be accessed via the BOSH Concourse VPN.

Authentication to the VPN is handled via SSOCA/GitHub through the same GitHub teams that are used to authenticate to Concourse.

## Requirements

### OpenVPN 2.4+

- macOS: `brew install openvpn`
- Ubuntu/Debian and RHEL/CentOS/Fedora: Follow the instructions [here](https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos)
- Windows: Download and install from this [page](https://openvpn.net/index.php/open-source/downloads.html)

On macOS, you might not see openvpn in `/usr/local/sbin` if that directory hasn't been created. To get openvpn linked correctly:
```
sudo mkdir /usr/local/sbin
sudo chown -R `whoami`:admin /usr/local/sbin
brew link openvpn
```

### ssoca

Download, verify, and install the `ssoca` client from [vpn-bosh.ci.cf-app.com](https://vpn-bosh.ci.cf-app.com).

Alternatively, with [Homebrew](https://brew.sh/) or [Linuxbrew](http://linuxbrew.sh/)...

 ```
 brew install dpb587/tap/ssoca
 ```

## Connecting to Concourse through the VPN

Follow these instructions to setup and connect. Once connected to the VPN, traffic to the [BOSH CPI](https://bosh-cpi.ci.cf-app.com) and [BOSH Core](https://main.bosh-ci.cf-app.com/) Concourse installations will be routed through the VPN.

### Linux/macOS

1. To configure `ssoca` for the first time:

    ```
    ssoca -e bosh env set https://vpn-bosh.ci.cf-app.com
    ```

2. Once configured, initiate the VPN connection:

    ```
    ssoca -e bosh openvpn exec --sudo
    ```

3. macOS-specific: If you want to use [Tunnelblick](https://tunnelblick.net/) to manage the connection...

    ```
    ssoca -e bosh openvpn create-tunnelblick-profile --install
    ```


### Windows

1. To configure `ssoca` for the first time, download [our CA Certificate](ssoca_ca_cert.pem); then:

    ```
    ssoca -e bosh env set https://vpn-bosh.ci.cf-app.com --ca-cert=ssoca_ca_cert.pem
    ```

2. Once configured, start PowerShell as Administrator and initiate the VPN connection:

    ```
    ssoca -e bosh openvpn exec
    ```
