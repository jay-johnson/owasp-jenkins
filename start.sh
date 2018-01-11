#!/bin/bash

# this assumes docker is running and docker-compose is installed

compose_file="compose-owasp.yml"

echo "Starting OWASP-Ready Jenkins with compose_file=${compose_file}"
docker-compose -f $compose_file up

exit 0
