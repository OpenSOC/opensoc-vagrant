# OpenSOC Vagrant

A collection of shell scripts and a Vagrant file for building an OpenSOC cluster. There are two primary goals we hope to solve with this project:

* Create a turnkey OpenSOC cluster to allow users to play with OpenSOC with minimal setup
* Provide a disposable environment where developers can run and test OpenSOC topologies.

To accomplish this, we have provided a collection of bash scripts that are orchestrated using [Vagrant](https://www.vagrantup.com/) and [Fabric](http://www.fabfile.org/). Both of these tools should be installed prior to using this project. 

## Inspiration

Credit to https://github.com/vangj/vagrant-hadoop-2.4.1-spark-1.0.1 for the inspiration for this. This project is heavily influenced by that one.

## Quick Start

 - Run `vagrant up`
 - Run `fab vagrant postsetup`

* Endpoints for different services. 
 - HDFS - localhost:50070
 - Hbase - localhost:60010
 - Storm UI - localhost:8080      (currently disabled)
 - Elasticsearch - localhost:9200 (currently disabled)

## Virtual Machines

By default, 4 VMs will be created. They are named node1, node2, node3, and node4. Here is a breakdown of what services run where:

* node1
  * HDFS Namenode
  * Yarn Resourcemanager
  * Storm Nimbus and UI (disabled)
  * HBase Master
  * Elasticsearch Master (disabled)
  * MySql (Hive metastore and geo enrichment store) (disabled)

* node2-4
  * Kafka Broker (disabled)
  * Zookeeper
  * HDFS Datanode
  * YARN Nodemanager
  * Storm Supervisor (disabled)
  * HBase Regionserver 
  * Elasticsearch Data Nodes (disabled)

## Port Forwarding

Some service's UIs are forwarded to localhost for ease of use. You can find the following services forwarded by default:

* HDFS - localhost:50070 -> node1:50070
* Hbase - localhost:60010 -> node1:60010

* Storm UI - localhost:8080 -> node1:8080 (disabled)
* Elasticsearch - localhost:9200 -> node1:9200 (disabled)
* OpenSOC-UI - localhost:8443 -> node1:443 (disabled)

## Progress

Here is a list of what will be provisioned via vagrant and its current status:

* Java - DONE
* Zookeeper - DONE
* HDFS/Yarn - DONE
* Hbase - DONE

* Kafka - DONE (disabled)
* Storm - DONE (disabled)
* Hive - DONE (disabled)
* Elasticsearch - DONE (disabled)
* GeoIP Enrichment Data - DONE (disabled)
* OpenSOC UI (disabled)
* OpenSOC Storm Topologies (disabled)

* Componets versions: 
 - JRE_RPM=jre-8u112-linux-x64.rpm
 - HADOOP_VERSION=hadoop-2.6.0
 - ZOOKEEPER_VERSION=zookeeper-3.4.6
 - KAFKA_SCALA_VERSION=2.9.2
 - KAFKA_VERSION_NUM=0.8.1.1
 - KAFKA_VERSION="kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION_NUM}"
 - STORM_VERSION=apache-storm-0.9.4
 - HBASE_VERSION_NUM=0.98.23
 - HBASE_VERSION=hbase-"${HBASE_VERSION_NUM}-hadoop2"
 - HIVE_VERSION=hive-1.2.1
 - ES_VERSION=1.5.2
