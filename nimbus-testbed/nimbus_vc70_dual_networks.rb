require 'rbvmomi'

oneGB = 1 * 1000 * 1000 # in KB
dcName = 'private'
clusterName = 'private'

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
        "clusters" => [
          {
            "name" => clusterName,
            "dc" => dcName,
            "enableDrs" => true
          }
        ]
      }
    ],

    "beforePostBoot" => Proc.new do |runId, testbedSpec, vmList, catApi, logDir|
    end,
    "postBoot" => Proc.new do |runId, testbedSpec, vmList, catApi, logDir|
    end
  }
end
