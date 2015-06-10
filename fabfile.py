#!/usr/bin/python
from fabric.api import env, local, run, sudo, execute, hosts
from fabric.context_managers import shell_env

# configure fabric to talk to the VMs
temp_ssh_config = '.ssh_config'

def vagrant():
    '''sets up fabric environment to work with vagrant VMs'''
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


def postsetup():
    '''Perform post vagrant up tasks on cluster'''
    execute(format_namenode)
    execute(supervisorctl_start, 'namenode', host='node1')
    execute(supervisorctl_start, 'resourcemanager', host='node1')
    execute(supervisorctl_start, 'master', host='node1')
    for x in range(2,total_nodes+1):
        execute(supervisorctl_start, 'datanode', host='node{0}'.format(x))
        execute(supervisorctl_start, 'nodemanager', host='node{0}'.format(x))
        execute(supervisorctl_start, 'regionserver', host='node{0}'.format(x))

def supervisorctl_reread_update():
    sudo('supervisorctl reread')
    sudo('supervisorctl update')

def update_supervisor():
    execute(supervisorctl_reread_update, hosts=['node{0}'.format(x) for x in range(1,total_nodes+1)])