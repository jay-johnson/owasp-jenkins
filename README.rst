OWASP Jenkins in Docker
=======================

Want to automate testing your python applications using the latest OWASP security toolchains and the NIST National Vulnerability Database (NVD)?

This repository uses ansible to create a docker container to hold an automatically-configured Jenkins application with the `OWASP Dependency Checker`_, `NIST NVD`_, `Python OWASP ZAP`_, and `Openstack Bandit`_ installed. All Jenkins jobs run inside this docker container and are hosted using self-signed ssl certificates.

Hopefully this will make securing your applications easier.

.. _NIST NVD: https://nvd.nist.gov/vuln/data-feeds
.. _OWASP Dependency Checker: https://github.com/jeremylong/DependencyCheck

Start the Container
-------------------

This will download the latest https://hub.docker.com/r/jayjohnson/owasp-jenkins container. Please note, because there are so many vulnerabilities this container will inflate to a size of about ``4.4 GB``.

::

    ./start.sh

Login to Jenkins
----------------

The login for the Jenkins instance is:

- username: admin
- password: testing

https://localhost:8443/

Running the OWASP Tools Manually
================================

I find it easier to initially integrate my applications with the OWASP + NIST toolchains by manually running tests from inside the container without a Jenkins job to debug at the same time.

SSH into the container with:

::

    docker exec -it owasp-jenkins bash

or from the base repository directory:

::

    ./ssh.sh

Confirm you're in the ansible directory:

::

    pwd
    /opt/owasp/ansible

Run OWASP Analysis and Generate an HTML Report
----------------------------------------------

This command will analyze the repository's ``/opt/owasp/owasp_jenkins/log/*.py`` modules using verbose ansible terminal output. This is helpful for figuring out what ansible is doing under the hood. By default the ansible playbook will create the OWASP html file inside the docker container directory: ``/opt/reports``. This directory is set up in the compose file to auto-mount to the host's directory ``./reports`` from the repository to make sharing and viewing these html reports easier.

::

    ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/owasp/owasp_jenkins/log" -e owasp_report_file="/opt/reports/owasp-report.html" -vvvv

Run Bandit Analysis and Generate an HTML Report
-----------------------------------------------

This will analyze the bandit project's own code with the bandit analyzer and generate an html report that will be stored on the host in the ``./reports`` directory.

::

    ansible-playbook -i inventories/inventory_dev run-bandit-analysis.yml -e bandit_scan_dir="/opt/owasp/venv/lib/python3.5/site-packages/bandit" -e bandit_report_file="/opt/reports/bandit-report.html" -vvvv

Onboarding Your Own Application with OWASP
------------------------------------------

The ansible playbook configures the Dependency Checker parameters for making onboarding easier even behind a corporate proxy. These are the general steps I run through to get an application automatically scanned within a Jenkins job.

#.  Changing the Runtime Parameters

    Please checkout what can be overridden from the ansible-playbook cli using the ``-e <arg name>="<arg value>"`` and then port them into your Jenkins build jobs.

    https://github.com/jay-johnson/owasp-jenkins/blob/master/ansible/roles/install/vars/jenkins-runtime-latest.yml

#.  Tuning OWASP Runtime Arguments

    The Dependency Checker supports numerous parameters to test and audit an application. I would recommend periodically reviewing what has changed to make sure you are using the right ones for each application:

    https://jeremylong.github.io/DependencyCheck/dependency-check-maven/configuration.html

    By default, this repository was built to analyze python so I am using: ``owasp_python_args="--enableExperimental true"``

#.  Setting up an OWASP pom.xml file

    There are two sample ``pom.xml`` files in the repo. One is for testing with my `celery-connectors`_ repository and the other is the default.
    
    - https://github.com/jay-johnson/owasp-jenkins/blob/master/ansible/roles/install/files/initial-pom.xml
    - https://github.com/jay-johnson/owasp-jenkins/blob/master/ansible/roles/install/files/celery-connectors-pom.xml
    
    There are numerous different configurable options that each application should review to ensure they are testing their code accordingly.

    https://jeremylong.github.io/DependencyCheck/dependency-check-maven/index.html

    Once you have a ``pom.xml`` ready for testing you can use it with the ``run-owasp-analysis.yml`` by adding the arguments: 
    
    ``-e owasp_pom="<path to your application pom.xml>"``

    .. _celery-connectors: https://github.com/jay-johnson/celery-connectors

