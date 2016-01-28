# Jenkins
#
#

FROM centos:latest
MAINTAINER Ruggero Marchei <ruggero.marchei@daemonzone.net>


ENV JDK8_VERSION 8u71-b15

RUN cd /tmp && \
  curl -sLO -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JDK8_VERSION}/jdk-${JDK8_VERSION%%-*}-linux-x64.rpm && \
  yum install -y /tmp/jdk-${JDK8_VERSION%%-*}-linux-x64.rpm && \
  rm -f /tmp/jdk-${JDK8_VERSION%%-*}-linux-x64.rpm && \
  curl -sLo /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo && \
  rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key && \
  yum install -y epel-release && \
  yum install -y unzip \
  gcc openssl-devel python-devel python-setuptools libffi-devel \
  cyrus-sasl-md5 ncftp \
  java-1.8.0-openjdk-headless ant ant-jsch jenkins \
  pyOpenSSL python2-crypto python-pip python-virtualenv \
  perl-DBD-mysql perl-JSON perl-XML-Twig \
  supervisor openssh openssh-server openssh-clients mariadb-libs mariadb \
  sudo which pwgen \
  git subversion && \
  yum clean all -q


ENV ROOT_PW root
ENV JENKINS_PW jenkins

# no PAM
# http://stackoverflow.com/questions/18173889/cannot-access-centos-sshd-on-docker
RUN sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config; \
  echo "sshd: ALL" >> /etc/hosts.allow; \
  rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
  ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && \
  ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
  echo "root:$ROOT_PW" | chpasswd; \
  echo "jenkins:$JENKINS_PW" | chpasswd; \
  gpasswd -a jenkins wheel; \
  sed -i -e 's/^\(%wheel\s\+.\+\)/#\1/gi' /etc/sudoers; \
  echo -e '\n%wheel ALL=(ALL) ALL' >> /etc/sudoers; \
  echo -e '\nDefaults:root   !requiretty' >> /etc/sudoers; \
  echo -e '\nDefaults:%wheel !requiretty' >> /etc/sudoers;


ENV MAVEN_VERSION 3.2.5

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven


EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
