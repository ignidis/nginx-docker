#!/bin/bash
#
# docker build deconz image
# Usage:
#        [sudo] build.sh <nginx-version>
#
# Must run as superuser, either you are root or must sudo 
#
docker build --build-arg NAME="nginx" --build-arg NGINX_VERSION="$1" --build-arg NGINX_REPO="nginx-stable" --build-arg NGINX_SHORT_REPO="stable" --build-arg NGINX_SVC_NAME="nginx" --build-arg NGINX_SVC_UID="9001" -t nginx:"$1"-amd64-centos .
