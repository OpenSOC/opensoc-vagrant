Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    numNodes = 4
    r = numNodes..1
    (r.first).downto(r.last).each do |i|
        config.vm.define "node#{i}" do |node|
            node.vm.box = "chef/centos-6.5"
            node.vm.provider "virtualbox" do |v|
              v.name = "node#{i}"
              v.customize ["modifyvm", :id, "--memory", "1024"]
            end
            node.vm.network :private_network, ip: "10.0.0.10#{i}"

            # base setup
            node.vm.hostname = "node#{i}"
            
            node.vm.provision "shell" do |s|
                s.path = "scripts/setup-os.sh"
                s.args = "-t #{numNodes}"
            end

            node.vm.provision "shell", path: "scripts/setup-java.sh"

            if i == 1
                # namenode
                node.vm.provision "shell" do |s|
                    s.path = "scripts/setup-hadoop.sh"
                    s.args = "-r namenode -t #{numNodes}"
                end
                node.vm.network "forwarded_port", guest: 50070, host: 50070
                node.vm.network "forwarded_port", guest: 8088, host:8088

                # storm nimbus
                node.vm.provision "shell" do |s|
                    s.path = "scripts/setup-storm.sh"
                    s.args = "-r nimbus -t #{numNodes}"
                end
                node.vm.network "forwarded_port", guest: 8080, host: 8080

                # hbase master
                node.vm.provision "shell" do |s|
                    s.path = "scripts/setup-hbase.sh"
                    s.args = "-r master -t #{numNodes}"
                end
                node.vm.network "forwarded_port", guest: 60010, host: 60010
            else
                # zookeeper
                node.vm.provision "shell" do |s|
                    s.path = "scripts/setup-zookeeper.sh"
                    s.args = "-t #{numNodes}"
                end
                # datanode
                node.vm.provision "shell" do |s|
                    s.path = "scripts/setup-hadoop.sh"
                    s.args = "-r datanode -t #{numNodes}"
                end
                # hbase regionserver
                node.vm.provision "shell" do |s|
                    s.path = "scripts/setup-hbase.sh"
                    s.args = "-r regionserver -t #{numNodes}"
                end
                # kafka broker
                node.vm.provision "shell" do |s|
                    s.path = "scripts/setup-kafka.sh"
                    s.args = "-t #{numNodes}"
                end
                # storm supervisor
                node.vm.provision "shell" do |s|
                    s.path = "scripts/setup-storm.sh"
                    s.args = "-r supervisor -t #{numNodes}"
                end
                # elasticsearch
                # reload supervisord
            end

            #After everything is provisioned, start Supervisor
            node.vm.provision "shell", inline: "pgrep supervisord || start supervisor"
        end
    end
end
