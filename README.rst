OWASP Jenkins in Docker
=======================

Want to automate testing your web applications and REST API service layers using the latest OWASP security toolchains and the NIST National Vulnerability Database (NVD)?

This repository uses Ansible to create a docker container to hold an automatically-configured Jenkins application with the `OWASP Dependency Checker`_, `NIST NVD`_, `Python OWASP ZAP`_, and `Openstack Bandit`_ installed. All Jenkins jobs run inside this docker container and are hosted using self-signed ssl certificates.

Hopefully this will make securing your applications easier by jumpstarting your testing with the `OWASP Top 10 Application Security Risks - 2017`_.

.. _NIST NVD: https://nvd.nist.gov/vuln/data-feeds
.. _OWASP Dependency Checker: https://github.com/jeremylong/DependencyCheck
.. _OWASP Top 10 Application Security Risks - 2017: https://www.owasp.org/index.php/Top_10_2017-Top_10

Quickly Analyze any Repository with OWASP
-----------------------------------------

Here's how to scan a repository for security issues. This will download the latest https://hub.docker.com/r/jayjohnson/owasp-jenkins container. Please note: because there are so many known vulnerabilities to test, the container inflates to a size of about ``4.4 GB`` on disk.

In this example I am testing the Bandit repository https://github.com/openstack/bandit.git and will create the ``owasp-report-<date>.html`` file in the current directory before removing the container.

#.  Check there's nothing in the directory:

    ::

        ls | grep html

#.  Pick a Repository to Scan

    ::

        repo=https://github.com/openstack/bandit.git

#.  Run the OWASP Analysis and Generate the HTML Report

    ::

        docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/scanrepo" -e owasp_report_file="/opt/reports/owasp-report-$(date +'%Y-%m-%d-%H-%M-%S').html"

    This will log something like below:

    ::

        d9d9c4e1945b7c0822f29aaae4db48842454ed693e1cc40d041f8362cd49cb12
        Cloning into '/opt/scanrepo'...
        remote: Counting objects: 5975, done.
        remote: Compressing objects: 100% (26/26), done.
        remote: Total 5975 (delta 5), reused 21 (delta 0), pack-reused 5949
        Receiving objects: 100% (5975/5975), 1.39 MiB | 0 bytes/s, done.
        Resolving deltas: 100% (4104/4104), done.
        [WARNING]: log file at /opt/owasp/ansible/"/tmp/owasp-jenkins.log" is not writeable and we cannot create it, aborting


        PLAY [Running OWASP Analysis] **************************************************

        TASK [set_fact] ****************************************************************
        ok: [localhost]

        TASK [set_fact] ****************************************************************
        ok: [localhost]

        TASK [set_fact] ****************************************************************
        ok: [localhost]

        TASK [set_fact] ****************************************************************
        ok: [localhost]

        TASK [set_fact] ****************************************************************
        ok: [localhost]

        TASK [set_fact] ****************************************************************
        ok: [localhost]

        TASK [set_fact] ****************************************************************
        ok: [localhost]

        TASK [set_fact] ****************************************************************
        ok: [localhost]

        TASK [set_fact] ****************************************************************
        ok: [localhost]

        TASK [Checking if this is a rebuild_nvd=0] *************************************
        skipping: [localhost]

        TASK [Building OWASP Arguments] ************************************************
        ok: [localhost]

        TASK [Running OWASP Report depchecker=/opt/tools/depcheck/dependency-check-cli/target/release/bin/dependency-check.sh owasp_args= -n --enableExperimental true --out /opt/reports/owasp-report-2018-01-10-20-21-18.html --scan /opt/scanrepo -P /opt/owasp/ansible/roles/install/files/initial-pom.xml --project analyze-this-code --data /opt/nvd] ***
        changed: [localhost]

        TASK [Checking if the OWASP Report=/opt/reports/owasp-report-2018-01-10-20-21-18.html exists] ***
        ok: [localhost]

        TASK [Verifying OWASP Report=/opt/reports/owasp-report-2018-01-10-20-21-18.html was created] ***
        skipping: [localhost]

        PLAY RECAP *********************************************************************
        localhost                  : ok=12   changed=1    unreachable=0    failed=0

