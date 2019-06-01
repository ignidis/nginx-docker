This is a Dockerfile and build bash script for the OFFICIAL NGINX ORG Distribution.
This can be used as it is for deploying NGINX to a Docker or Openshift environment, or as base image for applications.
It is based on CENTOS - 7 at the time i write this - but it should be quite simple to convert for Debian derivates.
This image exposes only port 8080 and 8443 - eventhough the bare server is bound only to 8080 and HTTP - but it would quite easy to start the image binding /etc/nginx and a for example /opt/wwwroot to host provided volumes containing a persistent configuration and web content.
The image is meant to run NGINX using a NON-ROOT user, per default UID 9001 is used, but you can change to another UID at build time.
Keep in mind that the NGINX user needs access to the host volumes , should you mount content.
How you acomplish this depends on your base system, docker or openshift, and their config (maybe you find some inspiration in the other repositories i have published)
