FROM registry.access.redhat.com/ubi8/ubi

LABEL authors="Arthur Laimbock <arthur.laimbock@nl.ibm.com>, \
            Markus Wiegleb <wieglebm@de.ibm.com>, \
            Frank Ketelaars <fketelaars@nl.ibm.com>, \ 
            Jiri Petnik <jiri_petnik@cz.ibm.com>"

# Install required packages, including HashiCorp Vault client
RUN yum install -y yum-utils python38 python38-pip && \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    yum install -y tar unzip wget jq skopeo httpd-tools git && \
    pip3 install --upgrade pip && \
    pip3 install jmespath pyyaml argparse python-benedict pyvmomi ansible && \
    alternatives --set python /usr/bin/python3 && \
    yum install -y vault && \
    yum clean all

RUN ansible-galaxy collection install community.general community.crypto ansible.utils community.vmware

VOLUME ["/Data"]

# Prepare directory that runs automation scripts
RUN mkdir -p /cloud-pak-deployer && \
    mkdir -p /Data

COPY . /cloud-pak-deployer/

RUN chmod -R 755 /cloud-pak-deployer/docker-scripts && \
    chmod -R 755 /cloud-pak-deployer/*.sh

ENTRYPOINT ["/cloud-pak-deployer/docker-scripts/container-bash.sh"]
