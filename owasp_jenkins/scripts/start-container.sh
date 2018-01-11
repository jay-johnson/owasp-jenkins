#!/bin/bash

echo ""
date

use_cert=/opt/certs/jenkins_server_cert.pem
use_key=/opt/certs/jenkins_server_key.pem

if [[ "${PATH_TO_CERT}" == "" ]]; then
    if [[ -e ${PATH_TO_CERT} ]]; then
        use_cert=${PATH_TO_CERT}
    fi
fi

if [[ "${PATH_TO_KEY}" == "" ]]; then
    if [[ -e ${PATH_TO_KEY} ]]; then
        use_key=${PATH_TO_KEY}
    fi
fi

if [[ -e ${use_cert} ]] && [[ -e ${use_key} ]]; then
    echo "Starting Jenkins using certs on:"
    echo ""
    echo "https://jenkins.localdev.com:8443"
    echo ""
    echo "Login:"
    echo ""
    echo "User: ${ADMIN_JENKINS_USER}"
    echo "Password: ${ADMIN_JENKINS_PASSWORD}"
    echo ""
    /sbin/tini -- /usr/local/bin/jenkins.sh --httpsPort=8443 --httpsCertificate=${use_cert} --httpsPrivateKey=${use_key}
else
    /sbin/tini -- /usr/local/bin/jenkins.sh
fi

touch /tmp/keeprunning
tail -f /tmp/keeprunning
