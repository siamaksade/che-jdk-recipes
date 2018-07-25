#!/bin/bash
# Copyright (c) 2012-2017 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Red Hat, Inc. - initial implementation

set -e

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

if ! grep -Fq "${USER_ID}" /etc/passwd; then
    envsubst < ${HOME}/passwd.template > /etc/passwd
    envsubst < ${HOME}/group.template > /etc/group
    touch ${HOME}/is_arbitrary_user
fi

# check for the MAVEN_MIRROR_URL env variable, if its available then set maven mirrors in $HOME/.m2/settings.xml
configure_mirrors() {
  if [ -n "$MAVEN_MIRROR_URL" ]; then
    xml="    <mirror>\
      <id>mirror.default</id>\
      <url>$MAVEN_MIRROR_URL</url>\
      <mirrorOf>external:*</mirrorOf>\
    </mirror>"
    sed -i "s|<!-- ### configured mirrors ### -->|$xml|" "${HOME}/.m2/settings.xml"
  fi
}

function download_projects() {
  if [ -n "$DOWNLOAD_ARCHIVE_URL" ]; then
    cd "${HOME}"

    if [[ $DOWNLOAD_ARCHIVE_URL =~ \.gz$ ]]; then
      curl -skL -o projects.tar.gz $DOWNLOAD_ARCHIVE_URL
      tar xvfz projects.tar.gz
      rm -rf projects.tar.gz

    elif [[ $DOWNLOAD_ARCHIVE_URL =~ \.zip$ ]]; then
      curl -skL -o projects.zip $DOWNLOAD_ARCHIVE_URL
      unzip projects.zip
      rm -rf projects.zip
    fi
  fi
}

configure_mirrors
download_projects

exec "$@"