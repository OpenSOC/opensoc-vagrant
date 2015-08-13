#!/usr/bin/python
import os
import xml.etree.ElementTree as ETree

from fabric.api import env, local, run, sudo, execute, hosts
from fabric.context_managers import shell_env, lcd, cd
from fabric.colors import yellow, green

# configure fabric to talk to the VMs
temp_ssh_config = '.ssh_config'

def vagrant():
    '''Sets up fabric environment to work with vagrant VMs'''
    with open(temp_ssh_config, 'w') as f:
        f.write(local('vagrant ssh-config', capture=True))

    global total_nodes
    total_nodes = int(local('vagrant status | grep node | wc -l', capture=True))

    env.user = 'vagrant'
    env.use_ssh_config = True
    env.ssh_config_path = temp_ssh_config

@hosts('node1')
def format_namenode():
    '''Formats namenode on node1'''
    with shell_env(JAVA_HOME='/usr/java/default'):
        sudo('/opt/hadoop/bin/hdfs namenode -format vagrant -nonInteractive', warn_only=True)


def supervisorctl_start(process):
    '''Start a process managed by supervisor'''
    sudo('supervisorctl start {0}'.format(process))

def supervisorctl_stop(process):
    '''Stop a process managed by supervisor'''
    sudo('supervisorctl stop {0}'.format(process))

def supervisorctl_startall():
    sudo('pgrep supervisord || start supervisor', warn_only=True)
    sudo('supervisorctl start all')

def startall():
    '''Ensure that all services are up and running'''
    for x in range(total_nodes,0,-1):
        execute(supervisorctl_startall, host='node{0}'.format(x))

def supervisorctl_stopall():
    sudo('supervisorctl stop all')

def restartall():
    '''Restart all services'''
    for x in range(total_nodes,0,-1):
        execute(supervisorctl_stopall, host='node{0}'.format(x))
    for x in range(total_nodes,0,-1):
        execute(supervisorctl_startall, host='node{0}'.format(x))


def postsetup():
    '''Perform post vagrant up tasks on cluster'''

    execute(format_namenode)
    execute(startall)

    execute(init_ip_whitelist,host='node1')

def supervisorctl_reread_update():
    sudo('supervisorctl reread')
    sudo('supervisorctl update')

def update_supervisor():
    execute(supervisorctl_reread_update, hosts=['node{0}'.format(x) for x in range(1,total_nodes+1)])

def supervisorctl_status():
    sudo('supervisorctl status')

def status():
    '''Check the status of all services'''
    execute(supervisorctl_status, hosts=['node{0}'.format(x) for x in range(1,total_nodes+1)])

@hosts('node1')
def init_ip_whitelist():
    run('/opt/hbase/bin/hbase shell /vagrant/resources/opensoc/hbase_ip_whitelist.rb')


@hosts('node2')
def create_topic(topic, partitions=1, replication_factor=1):
    run('/opt/kafka/bin/kafka-topics.sh --zookeeper localhost --create --topic {0} --partitions {1} --replication-factor {2}'.format(
        topic,
        partitions,
        replication_factor
        ))

def get_topologies(repo='../opensoc-streaming'):
    '''Build and fetch a new OpenSOC topology jar from repo (default: ../opensoc-streaming)'''

    pom_file = os.path.join(repo, 'pom.xml')
    pom = ETree.parse(pom_file)
    version = pom.getroot().find('{http://maven.apache.org/POM/4.0.0}version').text
    rev = local("git log | head -1 | cut -d ' ' -f 2 | cut -c1-11", capture=True)

    topology_jar = os.path.join(
        repo,
        'OpenSOC-Topologies',
        'target',
        'OpenSOC-Topologies-{0}.jar'.format(version)
        )

    vagrant_jar = 'OpenSOC-Topologies-{0}-{1}.jar'.format(version, rev)
    vagrant_jar_path = os.path.join('resources/opensoc', vagrant_jar)

    if os.path.exists(vagrant_jar_path):
        print yellow('{0} already exists. Not building a new jar.'.format(vagrant_jar_path))
        print yellow('Remove the existing jar and run this command again to build a fresh jar.')
        return vagrant_jar

    with lcd(repo):
        local('mvn clean package -Dmaven.test.skip=true')

    local('cp {0} {1}'.format(
        topology_jar,
        vagrant_jar_path
        ))

    return vagrant_jar

@hosts('node1')
def start_topology(topology, repo=None, local_mode=False, config_path='/vagrant/resources/opensoc/config/', generator_spout=False):
    '''Builds and copies a fresh topology jar from a locally cloned opensoc-streaming and submits it to storm'''

    if repo is not None:
        jar = get_topologies(repo)
    else:
        jar = get_topologies()

    if local_mode:
        local_mode='true'
    else:
        local_mode='false'

    if generator_spout:
        generator_spout='true'
    else:
        generator_spout='false'

    with cd('/vagrant/resources/opensoc/'):
        run('/opt/storm/bin/storm jar {0} {1} -local_mode {2} -config_path {3} -generator_spout {4}'.format(
            jar,
            topology,
            local_mode,
            config_path,
            generator_spout
            ))

def restart_storm():
    '''Restarts storm workers and nimbus'''

    execute(supervisorctl_stop, 'storm-nimbus', host='node1')
    execute(supervisorctl_stop, 'storm-supervisor', hosts=[ 'node{0}'.format(x) for x in range(2, total_nodes+1)])

    execute(supervisorctl_start, 'storm-nimbus', host='node1')
    execute(supervisorctl_start, 'storm-supervisor', hosts=[ 'node{0}'.format(x) for x in range(2, total_nodes+1)])

def quickstart():
    '''Start OpenSOC with bro, snort, and pcap'''
    # run post setup tasks
    postsetup()

    # clone opensoc-streaming if its not here locally
    if not os.path.exists('../opensoc-streaming'):
        with lcd('../'):
            local('git clone https://github.com/OpenSOC/opensoc-streaming.git')
    else:
        print green('Found a copy of opensoc-streaming in ../opensoc-streaming.')

    for top in ['bro', 'sourcefire', 'pcap']:

        topic = '{0}_raw'.format(top)
        # create kafka topic
        execute(create_topic, topic, host='node2')

        # launch topology
        topology = 'com.opensoc.topology.{0}'.format(top.capitalize())
        execute(start_topology, topology, config_path='config/')
