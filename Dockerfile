# Jenkins
#
#

FROM centos:latest
MAINTAINER Ruggero Marchei <ruggero.marchei@daemonzone.net>


ENV JDK_VERSION 8u71-b15

RUN cd /tmp && \
  curl -sLO -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JDK_VERSION}/jdk-${JDK_VERSION%%-*}-linux-x64.rpm && \
  yum install -y /tmp/jdk-${JDK_VERSION%%-*}-linux-x64.rpm && \
  rm -f /tmp/jdk-${JDK_VERSION%%-*}-linux-x64.rpm && \
  yum install -y epel-release && \
  yum install -y unzip \
  gcc openssl-devel python-devel python-setuptools libffi-devel \
  cyrus-sasl-md5 ncftp \
  ant ant-jsch \
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
  useradd -g wheel jenkins; \
  echo "jenkins:$JENKINS_PW" | chpasswd; \
  sed -i -e 's/^\(%wheel\s\+.\+\)/#\1/gi' /etc/sudoers; \
  echo -e '\n%wheel ALL=(ALL) ALL' >> /etc/sudoers; \
  echo -e '\nDefaults:root   !requiretty' >> /etc/sudoers; \
  echo -e '\nDefaults:%wheel !requiretty' >> /etc/sudoers;


EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
