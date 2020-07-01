require 'rbvmomi'

oneGB = 1 * 1000 * 1000 # in KB
dcName = 'vcaqDC'
clusterName = 'cluster0'

$testbed = Proc.new do
  {
    "name" => "testbed-test",
    "version" => 3,
    "network" => [
      {
        "name" => "net.0",
        "enableDhcp" => true,
        "enableStaticIpService" => true
      }
    ],
    "esx" => (0..0).map do | idx |
      {
        "name" => "esx.#{idx}",
        "nics" => 2, # 2 NICs
        "networks" => ["public", "nsx::net.0"],
        "vc" => "vc.0",
        "customBuild" => "ob-15843807",
        "dc" => dcName,
        "clusterName" => clusterName,
        "style" => "fullInstall",
        "cpus" => 32, # 32 vCPUs
        "memory" => 98000, # 98GB memory
        "fullClone" => true,
        "disks" => [ 10 * 1000 * oneGB ], # 10 TB Disk
      }
    end,

    "vcs" => [
      {
        "name" => "vc.0",
        "type" => "vcva",
        "customBuild" => "ob-15952498",
        "dcName" => [dcName],
        "enableDrs" => true,
        "clusters" => [
          {
            "name" => clusterName,
            "dc" => dcName
          }
        ]
      }
    ],

    "beforePostBoot" => Proc.new do |runId, testbedSpec, vmList, catApi, logDir|
    end,
    "postBoot" => Proc.new do |runId, testbedSpec, vmList, catApi, logDir|
      vc = vmList['vc'].first
      vim = RbVmomi::VIM.connect(
        host: vc.ip,
        user: vc.testbedInfo['vimUsername'],
        password: vc.testbedInfo['vimPassword'],
        insecure: true
      )
      root_folder = vim.serviceInstance.content.rootFolder
      dc = root_folder.childEntity.grep(RbVmomi::VIM::Datacenter).find { |x| x.name == dcName } || fail('datacenter not found')
      cr = dc.find_compute_resource(clusterName) || dc.hostFolder.children.find(clusterName).first
      abort "compute resource not found" unless cr

      VIM = RbVmomi::VIM

      case cr
      when VIM::ClusterComputeResource
        hosts = cr.host
      when VIM::ComputeResource
        hosts = [cr]
      else
        abort "invalid resource"
      end

      hosts.each do |host|
        hns = host.configManager.networkSystem

        pnics_in_use = []
        pnics_available = []

        # find available Physical Nic's
        hns.networkConfig.vswitch.each do |vs|
          pnics_in_use.concat vs.props[:spec].policy.nicTeaming.nicOrder.activeNic
          pnics_in_use.concat vs.props[:spec].policy.nicTeaming.nicOrder.standbyNic
        end

        hns.networkConfig.pnic.each do |pnic|
          pnics_available << pnic.device if !pnics_in_use.include?(pnic.device)
        end

        name = 'internal-network'
        policy = VIM::HostNetworkPolicy(nicTeaming: VIM::HostNicTeamingPolicy(nicOrder: VIM::HostNicOrderPolicy(activeNic: pnics_available)))
        portgroup = VIM::HostPortGroupSpec(name: name, vswitchName: name, vlanId: 0, policy: policy)
        hostbridge = VIM::HostVirtualSwitchBondBridge(:nicDevice => pnics_available)
        vswitchspec = VIM::HostVirtualSwitchSpec(:bridge => hostbridge, :mtu => 1500, :numPorts => 128)
        hns.AddVirtualSwitch(vswitchName: name, spec: vswitchspec)
        hns.AddPortGroup(portgrp: portgroup)
      end

    end
  }
end
