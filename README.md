# Eclipse Che Cloud Native Recipe 

This Eclipse Che recipe contains JDK 8, OpenShift CLI, Openshift DO and Ansible.

This recipe is available as a docker image on Docker Hub:
https://hub.docker.com/r/mcouliba/che-cloud-native/

You can find more details in Eclipse Che docs about stacks and recipes:
https://www.eclipse.org/che/docs/creating-starting-workspaces.html

The following environment variables can be set on the stack or workspace to configure this 
recipe:

`MAVEN_MIRROR_URL`: add a Maven repository as the mirror url in `$HOME/.m2/settings.xml`

`DOWNLOAD_ARCHIVE_URL`: url to a `zip` or `tar.gz` archive to be downloaded into `$HOME` when the workspace started. It can be used to download project files, scripts, lab solutions etc into the workspace

## Build
```
$ docker build . --tag 'mcouliba/che-cloud-native:latest'
$ docker images
REPOSITORY                        TAG                 IMAGE ID            CREATED             SIZE
mcouliba/che-cloud-native         latest              fcfa05aed2c8        9 minutes ago       2.61GB
```

## Deploy on Docker Hub
```
$ docker login
$ docker push mcouliba/che-cloud-native
```