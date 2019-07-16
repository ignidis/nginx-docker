#!/bin/bash
#
# docker build deconz image
# Usage:
#        [sudo] build.sh <nginx-version> <registry> <registry-user> <registry-pwd> <project>

#
# Must run as superuser, either you are root or must sudo 
#
docker build --build-arg NAME="NGINX" --build-arg APP_ROOT="/opt/www" --build-arg NGINX_VERSION="$1" --build-arg NGINX_REPO="nginx-stable" --build-arg NGINX_SHORT_REPO="stable" --build-arg NGINX_SVC_NAME="nginx" --build-arg NGINX_SVC_UID="9001" --rm -t builder:ml-nginx-amd64-centos --file ./Builderfile . && \
docker run --rm -it -d --name builder-nginx-amd64-centos builder:ml-nginx-amd64-centos bash && \
docker export builder-nginx-amd64-centos | docker import - builder:nginx-amd64-centos && \
docker kill builder-nginx-amd64-centos && \
docker build --build-arg NAME="NGINX" --build-arg APP_ROOT="/opt/www" --build-arg NGINX_VERSION="$1" --build-arg NGINX_REPO="nginx-stable" --build-arg NGINX_SHORT_REPO="stable" --build-arg NGINX_SVC_NAME="nginx" --build-arg NGINX_SVC_UID="9001" --rm -t "$2"/"$5"/nginx:"$1"-amd64-centos . && \
docker rmi builder:ml-nginx-amd64-centos builder:nginx-amd64-centos && \
docker login -p "$4" -u "$3" "$2" && \
docker push "$2"/"$5"/nginx:"$1"-amd64-centos && \
docker rmi "$2"/"$5"/nginx:"$1"-amd64-centos