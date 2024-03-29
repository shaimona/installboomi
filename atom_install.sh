#!/bin/bash
if [ -f /mnt/data/molecule/*/bin/atom ]; then
    echo "Atom already installed"
else
    # Set installation mutex
    touch /mnt/data/BOOMI_{{BoomiName}}_INPROGRESS
    date +%s > /mnt/data/BOOMI_{{BoomiName}}_STARTED_AT
    curl  http://169.254.169.254/latest/meta-data/local-ipv4 > /mnt/data/BOOMI_{{BoomiName}}_HEAD_NODE_IP
    # Download Dell Boomi installer
    lowercaseBoomiType="$(echo {{BoomiType}} | tr '[A-Z]' '[a-z]')"
    wget -O /tmp/{{BoomiType}}_install64.sh https://platform.boomi.com/atom/"$lowercaseBoomiType"_install64.sh
    chmod +x /tmp/{{BoomiType}}_install64.sh
    # Install Boomi (Cloud) Molecule
    /tmp/{{BoomiType}}_install64.sh -q -console -VlocalPath=/usr/local/boomi/work -VinstallToken={{BoomiInstallToken}} -VatomName={{BoomiName}} -dir /mnt/data/molecule
    sleep 10
    # Initial setup: UNICAST and JGroups config
    echo 'com.boomi.container.cloudlet.clusterConfig=UNICAST' >> /mnt/data/molecule/{{BoomiType}}_{{BoomiName}}/conf/container.properties
    echo "com.boomi.container.cloudlet.initialHosts=$(cat /mnt/data/molecule/BOOMI_{{BoomiName}}_HEAD_NODE_IP)[7800]" >> /mnt/data/molecule/{{BoomiType}}_{{BoomiName}}/conf/container.properties
    # Increase JVM heap space
    sed -i 's/-Xmx.*/-Xmx1024m/g' /mnt/data/molecule/{{BoomiType}}_{{BoomiName}}/bin/atom.vmoptions
    # Remove installation mutex
    rm /mnt/data/BOOMI_{{BoomiName}}_INPROGRESS
fi
