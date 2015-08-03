source "/vagrant/scripts/common.sh"

function installJava {
    #can be either jdk or jre
    rpm -q ${JRE_RPM:0:3} 
    if [ $? -eq 0 ]; then
        echo "Java is already installed"
    else
        echo "install ${JRE_RPM}"
        rpm -i /vagrant/resources/$JRE_RPM
    fi
}

function setupEnvVars {
    echo "creating java environment variables"
    echo export JAVA_HOME=/usr/java/default > /etc/profile.d/java.sh
    echo export PATH=\${JAVA_HOME}/bin:\${PATH} >> /etc/profile.d/java.sh
}

echo "Setting Up Java"
installJava
setupEnvVars
