# OpenSOC Vagrant

A collection of shell scripts and a Vagrant file for building an OpenSOC cluster. The goal of this project is to create be able to create a disposable OpenSOC cluster using Vagrant for development and testing purposes.

## Inspiration

Credit to https://github.com/vangj/vagrant-hadoop-2.4.1-spark-1.0.1 for the inspiration for this. This project is heavily influenced by that one.

## Virtual Machines

By default, 4 VMs will be created. They are named node1, node2, node3, and node4. Here is a breakdown of what services run where:

* node1
  * HDFS Namenode
  * Yarn Resourcemanager

* node2-4
  * Kafka Broker
  * Zookeeper
  * HDFS Datanode
  * YARN Nodemanager

## Port Forwarding

Some service's UIs are forwarded to localhost for ease of use. You can find the following services forwarded by default:

* HDFS - localhost:50070 -> node1:50070

## Progress

Here is a list of what will be provisioned via vagrant and its current status:

* Java - DONE
* Zookeeper - DONE
* HDFS/Yarn - DONE
* Kafka - DONE 
* Storm 
* Hbase
* Hive
* Elasticsearch
* OpenSOC UI
* OpenSOC Storm Topologies

