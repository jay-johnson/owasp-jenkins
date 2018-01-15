FROM jenkins/jenkins:latest

USER root

RUN apt-get update \
  && apt-get -y upgrade

RUN apt-get -y install \
  build-essential \
  software-properties-common \
  git vim \
  python \
  python-dev \
  python3 \
  python3-dev \
  python-setuptools \
  python-virtualenv \
  python-pip \
  net-tools \
  gcc \
  vim \
  openssl \
  libssl-dev \
  make \
  cmake \
  autoconf \
  mono-runtime \
  mono-devel \
  libcurl4-openssl-dev \
  libffi6 \
  libffi-dev \
  ruby \
  curl \
  php-cli \
  php-mbstring \
  unzip 

RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  # https://jeremylong.github.io/DependencyCheck/analyzers/bundle-audit.html
  && gem install bundler-audit \
  && bundle-audit update
 
# Install ansible in the system's pips for jenkins
# and in the virtual env for python3
RUN mkdir -p -m 777 /opt/owasp \
  && pip install --upgrade pip \
  && pip install --upgrade setuptools \
  && pip install --upgrade cryptography>=2.1.4 \
  && pip install --upgrade ansible \
  && virtualenv -p python3 /opt/owasp/venv \
  && . /opt/owasp/venv/bin/activate \
  && pip install --upgrade pip \
  && pip install --upgrade setuptools \
  && pip install --upgrade cryptography>=2.1.4 \
  && pip install --upgrade ansible \
  && pip list

ENV PROJECT_NAME owasp
ENV LOG_DIR /opt/logs
ENV CONFIG_DIR /opt/logs
ENV DATA_DIR /opt/logs
ENV PATH="/opt/tools/apache-maven/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/sbin:/bin"
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

RUN mkdir -p -m 777 /opt/owasp /opt/shared /opt/logs /opt/data /opt/configs /opt/nvd /opt/depchecker /opt/jenkins /opt/certs /opt/reports /opt/scanthisdir

RUN /bin/echo "Installing Plugins"

COPY ./docker/data/jenkins/ref/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

WORKDIR /opt/owasp/ansible

COPY ./ansible /opt/owasp/ansible

RUN chmod 777 /opt/owasp/ansible \
  && ls -l /opt/owasp/ansible

RUN /bin/echo "Starting OWASP build"

# default user is jenkins with home dir in /var/jenkins_home
RUN /bin/echo 'PATH="/opt/tools/apache-maven/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/sbin:/bin"' >> /var/jenkins_home/.bashrc

RUN /bin/echo "Installing Maven using Ansible" \
  && . /opt/owasp/venv/bin/activate \
  && cd /opt/owasp/ansible \
  && ansible-playbook -i inventories/inventory_dev install-maven.yml -e install_maven=1 -vvvv

RUN /bin/echo "Installing NIST National Vulnerability Database and NVD Dependency Checker using Ansible and Maven" \
  && . /opt/owasp/venv/bin/activate \
  && cd /opt/owasp/ansible \
  && ansible-playbook -i inventories/inventory_dev install-tools.yml -e clone_depchecker=1 -e clone_nvd_dl=1 -vvvv

RUN /bin/echo "Downloading NIST National Vulnerability Database file" \
  && . /opt/owasp/venv/bin/activate \
  && cd /opt/owasp/ansible \
  && ansible-playbook -i inventories/inventory_dev download-nvd.yml -vvvv

RUN /bin/echo "Generating National Vulnerability H2 Database for increasing OWASP analysis performance" \
  && . /opt/owasp/venv/bin/activate \
  && cd /opt/owasp/ansible \
  && ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e rebuild_nvd=1 -e owasp_scan_dir="/opt/owasp/venv/bin" -vvvv

RUN /bin/echo "Installing ZAP community scripts in: /opt/zapscripts" \
  && git clone https://github.com/zaproxy/community-scripts.git /opt/zapscripts

RUN /bin/echo "Installing Certs"

COPY ./docker/bashrc /root/.bashrc
ADD docker/certs /opt/certs

RUN /bin/echo "Installing Python Utilities"

COPY owasp-jenkins-latest.tgz /opt/owasp

RUN cd /opt/owasp \
  && tar xvf owasp-jenkins-latest.tgz \
  && ls /opt/owasp

RUN cd /opt/owasp \
  && . /opt/owasp/venv/bin/activate \
  && pip install -e . \
  && pip list

ENTRYPOINT /opt/owasp/owasp_jenkins/scripts/start-container.sh
