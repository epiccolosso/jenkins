FROM alpine
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# env variables for the console or child containers to override
ENV JAVA_VM_PARAMETERS=-Xmx512m \
 JENKINS_MASTER_EXECUTORS= \
 JENKINS_SLAVEPORT=50000 \
 JENKINS_ADMIN_USER= \
 JENKINS_ADMIN_PASSWORD= \
 JENKINS_PLUGINS=swarm \
 JENKINS_PARAMETERS= \
 JENKINS_KEYSTORE_PASSWORD= \
 JENKINS_CERTIFICATE_DNAME= \
 JENKINS_ENV_FILE= \
 JENKINS_HOME=/jenkins \
 JENKINS_DELAYED_START= \
 JENKINS_VERSION=1.642.1 \
 JENKINS_RELEASE=war-stable

RUN export CONTAINER_USER=jenkins && \
    export CONTAINER_UID=1000 && \
    export CONTAINER_GROUP=jenkins && \
    export CONTAINER_GID=1000 && \
    # Add user
    addgroup -g $CONTAINER_GID jenkins && \
    adduser -u $CONTAINER_UID -G jenkins -h /home/jenkins -s /bin/bash -S jenkins && \
    # Install software
    apk add --update \
    git \
    unzip \
    wget \
    zip \
    bash \
    openjdk7-jre && \
    rm -rf /var/cache/apk/* && \
    # Install jenkins
    mkdir -p /usr/bin/jenkins && \
    wget --directory-prefix=/usr/bin/jenkins \
         http://mirrors.jenkins-ci.org/${JENKINS_RELEASE}/${JENKINS_VERSION}/jenkins.war && \
    chown -R $CONTAINER_USER:$CONTAINER_GROUP /usr/bin/jenkins && \
    chmod ug+x /usr/bin/jenkins/jenkins.war && \
    # Jenkins directory
    mkdir -p ${JENKINS_HOME} && \
    chown -R $CONTAINER_USER:$CONTAINER_GROUP ${JENKINS_HOME}

WORKDIR /jenkins
VOLUME ["/jenkins"]
EXPOSE 8080 50000

USER jenkins
COPY imagescripts/docker-entrypoint.sh /home/jenkins/docker-entrypoint.sh
ENTRYPOINT ["/home/jenkins/docker-entrypoint.sh"]
CMD ["jenkins"]
