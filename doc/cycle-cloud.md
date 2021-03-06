# AzureHPC and CycleCloud integration FAQ
With this intgration, AzureHPC can create CycleCloud clusters with a set a prefix values for the cluster parameters as well as adding cluster-init specs to reuse existing AzureHPC scripts like the one provided for the storage clients for example. The main principle with the integration is to leave untouch the CycleCloud cluster template and to leverage cluster-init to extend any existing specs defined in the template.

## how to retrieve the list of existing templates ?

If you are not using a customize template for which you know it's exact name, one way of retrieving the list of pre-set templates full names is to run the following command:
```
$ cyclecloud show_cluster -t
--------------------------------------
gridengine_template_1.0.0 : *template*
--------------------------------------
Resource group:
Cluster nodes:
    master: Off -- --
Total nodes: 1
------------------------------------
htcondor_template_1.0.1 : *template*
------------------------------------
Resource group:
Cluster nodes:
    master: Off -- --
Total nodes: 1
-------------------------------
lsf_template_3.2.2 : *template*
-------------------------------
Resource group:
Cluster nodes:
    proxy: Off -- --
Total nodes: 1
---------------------------------
pbspro_template_1.3.7 : *template*
----------------------------------
Resource group:
Cluster nodes:
    master: Off -- --
Total nodes: 1
---------------------------------
slurm_template_2.1.0 : *template*
---------------------------------
Resource group:
Cluster nodes:
    master: Off -- --
Total nodes: 1
```

## how to know which parameters can be used in the config file ?

Parameters are defined in templates, and if you haven't created the template yourself or don't have access to the template text file, you can export parameters of an existing cluster with this command :

```
$ cyclecloud export_parameters pbscycle
{
  "MaxExecuteCoreCount" : 1000,
  "MasterMachineType" : "Standard_D8s_v3",
  "UsePublicNetwork" : false,
  "ReturnProxy" : false,
  "Credentials" : "azure",
  "Autoscale" : true,
  "SubnetId" : "myrg/hpcvnet/compute",
  "UseLowPrio" : false,
  "Region" : "westeurope",
  "NumberLoginNodes" : 0,
  "MasterClusterInitSpecs" : null,
  "ExecuteMachineType" : "Standard_HB60rs",
  "pbspro" : null,
  "ImageName" : "OpenLogic:CentOS-HPC:7.7:latest",
  "ExecuteNodesPublic" : false,
  "ExecuteClusterInitSpecs" : null
}
```
If you haven't assigned any ClusterInit specs these values will be `null` as above. If a ClusterInit spec have been assigned then it' content would be :

```json
  "MasterClusterInitSpecs" : {
    "azurehpc:default:1.0.0" : {
      "Order" : 10000,
      "Spec" : "default",
      "Name" : "azurehpc:default:1.0.0",
      "Project" : "azurehpc",
      "Locker" : "azure-storage",
      "Version" : "1.0.0"
    }
  }
```

This full JSON content will have to be included in the AzureHPC configuration file.

## What is the CycleCloud project content generated by AzureHPC ?
The goal of the integration is to make an easy use of the scripts provided by AzureHPC. The project dictionary in the configuration file will list which scripts to call, with which arguments and any additional file dependencies. The `azhpc build` command will use the CycleCloud CLI to initialize a project and specs under the `azhpc_install_<configname>/projects` directory. All referenced files and dependencies are copied in the `<projectname>/specs/<specname>/cluster-init/files` and wrappers are generated in the `<projectname>/specs/<specname>/cluster-init/scripts`. Then the project is uploaded in the `azure-storage` CycleCloud locker.

## How to debug the cluster-init scripts ?
Connect on the machine which is supposed to run the cluster-init scripts. The execution output is stored under the `/opt/cycle/jetpack/logs/cluster-init/<projectname>`, in addition look at the `/opt/cycle/jetpack/logs/jetpack.log` and `/opt/cycle/jetpack/logs/chef-client.log`.