#.  Verify the OWASP HTML Report Exists

    ::

        ls | grep html
        owasp-report-2018-01-10-20-21-18.html

#.  Cleanup the Docker Container

    ::

        docker stop owasp-jenkins; docker rm owasp-jenkins
        owasp-jenkins
        owasp-jenkins

Analyzing Popular GitHub Repositories
=====================================

I hope this container makes it easy to find security risks in your code and in any third-party dependencies. Here's examples for analyzing some of the most popular GitHub repositories:

Scan Django
-----------

Scan Django and generate an OWASP HTML Report for third-party vulnerabilities:

::

    repo=https://github.com/django/django.git
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/scanrepo" -e owasp_report_file="/opt/reports/owasp-django-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l owasp-django-report-*.html

Scan React
----------

Scan React and generate an OWASP HTML Report for third-party vulnerabilities:

::

    repo=https://github.com/facebook/react.git
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/scanrepo" -e owasp_report_file="/opt/reports/owasp-react-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l owasp-react-report-*.html

Scan Vue
--------

Scan Vue and generate an OWASP HTML Report for third-party vulnerabilities:

::

    repo=https://github.com/vuejs/vue.git
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/scanrepo" -e owasp_report_file="/opt/reports/owasp-vue-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l owasp-vue-report-*.html

Scan Angular
------------

Scan Angular and generate an OWASP HTML Report for third-party vulnerabilities:

::
    
    repo=https://github.com/angular/angular.git
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/scanrepo" -e owasp_report_file="/opt/reports/owasp-angular-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l owasp-angular-report-*.html

Scan Ruby on Rails
------------------

Scan Ruby on Rails and generate an OWASP HTML Report for third-party vulnerabilities:

::

    repo=https://github.com/rails/rails
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/scanrepo" -e owasp_report_file="/opt/reports/owasp-ror-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l owasp-ror-report-*.html

Scan Shadowsocks Windows
------------------------

Scan Shadowsocks Windows and generate an OWASP HTML Report for third-party vulnerabilities:

::
    
    repo=https://github.com/shadowsocks/shadowsocks-windows.git
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/scanrepo" -e owasp_report_file="/opt/reports/owasp-shadowsockswindows-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l owasp-shadowsockswindows-report-*.html

Scan Laravel
------------

Scan Laravel and generate an OWASP HTML Report for third-party vulnerabilities:

::
    
    repo=https://github.com/laravel/laravel
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/scanrepo" -e owasp_report_file="/opt/reports/owasp-laravel-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l owasp-laravel-report-*.html

Scan Django REST Framework
--------------------------

Scan Django REST Framework and generate an OWASP HTML Report for third-party vulnerabilities:

::

    repo=https://github.com/encode/django-rest-framework.git
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/scanrepo" -e owasp_report_file="/opt/reports/owasp-drf-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l owasp-drf-report-*.html

Want to generate Bandit reports for some of the most popular python projects?
-----------------------------------------------------------------------------

Scan Tensorflow and generate a Bandit HTML report (this can take a few minutes depending on your host):

::

    repo=https://github.com/tensorflow/tensorflow.git
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-bandit-analysis.yml -e bandit_scan_dir="/opt/scanrepo" -e bandit_report_file="/opt/reports/bandit-tf-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l bandit-tf-report-*.html

Scan Flask and generate a Bandit HTML report:

::

    repo=https://github.com/pallets/flask.git
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-bandit-analysis.yml -e bandit_scan_dir="/opt/scanrepo" -e bandit_report_file="/opt/reports/bandit-flask-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l bandit-flask-report-*.html

Scan Ansible and generate a Bandit HTML report (this can take a few minutes depending on your host):

::

    repo=https://github.com/ansible/ansible.git
    docker run --name owasp-jenkins -p 8443:8443 -v $(pwd):/opt/reports -it -d jayjohnson/owasp-jenkins:latest && docker exec -it owasp-jenkins git clone $repo /opt/scanrepo && docker exec -it owasp-jenkins ansible-playbook -i inventories/inventory_dev run-bandit-analysis.yml -e bandit_scan_dir="/opt/scanrepo" -e bandit_report_file="/opt/reports/bandit-ab-report-$(date +'%Y-%m-%d-%H-%M-%S').html" && docker stop owasp-jenkins && docker rm owasp-jenkins
    ls -l bandit-ab-report-*.html

