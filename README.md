# OpenSOC Vagrant

A collection of shell scripts and a Vagrant file for building an OpenSOC cluster. There are two primary goals we hope to solve with this project:

* Create a turnkey OpenSOC cluster to allow users to play with OpenSOC with minimal setup
* Provide a disposable environment where developers can run and test OpenSOC topologies.

To accomplish this, we have provided a collection of bash scripts that are orchestrated using [Vagrant](https://www.vagrantup.com/) and [Fabric](http://www.fabfile.org/). Both of these tools should be installed prior to using this project. 

## Inspiration

Credit to https://github.com/vangj/vagrant-hadoop-2.4.1-spark-1.0.1 for the inspiration for this. This project is heavily influenced by that one.

## Quick Start

If you don't want to bother with the details of the cluster, and just want to see OpenSOC, do the following:

* Place a RPM For Oracle's JVM in `resources/`, edit `common.sh` to set `JRE_RPM` to the name of the RPM. 
* Get a set of snort rules from [here](https://www.snort.org/downloads), place them in `resources/data` and set `RULES_TARBALL` in `scripts/data/setup-snort.sh`
* Idenity a pcap file to process with OpenSOC

Then run:

```
vagrant up
fab vagrant quickstart /path/to/pcap/file.pcap
```

Finally, point your browser at https://localhost:8443

This should get you a running OpenSOC cluster with Bro, Snort, and PCAP. The PCAP you specify get copied to the data VM, and processed by Bro, Sourcefire, and [Pycapa](https://github.com/OpenSOC/pycapa) If you are looking to customize the setup or run your own topologies, see the secions below on running the cluster and running an OpenSOC Topology.

## Advanced Setup

If you are interested in tweaking the underlying cluster, running your own OpenSOC topology, or just want to understand how it all works, this section will break down how the cluster is started, and now topoogies can be run.

## Running the cluster

To get the cluster up and running, do the following:

* Place an RPM for Oracle's JVM in `resources/` and edit `common.sh` to set `JRE_RPM` to the name of the RPM
* Run `vagrant up`
* Run `fab vagrant postsetup`

The `vagrant up` command will build the VMs for the cluster, and install all dependencies which include:

* Hadoop 2.6
* Hbase 0.98
* Kafka 0.8.1.1
* Zookeeper 3.4.6
* Hive 1.2.0
* Elasticsearch 1.5.2
* Storm 0.9.4

After this, the `fab vagrant postsetup` command will run a handful of tasks that need to occur after the cluster is running, but before it can be used. These are:

* Formatting HDFS
* Starting Hadoop cluster
* Starting HBase cluster
* Setup Hbase whitelist table with RFC1918 addresses

## Running an OpenSOC Topology

After provisioning the cluster as described above, you can use some more fabric tasks to run a topology. Before you start, you should have the following:

* opensoc-streaming repo cloned locally
* a copy of OpenSOC configs in resources/opensoc/OpenSOC_Configs

Then you can run `fab vagrant start_topology:<topology_name>` which will do the following:

* cd into the opensoc-streaming repo, and run `mvn clean package`
* copy the newly built OpenSOC-Topologies.jar to resources/opensoc, where it will be avilable to the VMs
* Submit `<topology_name>` and the topology jar to Nimbus

If your topology is pulling data from Kafka, you can create a topic with the fabric task `fab vagrant create_topic:<topic>`

## Virtual Machines

By default, 4 VMs will be created. They are named node1, node2, node3, and node4. Here is a breakdown of what services run where:

* node1
  * HDFS Namenode
  * Yarn Resourcemanager
  * Storm Nimbus and UI
  * HBase Master
  * Elasticsearch Master
  * MySql (Hive metastore and geo enrichment store)

* node2-4
  * Kafka Broker
  * Zookeeper
  * HDFS Datanode
  * YARN Nodemanager
  * Storm Supervisor
  * HBase Regionserver
  * Elasticsearch Data Nodes

* data
  * Flume
  * Snort
  * Bro
  * Pycapa
  
## Port Forwarding

Some service's UIs are forwarded to localhost for ease of use. You can find the following services forwarded by default:

* HDFS - localhost:50070 -> node1:50070
* Hbase - localhost:60010 -> node1:60010
* Storm UI - localhost:8080 -> node1:8080
* Elasticsearch - localhost:9200 -> node1:9200
* OpenSOC-UI - localhost:8443 -> node1:443

## Progress

Here is a list of what will be provisioned via vagrant and its current status:

* Java - DONE
* Zookeeper - DONE
* HDFS/Yarn - DONE
* Kafka - DONE 
* Storm - DONE
* Hbase - DONE
* Hive - DONE
* Elasticsearch - DONE
* GeoIP Enrichment Data - DONE
* OpenSOC UI
* OpenSOC Storm Topologies

