# Eclipse Che JDK Recipe [![Build Status](https://travis-ci.org/siamaksade/che-jdk-recipes.svg?branch=master)](https://travis-ci.org/siamaksade/che-jdk-recipes)

This Eclipse Che recipe contains JDK 8, OpenShift CLI and Ansible and also pre-populates the local 
Maven repository with Spring Boot dependencies.

This recipe is available as a docker image on Docker Hub:
https://hub.docker.com/r/siamaksade/che-centos-jdk8/

You can find more details in Eclipse Che docs about stacks and recipes:
https://www.eclipse.org/che/docs/creating-starting-workspaces.html

The following environment variables can be set on the stack or workspace to configure this 
recipe:

`MAVEN_MIRROR_URL`: add a Maven repository as the mirror url in `$HOME/.m2/settings.xml`

`DOWNLOAD_ARCHIVE_URL`: url to a `zip` or `tar.gz` archive to be downloaded into `$HOME` when the workspace started. It can be used to download project files, scripts, lab solutions etc into the workspace