Setting up Jenkins for Automating your Security Testing
=======================================================

Start the Container
-------------------

If you want to set up the Jenkins container or onboard an application with OWASP testing you can start the container with:

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

This command will analyze the repository's ``/opt/owasp/owasp_jenkins/log/*.py`` modules using verbose Ansible terminal output. This is helpful for figuring out what Ansible is doing under the hood. By default the Ansible playbook will create the OWASP html file inside the docker container directory: ``/opt/reports``. This directory is set up in the compose file to auto-mount to the host's directory ``./reports`` from the repository to make sharing and viewing these html reports easier.

::

    ansible-playbook -i inventories/inventory_dev run-owasp-analysis.yml -e owasp_scan_dir="/opt/owasp/owasp_jenkins/log" -e owasp_report_file="/opt/reports/owasp-report.html" -vvvv

Run Bandit Analysis and Generate an HTML Report
-----------------------------------------------

This will analyze the Bandit project's own code with the bandit analyzer and generate an html report that will be stored on the host in the ``./reports`` directory.

::

    ansible-playbook -i inventories/inventory_dev run-bandit-analysis.yml -e bandit_scan_dir="/opt/owasp/venv/lib/python3.5/site-packages/bandit" -e bandit_report_file="/opt/reports/bandit-report.html" -vvvv

Onboarding Your Own Application with OWASP
------------------------------------------

The Ansible playbook configures the `Dependency Checker parameters`_ for making onboarding easier even behind a corporate proxy. These are the general steps I run through to get an application automatically scanned within a Jenkins job.

.. _Dependency Checker parameters: https://github.com/jay-johnson/owasp-jenkins/blob/master/ansible/run-owasp-analysis.yml#L23-L31

#.  Changing the Runtime Parameters

    Please checkout what can be overridden from the ansible-playbook cli using the ``-e <arg name>="<arg value>"`` and then port them into your Jenkins build jobs.

    https://github.com/jay-johnson/owasp-jenkins/blob/master/ansible/roles/install/vars/jenkins-runtime-latest.yml

#.  Tuning OWASP Runtime Arguments

    The Dependency Checker supports numerous parameters to test and audit an application. I would recommend periodically reviewing what has changed to make sure you are using the right ones for each application:

    https://jeremylong.github.io/DependencyCheck/dependency-check-maven/configuration.html

    This repository was built to analyze python, but the `default pom.xml file`_ is set up with most of the available `language analyzers`_ enabled (node.js, java, .NET, ruby, php) and uses the default flag: ``owasp_analyzers="--enableExperimental true"``

    .. _default pom.xml file: https://github.com/jay-johnson/owasp-jenkins/blob/master/ansible/roles/install/files/initial-pom.xml
    .. _language analyzers: https://jeremylong.github.io/DependencyCheck/analyzers/index.html

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

