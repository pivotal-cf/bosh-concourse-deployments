# Runway hosted Concourse within VMware
On-boarding docs can be found [here](https://confluence.eng.vmware.com/display/RUNWAY/1.+On-Boarding).

To add new users to the `bosh-core` namespace:
- add their username to `access.json`
- run `./update-namespace.sh`

To login to the runway concourse instance run:
```
fly -t runway@bosh-core login -c https://runway-ci.eng.vmware.com -n bosh-core
```
