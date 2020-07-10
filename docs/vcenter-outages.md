# Recovering from a Vcenter outage
The concourse upgrader for Bosh is at https://bosh-upgrader.ci.cf-app.com/ 

The actual VM for the upgrader is created in vcenter wild (https://vcenter.wild.cf-app.com/) creds in lastpass.
In the event of a vcenter outage (ie from a scheduled power-down event),
the VM running the upgrader will be powered down and someone will need to manually restart it in vcenter.

The VM you need to restart is under the "[BOSH-CPI-CONCOURSE-UPGRADER-VMs](https://vcenter.wild.cf-app.com/ui/#?extensionId=vsphere.core.folder.vm.relatedVMsTab&objectId=urn:vmomi:Folder:group-v463711:D431B8F6-82A5-4ACE-B4BD-25B2C0D477DF&navigator=vsphere.core.viTree.vmsAndTemplatesView)" VMs category

At the moment, the upgrader VM is vm-985561c7-5c63-4513-b2a4-133a7a80bf04, who knows if this updates. If you accidentally pick the wrong VM and it is managed by bosh, vcenter will give you a helpful warning that the VM is managed by the vsphere cpi, you probably shoulnd't be directly starting that VM.

Once the upgrader is running, you can go to https://bosh-upgrader.ci.cf-app.com/ and run update-vsphere-v6.5-worker (from both the core pipeline and the cpi pipeline). It should also help to prune the old worker references with fly.

Alternatively, you can open the ssh tunnel and `bosh cck`, this should also work.
