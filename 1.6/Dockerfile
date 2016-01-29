FROM centos:centos7

# JA Bride
# sudo docker build --rm=true -t rhtgptetraining/jenkins-ose-dev .
# sudo docker run -i -t rhtgptetraining/jenkins-ose-dev
# sudo docker tag -f rhtgptetraining/jenkins-ose-dev docker.io/rhtgptetraining/jenkins-ose-dev
# sudo docker push docker.io/rhtgptetraining/jenkins-ose-dev

# Jenkins image for OpenShift
#
# This image provides a Jenkins server, primarily intended for integration with
# OpenShift v3.
#
# Volumes: 
# * /var/jenkins_home
# Environment:
# * $JENKINS_PASSWORD - Password for the Jenkins 'admin' user.

MAINTAINER Ben Parees <bparees@redhat.com>

ENV JENKINS_VERSION=1.6 \
    HOME=/var/lib/jenkins \
    JENKINS_HOME=/var/lib/jenkins

LABEL k8s.io.description="Jenkins is a continuous integration server" \
      k8s.io.display-name="Jenkins 1.6" \
      openshift.io.expose-services="8080:http" \
      openshift.io.tags="jenkins,jenkins16,ci"

# 8080 for main web interface, 50000 for slave agents
EXPOSE 8080 50000


RUN mkdir -p /opt/openshift/configuration/plugins

RUN curl http://pkg.jenkins-ci.org/redhat/jenkins.repo -o /etc/yum.repos.d/jenkins.repo && \
    rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key && \
    yum install -y tar zip unzip java-1.8.0-openjdk-devel jenkins-1.609 git && \
    yum clean all  && \
    chmod og+rw /var/lib/jenkins

# JA Bride:  adding needed git plugin
RUN curl -L -o /opt/openshift/configuration/plugins/git.hpi http://updates.jenkins-ci.org/latest/git.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/git-client.hpi http://updates.jenkins-ci.org/latest/git-client.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/scm-api.hpi http://updates.jenkins-ci.org/latest/scm-api.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/ssh-credentials.hpi http://updates.jenkins-ci.org/latest/ssh-credentials.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/credentials.hpi http://updates.jenkins-ci.org/latest/credentials.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/mailer.hpi http://updates.jenkins-ci.org/latest/mailer.hpi

# JA Bride:  adding delivery-pipeline plugin
RUN curl -L -o /opt/openshift/configuration/plugins/delivery-pipeline-plugin.hpi       https://updates.jenkins-ci.org/download/plugins/delivery-pipeline-plugin/0.9.7/delivery-pipeline-plugin.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/build-pipeline-plugin.hpi          http://updates.jenkins-ci.org/download/plugins/build-pipeline-plugin/1.4.4/build-pipeline-plugin.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/parameterized-trigger.hpi          http://updates.jenkins-ci.org/download/plugins/promoted-builds/2.17/promoted-builds.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/parameterized-trigger.hpi          http://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.25/parameterized-trigger.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/jquery.hpi                         http://updates.jenkins-ci.org/download/plugins/jquery/1.7.2-1/jquery.hpi
RUN curl -L -o /opt/openshift/configuration/plugins/token-macro.hpi                    https://updates.jenkins-ci.org/download/plugins/token-macro/1.9/token-macro.hpi

# JA Bride: adding sonar
RUN curl -L -o /opt/openshift/configuration/plugins/sonar.hpi                          http://updates.jenkins-ci.org/download/plugins/sonar/2.1/sonar.hpi

# JA Bride:  upgrading maven, otherwise stock maven from rhel-7-server-optional-rpms channel is used which currently is v3.0.5
# This version of Maven causes lots of problems
ENV MAVEN_VERSION=3.3.3
RUN curl -L -o /tmp/apache-maven.tar.gz http://ftp.wayne.edu/apache/maven/maven-3/3.3.3/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar -zxvf /tmp/apache-maven.tar.gz -C /opt && \
    rm -f /tmp/apache-maven.tar.gz
ENV PATH=/opt/apache-maven-$MAVEN_VERSION/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/sbin:/usr/sbin

# JA Bride:  installing nodejs and npm to support CI of javascript apps
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm && \
    yum install -y nodejs npm && \
    yum clean all

COPY oc /usr/local/bin/oc
COPY run.sh /usr/local/bin/run.sh
COPY ./contrib/ /opt/openshift
RUN  chmod -R og+rw /opt/openshift

VOLUME ["/var/lib/jenkins"]

# JA Bride
# Modifying to jenkins because otherwise end up wth the following error when attempting to execute git:
#   fatal: unable to look up current user in the passwd file: no such user
# Need to also modify cluster security:  oc edit scc restricted
# Change runAsUser -> type: RunAsAny
#USER 1001
RUN chown -R jenkins:jenkins /var/lib/jenkins/
USER jenkins

ENTRYPOINT ["/usr/local/bin/run.sh"]