#.  Set up OWASP Jenkins Jobs

    I prefer to set up my Jenkins jobs using the ``Execute shell - Command`` to configure my security toolchains in my CI/CD pipelines. These are the shell snippets for how I set up my initial OWASP jobs for a new security-ready CI/CD pipeline.

    #.  NIST National Vulnerability Database Update Job

        This job should run every seven days to pull in the latest updates or you can just rebuild this container (just a friendly reminder, don't forget to back up or migrate your jobs):

        https://jeremylong.github.io/DependencyCheck/data/index.html

        ::

            echo "Downloading NIST National Vulnerability Database file"
            . /opt/owasp/venv/bin/activate
            cd /opt/owasp/ansible
            ansible-playbook -i inventories/inventory_dev download-nvd.yml -vvvv

    #.  Run OWASP and Bandit Analysis on any new repo PR or merged-PR Job

        I usually assume the Jenkins job has ``WORKSPACE`` as the directory for the source code to check. I also try to automate email delivery by making sure the auto-generated html files are under the job's workspace to ensure the job can send an email with the files attached for review.

        ::

            echo "Running OWASP Analysis on Workspace=${WORKSPACE}"
            . /opt/owasp/venv/bin/activate
            cd /opt/owasp/ansible

            # If needed, make sure to specify the path to the repository's pom.xml:
            # -e owasp_pom="/opt/owasp/ansible/roles/install/files/initial-pom.xml"
            # and set the project label to match it:
            # -e owasp_project_label="analyze-this-code"
            ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="${WORKSPACE}" -e owasp_report_file="${WORKSPACE}/owasp-report.html" -vvvv

            echo "Running Bandit Analysis on Workspace=${WORKSPACE}"
            ansible-playbook -i inventories/inventory_dev run-bandit-analysis.yml -e bandit_scan_dir="${WORKSPACE}" -e bandit_report_file="${WORKSPACE}/bandit-report.html" -vvvv

    #.  Update NIST Downloader and Dependency Checker Tools Job

        This job will update the local, cloned repositories for the NIST NVD Downloader and Dependency Checker. This is helpful if you have to maintain an internal fork of these repositories for enhancing or modifying their testing.

        ::

            echo "Installing NIST National Vulnerability Database and NVD Dependency Checker using Ansible and Maven"
            . /opt/owasp/venv/bin/activate
            cd /opt/owasp/ansible
            ansible-playbook -i inventories/inventory_dev install-tools.yml -vvvv

Build the OWASP Jenkins Container
---------------------------------

This will build a large docker container (derived from ``jenkins/jenkins:latest``) by installing the following security packages listed below. If you want to install these later after the build you can run the ansible playbooks as needed by commenting out the install lines of the Dockerfile (https://github.com/jay-johnson/owasp-jenkins/blob/master/Dockerfile#L69-L87).

Build the container using this script in the base directory of the repository:

::

    ./build.sh

While you're waiting, here's what is installing inside the container:

- `OWASP Website`_
- `NVD Data Feeds`_
- `Dependency Checker`_
- `OpenStack Bandit`_
- `Python OWASP ZAP`_

.. _OWASP Website: https://www.owasp.org/index.php/Main_Page
.. _NVD Data Feeds: https://nvd.nist.gov/vuln/data-feeds
.. _Dependency Checker: https://github.com/jeremylong/DependencyCheck
.. _OpenStack Bandit: https://github.com/openstack/bandit
.. _Python OWASP ZAP: https://github.com/zaproxy/zap-api-python

Force a Rebuild of the NVD H2 files using the Dependency Checker
----------------------------------------------------------------

If you want to manually download the latest NVD updates you can run the included ansible playbook from inside the container. This can take a while if you're behind a proxy so I usually have a dedicated Jenkins job that handles updating the h2 database during off hours.

::

    ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e rebuild_nvd=1 -e owasp_scan_dir="/opt/owasp/owasp_jenkins/log" -vvvv

Cleaning up Everything on the Host before a Clean Rebuild
---------------------------------------------------------

Please be careful. This command will delete all the downloaded NIST NVD data files, maven, and the Dependency Checker tool if you have host-mounted them and commented-out the ansible-playbook install steps in the Docker container.

::

    sudo rm -rf ./docker/data/nvd/* ./docker/data/nvd/.git ./docker/data/tools/nvd/* ./docker/data/tools/nvd/.git ./docker/data/tools/depcheck/* ./docker/data/tools/depcheck/.git ./docker/data/tools/*

Setting up a Development Environment
------------------------------------

Setup the virtual environment with the command:

::

    virtualenv -p python3 venv && source venv/bin/activate && pip install -e .

Linting
-------

::

    pycodestyle --max-line-length=160 --exclude=venv,build,.tox

License
-------

Apache 2.0 - Please refer to the LICENSE_ for more details

.. _License: https://github.com/jay-johnson/owasp-jenkins/blob/master/LICENSE

