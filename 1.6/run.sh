#!/bin/bash

OUTPUT=/tmp/run.log

function obfuscate_password {
    local password="$1"
    local acegi_security_path=`find /tmp/war/WEB-INF/lib/ -name acegi-security-*.jar`
    local commons_codec_path=`find /tmp/war/WEB-INF/lib/ -name commons-codec-*.jar`

    java -classpath "${acegi_security_path}:${commons_codec_path}:/opt/openshift/password-encoder.jar" com.redhat.openshift.PasswordEncoder $password
}


mkdir /tmp/war
unzip -q /usr/lib/jenkins/jenkins.war -d /tmp/war
new_password_hash=`obfuscate_password ${JENKINS_PASSWORD:-password}`

if [ ! -e /var/lib/jenkins/configured ]; then
  cp -r /opt/openshift/configuration/* /var/lib/jenkins
  cp -r /opt/openshift/configuration/.m2 /var/lib/jenkins
  rm -rf /opt/openshift/configuration/*
  rm -rf /opt/openshift/configuration/.m2
  
  sed -i "s,<passwordHash>.*</passwordHash>,<passwordHash>$new_password_hash</passwordHash>,g" "/var/lib/jenkins/users/admin/config.xml"
  echo $new_password_hash > /var/lib/jenkins/password
  touch /var/lib/jenkins/configured
fi

if [ -e /var/lib/jenkins/password ]; then
  # if the password environment variable has changed, update the jenkins config.
  # we don't want to just blindly do this on startup because the user might change their password via
  # the jenkins ui, so we only want to do this if the env variable has been explicitly modified from
  # the original value.
  old_password=`cat /var/lib/jenkins/password`
  if [ $old_password!=$new_password_hash ]; then
    sed -i "s,<passwordHash>.*</passwordHash>,<passwordHash>$new_password_hash</passwordHash>,g" "/var/lib/jenkins/users/admin/config.xml"
    echo $new_password_hash > /var/lib/jenkins/password
  fi
fi
rm -rf /tmp/war

# JA Bride:  explicitly use java 1.8
# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
   exec /usr/lib/jvm/java-1.8.0-openjdk/bin/java $JAVA_OPTS -Dfile.encoding=UTF8 -jar /usr/lib/jenkins/jenkins.war $JENKINS_OPTS "$@"
fi


# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"

