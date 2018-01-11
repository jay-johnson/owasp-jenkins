#!/bin/bash

# this assumes docker is running and docker-compose is installed

compose_file="compose-owasp.yml"

echo "Stopping OWASP Jenkins with compose_file=${compose_file}"
docker-compose -f ${compose_file} stop

# This will delete your jobs... please be careful
# if [[ "$?" == "0" ]]; then
#     docker rm owasp-jenkins >> /dev/null 2>&1
# fi

exit 0