This will build a large docker container (derived from ``jenkins/jenkins:latest``) by installing the following security packages listed below. If you want to install these later after the build you can run the Ansible playbooks as needed by commenting out the install lines of the Dockerfile (https://github.com/jay-johnson/owasp-jenkins/blob/master/Dockerfile#L84-L102).

Build the container using this script in the base directory of the repository:

::

    ./build.sh

While you're waiting, here's what is installing inside the container:

- `OWASP Website`_
- `NVD Data Feeds`_
- `Dependency Checker`_
- `Openstack Bandit`_
- `Python OWASP ZAP`_
- `Python OWASP ZAP Community Scripts`_

.. _OWASP Website: https://www.owasp.org/index.php/Main_Page
.. _NVD Data Feeds: https://nvd.nist.gov/vuln/data-feeds
.. _Dependency Checker: https://github.com/jeremylong/DependencyCheck
.. _Openstack Bandit: https://github.com/openstack/bandit
.. _Python OWASP ZAP: https://github.com/zaproxy/zap-api-python
.. _Python OWASP ZAP Community Scripts: https://github.com/zaproxy/community-scripts

Container OWASP Coverage Analysis
=================================
    
So how does this container and approach help cover applications for the `2017 OWASP Top 10 Application Security Risks`_?

The container was built to help quickly secure python application code with Bandit for `Static Application Security Testing (SAST)`_ and ZAP for `Dynamic Application Security Testing (DAST)`_. There's tradeoffs to adding more and more tools to cover each item because while the tools might help find more security risks the tradeoff is your team just added more testing overhead to support tools and keep them updated with your application builds.

This is a table to visualize how the container helps tests the OWASP Top 10:

+---------------------------------------------------+-------+--------+------------------+
| OWASP Top 10 Application Security Risks - 2017    | DAST_ + SAST_  + Third Party      |
+===================================================+=======+========+==================+
| `A1 Injection`_                                   | ZAP   | Bandit | Dependency Check |
+---------------------------------------------------+-------+--------+------------------+
| `A2 Broken Authentication`_                       | ZAP   | Bandit | Dependency Check |
+---------------------------------------------------+-------+--------+------------------+
| `A3 Sensitive Data Exposure`_                     | ZAP   | Bandit | Dependency Check |
+---------------------------------------------------+-------+--------+------------------+
| `A4 XML External Entities`_                       | ZAP   | Bandit | Dependency Check |
+---------------------------------------------------+-------+--------+------------------+
| `A5 Broken Access Control`_                       | ZAP   | Bandit | Dependency Check |
+---------------------------------------------------+-------+--------+------------------+
| `A6 Security Misconfiguration`_                   | ZAP   | Bandit | Dependency Check |
+---------------------------------------------------+-------+--------+------------------+
| `A7 Cross Site Scripting`_                        | ZAP   | Bandit | Dependency Check |
+---------------------------------------------------+-------+--------+------------------+
| `A8 Insecure Deserialization`_                    | None  | Bandit | Dependency Check |
+---------------------------------------------------+-------+--------+------------------+
| `A9 Using Components with Known Vulnerabilities`_ | ZAP   | None   | Dependency Check |
+---------------------------------------------------+-------+--------+------------------+
| `A10 Insufficient Logging and Monitoring`_        | None  | None   | None             | 
+---------------------------------------------------+-------+--------+------------------+

.. _2017 OWASP Top 10 Application Security Risks: https://www.owasp.org/index.php/Top_10-2017_Top_10
.. _Static Application Security Testing (SAST): https://www.owasp.org/index.php/Source_Code_Analysis_Tools
.. _Dynamic Application Security Testing (DAST): https://www.owasp.org/index.php/Category:Vulnerability_Scanning_Tools
.. _SAST: https://www.owasp.org/index.php/Source_Code_Analysis_Tools
.. _DAST: https://www.owasp.org/index.php/Category:Vulnerability_Scanning_Tools
.. _A1 Injection: https://www.owasp.org/index.php/Top_10-2017_A1-Injection
.. _A2 Broken Authentication: https://www.owasp.org/index.php/Top_10-2017_A2-Broken_Authentication
.. _A3 Sensitive Data Exposure: https://www.owasp.org/index.php/Top_10-2017_A3-Sensitive_Data_Exposure
.. _A4 XML External Entities: https://www.owasp.org/index.php/Top_10-2017_A4-XML_External_Entities_(XXE)
.. _A5 Broken Access Control: https://www.owasp.org/index.php/Top_10-2017_A5-Broken_Access_Control
.. _A6 Security Misconfiguration: https://www.owasp.org/index.php/Top_10-2017_A6-Security_Misconfiguration
.. _A7 Cross Site Scripting: https://www.owasp.org/index.php/Top_10-2017_A7-Cross-Site_Scripting_(XSS)
.. _A8 Insecure Deserialization: https://www.owasp.org/index.php/Top_10-2017_A8-Insecure_Deserialization
.. _A9 Using Components with Known Vulnerabilities: https://www.owasp.org/index.php/Top_10-2017_A9-Using_Components_with_Known_Vulnerabilities
.. _A10 Insufficient Logging and Monitoring: https://www.owasp.org/index.php/Top_10-2017_A10-Insufficient_Logging%26Monitoring

Force a Rebuild of the NVD H2 files using the Dependency Checker
----------------------------------------------------------------

If you want to manually download the latest NVD updates you can run the included Ansible playbook from inside the container. This can take a while if you're behind a proxy so I usually have a dedicated Jenkins job that handles updating the h2 database during off hours.

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

