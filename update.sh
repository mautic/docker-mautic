#!/bin/bash
set -e

mautic_2_latest_version=2.16.5
mautic_3_latest_version="$(curl https://api.github.com/repos/mautic/mautic/releases/latest -s | jq -r .tag_name)"


for mautic_version in $mautic_2_latest_version $mautic_3_latest_version; do (

    # TODO - Expose SHA signatures for the packages somewhere
    filename=`mktemp`
    echo Loading https://github.com/mautic/mautic/releases/download/${mautic_version}/${mautic_version}.zip
    sha1=`wget --quiet --show-progress -O - https://github.com/mautic/mautic/releases/download/${mautic_version}/${mautic_version}.zip | sha1sum | head -c 40`

    path="mautic${mautic_version:0:1}/"

    echo ${path}: ${mautic_version} ${sha1}

    for variant in apache fpm; do (
        sed -ri '
            s/^(ENV MAUTIC_VERSION) .*/\1 '"${mautic_version}"'/;
            s/^(ENV MAUTIC_SHA1) .*/\1 '"${sha1}"'/;
        ' "${path}${variant}/Dockerfile"

        # To make management easier, we use these files for all variants
        cp ${path}common/* ${path}${variant}/
    ) done
) done
