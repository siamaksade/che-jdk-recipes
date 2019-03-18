# Copyright (c) 2012-2018 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors: Madou Coulibaly mcouliba@redhat.com

FROM centos
EXPOSE 4403 8080 8000 22

ARG OC_VERSION=3.11.43
ARG ODO_VERSION=v0.0.20
ARG KUBECTL_VERSION=v1.13.3
ARG SQUASHCTL_VERSION=v0.4.4
ARG MAVEN_VERSION=3.6.0
ARG GRAALVM_VERSION=1.0.0-rc13

# Install JDK/MAVEN
RUN yum update -y && \
    yum -y install sudo openssh-server procps wget unzip tar mc git curl subversion nmap java-1.8.0-openjdk-devel && \
    mkdir /var/run/sshd && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user && \
    sed -i 's/requiretty/!requiretty/g' /etc/sudoers

USER user

LABEL che:server:8080:ref=tomcat8 che:server:8080:protocol=http che:server:8000:ref=tomcat8-debug che:server:8000:protocol=http

ENV M2_HOME=/home/user/apache-maven-$MAVEN_VERSION \
    JAVA_HOME=/etc/alternatives/jre \
    TOMCAT_HOME=/home/user/tomcat8

ENV PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
ENV MAVEN_OPTS=$JAVA_OPTS

RUN mkdir /home/user/tomcat8 && mkdir /home/user/apache-maven-$MAVEN_VERSION && \
  wget -qO- "http://apache.ip-connect.vn.ua/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" | tar -zx --strip-components=1 -C /home/user/apache-maven-$MAVEN_VERSION/
ENV TERM xterm

RUN wget -qO- "http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.tar.gz" | tar -zx --strip-components=1 -C /home/user/tomcat8 && \
    rm -rf /home/user/tomcat8/webapps/*
ENV LANG C.UTF-8
RUN svn --version && \
    sed -i 's/# store-passwords = no/store-passwords = yes/g' /home/user/.subversion/servers && \
    sed -i 's/# store-plaintext-passwords = no/store-plaintext-passwords = yes/g' /home/user/.subversion/servers
WORKDIR /projects

# Install EPEL
RUN sudo yum update -y && \
    sudo yum install -y epel-release

# Install nss_wrapper and tools
RUN sudo yum install -y cmake3 gettext make gcc && \
    cd /home/user/ && \
    git clone git://git.samba.org/nss_wrapper.git && \
    cd nss_wrapper && \
    mkdir obj && cd obj && \
    cmake3 -DCMAKE_INSTALL_PREFIX=/usr/local -DLIB_SUFFIX=64 .. && \
    make && sudo make install && \
    cd /home/user && rm -rf ./nss_wrapper && \
    sudo yum remove -y cmake3 make gcc && \
    sudo yum clean all && \
    sudo rm -rf /tmp/* /var/cache/yum

# Install jq
RUN sudo yum install -y jq

# Install tools
RUN sudo yum update -y && \
    sudo yum install -y bzip2 tar curl wget

# Install oc
RUN sudo wget -qO- "https://mirror.openshift.com/pub/openshift-v3/clients/${OC_VERSION}/linux/oc.tar.gz" | sudo tar xvz -C /usr/local/bin && \
    oc version

# Install nodejs for ls agents
RUN curl -sL https://rpm.nodesource.com/setup_8.x | sudo -E bash - && \
    sudo yum install -y nodejs

# Install Ansible
RUN sudo yum install -y ansible

# Install Siege
RUN sudo yum install -y epel-release && \
    sudo yum install -y siege

# Install Openshift DO (ODO)
RUN sudo curl -L https://github.com/redhat-developer/odo/releases/download/${ODO_VERSION}/odo-linux-amd64 -o /usr/local/bin/odo && \
    sudo chmod +x /usr/local/bin/odo

# Install squashctl (kubectl)
RUN sudo wget -qO /usr/local/bin/squashctl https://github.com/solo-io/squash/releases/download/${SQUASHCTL_VERSION}/squashctl-linux && \
    sudo chmod +x /usr/local/bin/squashctl
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN sudo chmod +x /usr/local/bin/kubectl && \
    kubectl version --client

# Install GraalVM
ENV GRAALVM_HOME=/home/user/graalvm

RUN mkdir ${GRAALVM_HOME} && \
    sudo wget -qO- https://github.com/oracle/graal/releases/download/vm-${GRAALVM_VERSION}/graalvm-ce-${GRAALVM_VERSION}-linux-amd64.tar.gz | tar -zx --strip-components=1 -C ${GRAALVM_HOME}
ENV PATH=${GRAALVM_HOME}/bin:${PATH}

# Cleanup 
RUN sudo yum clean all && \
    sudo rm -rf /tmp/* /var/cache/yum
    
# The following lines are needed to set the correct locale after `yum update`
# c.f. https://github.com/CentOS/sig-cloud-instance-images/issues/71
RUN sudo localedef -i en_US -f UTF-8 C.UTF-8
ENV LANG="C.UTF-8"

# Maven settings
COPY ./settings.xml $HOME/.m2/settings.xml

# # Give write access to /home/user for 
# # users with an arbitrary UID 
# RUN sudo chgrp -R 0 /home/user \
#   && sudo chmod -R g+rwX /home/user \
#   && sudo chgrp -R 0 /etc/passwd \
#   && sudo chmod -R g+rwX /etc/passwd \
#   && sudo chgrp -R 0 /etc/group \
#   && sudo chmod -R g+rwX /etc/group \
#   && sudo mkdir -p /projects \
#   && sudo chgrp -R 0 /projects \
#   && sudo chmod -R g+rwX /projects
  
# # Generate passwd.template
# RUN cat /etc/passwd | \
#     sed s#user:x.*#user:x:\${USER_ID}:\${GROUP_ID}::\${HOME}:/bin/bash#g \
#     > /home/user/passwd.template

# # Generate group.template
# RUN cat /etc/group | \
#     sed s#root:x:0:#root:x:0:0,\${USER_ID}:#g \
#     > /home/user/group.template

RUN sed -i '/MAVEN_OPTS/d' /home/user/.bashrc && \
    echo "export MAVEN_OPTS=\"\$MAVEN_OPTS \$JAVA_OPTS\"" >> /home/user/.bashrc

# ENV HOME /home/user

# Overwride entrypoint
COPY ["entrypoint.sh","/home/user/entrypoint.sh"]

ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null
