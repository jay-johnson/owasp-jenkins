#!/bin/bash

maintainer=jayjohnson
imagename=owasp-jenkins
tag=$(cat setup.py | grep "version=" | sed -e 's/"/ /g' | awk '{print $2}')

log=/dev/null

source ./properties.sh

rm -f ${imagename}-*.tgz
include_these="owasp_jenkins ansible tests README.rst setup.cfg setup.py tox.ini"
echo "Creating src build tar for tag=${tag} including=${include_these}"
tar zcvf ${imagename}-${tag}.tgz ${include_these}
cp ${imagename}-${tag}.tgz ${imagename}-latest.tgz

echo ""
echo "--------------------------------------------------------"
echo "Building new Docker image(${maintainer}/${imagename})"
docker build --rm -t $maintainer/$imagename .
last_status=$?
if [[ "${last_status}" == "0" ]]; then
    echo ""
    if [[ "${tag}" != "" ]]; then
        image_csum=$(docker images | grep "${maintainer}/${imagename} " | grep latest | awk '{print $3}')
        if [[ "${image_csum}" != "" ]]; then
            docker tag $image_csum $maintainer/$imagename:$tag
            last_status=$?
            if [[ "${last_status}" != "0" ]]; then
                echo "Failed to tag image(${imagename}) with Tag(${tag})"
                echo ""
                exit 1
            else
                echo "Build Successful Tagged Image(${imagename}) with Tag(${tag})"
            fi

            echo ""
            exit 0
        else
            echo ""
            echo "Build failed to find latest image(${imagename}) with Tag(${tag})"
            echo ""
            exit 1
        fi
    else
        echo "Build Successful"
        echo ""
        exit 0
    fi
    echo ""
else
    echo ""
    echo "Build failed with exit code: ${last_status}"
    echo ""
    exit 1
fi

exit 0
