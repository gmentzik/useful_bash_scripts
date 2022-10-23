#!/bin/bash

for img in $( docker images --format '{{.Repository}}:{{.Tag}}' --filter "dangling=false" ) ; do
    base=${img#*/}
    echo ${base}
    IMGFILENAME=${base//:/__}
    IMGFILENAME="${IMGFILENAME////_%_}".tar.gz
    echo "${IMGFILENAME}"
    docker save "$img" | gzip > "${IMGFILENAME}"
done

