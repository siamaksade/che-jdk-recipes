#!/bin/bash

set -e
set -u

git_clone_and_build() {
  REPOSITORY=$1
  TAG=$2
  FOLDER=$3

  cd "${HOME}"
  CURRENT_FOLDER=$(pwd)

  echo "cloning with git clone -b ${TAG} ${REPOSITORY} tmp-folder"

  git clone -b "${TAG}" "${REPOSITORY}" tmp-folder
  cd tmp-folder/$FOLDER && scl enable rh-maven33 'mvn clean package verify'
  cd "${CURRENT_FOLDER}" && rm -rf tmp-folder
}

git_clone_and_build https://github.com/openshift-labs/rhsummit18-cloudnative-labs master catalog
