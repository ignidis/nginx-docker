#
# Use the unmodified centos image
#
FROM centos:7

#
# Build Time Arguments
#
ARG NAME
ARG NGINX_VERSION
ARG NGINX_REPO
ARG NGINX_SHORT_REPO
ARG NGINX_SVC_NAME
ARG NGINX_SVC_UID

#
# Add NGINX official repositories
#
COPY ./yum/nginx.repo /etc/yum.repos.d/nginx.repo

#
# Install the NGINX official repository and update the image packages
#
RUN yum install -y yum-utils; \
    yum-config-manager --enable ${NGINX_REPO}; \
    yum -y update && yum -y upgrade; \
#
#
# Install NGINX and any additional support packages
#
    yum install -y --setopt=tsflags=nodocs \
        gettext \
        nginx \
        nginx-module-njs \
        nginx-module-xslt \
    ; \
#
#
#   Install certbot for automatic Let's Encrypt TLS Certificate maintenance
#
    yum install -y epel-release; \
    yum install -y certbot python2-certbot-nginx; \
#
#
# Do some cleanup to reduce the image load
#
    yum clean all -y; \
    rm -rf /var/cache/yum; \
    rm -rf /var/temp; \
#
#
# Create or modify nginx group and service account to use the uid,guid we desire
#
    if id -u ${NGINX_SVC_NAME} >/dev/null 2>&1; then  \
        groupmod -g ${NGINX_SVC_UID} ${NGINX_SVC_NAME}; \ 
        usermod  -u ${NGINX_SVC_UID} -g ${NGINX_SVC_NAME} ${NGINX_SVC_NAME}; \
    fi; 
#
#
# Put all the config files in the same area so we can use a volume to make them persistente
#
RUN mkdir /etc/nginx/ssl; \
    cp -dR --preserve=all /etc/ssl /etc/nginx; \
    rm -rf /etc/ssl; \
    ln -sf /etc/nginx/ssl /etc/ssl;

RUN mkdir /etc/nginx/letsencrypt; \
    cp -dR --preserve=all /etc/letsencrypt /etc/nginx; \
    rm -rf /etc/letsencrypt; \
    ln -sf /etc/nginx/letsencrypt /etc/letsencrypt;
#
# Implement changes required to run NGINX as an unprivileged user
#
#
# Change access to the cache directory
#
RUN    chown -R ${NGINX_SVC_UID}:0 /var/cache/nginx; \
    chmod -R g+w /var/cache/nginx; \
#
#
# Modify Default site configuration
# Set default HTTP, HTTPS site config to listen on the exposed port
#
    sed -i -e '/listen/!b' -e '/80;/!b' -e 's/80;/8080;/' /etc/nginx/conf.d/default.conf; \
    sed -i -e '/listen/!b' -e '/443;/!b' -e 's/443;/8443;/' /etc/nginx/conf.d/default.conf; \
#
#
# Modify default server configuration
#
    sed -i -e '/user/!b' -e '/nginx/!b' -e '/nginx/d' /etc/nginx/nginx.conf; \
    sed -i 's!/var/run/nginx.pid!/var/cache/nginx/nginx.pid!g' /etc/nginx/nginx.conf; \
    sed -i "/^http {/a \    proxy_temp_path /var/cache/nginx/proxy_temp;\n    client_body_temp_path /var/cache/nginx/client_temp;\n    fastcgi_temp_path /var/cache/nginx/fastcgi_temp;\n    uwsgi_temp_path /var/cache/nginx/uwsgi_temp;\n    scgi_temp_path /var/cache/nginx/scgi_temp;\n" /etc/nginx/nginx.conf; \
#
#
# forward request and error logs to docker log collector
#
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log

#
# Compress the images
#
FROM scratch
COPY --from=0 / /

#
# Build Time Arguments
#
ARG NAME
ARG NGINX_VERSION
ARG NGINX_REPO
ARG NGINX_SHORT_REPO
ARG NGINX_SVC_NAME
ARG NGINX_SVC_UID

#
# Do some bookeeping for the repository and openshift
#
#
# It is deprecated but guess what...There are a lot of tools that still use it
#
MAINTAINER ignidis(at)cybearth(dot)net (https://github.com/ignidis/nginx-docker)

#
# And this is for those new tools
#
LABEL summary="Platform for running ${NAME}-${NGINX_SHORT_REPO}-${NGINX_VERSION} or building ${NAME}-based applications" \
      description="${NAME} is a web server and a reverse proxy server for HTTP, SMTP, POP3 and IMAP protocols, with a strong focus on high concurrency, performance and low memory usage. The container image provides a containerized packaging of the ${NAME}-${NGINX_SHORT_REPO}-$NGINX_VERSION daemon. The image can be used as a base image for other applications based on the ${NAME} web server. The ${NAME} server image can be extended using a source-to-image tool." \
      io.k8s.description="${NAME} is a web server and a reverse proxy server for HTTP, SMTP, POP3 and IMAP protocols, with a strong focus on high concurrency, performance and low memory usage. The container image provides a containerized packaging of the ${NAME}-${NGINX_SHORT_REPO}-$NGINX_VERSION daemon. The image can be used as a base image for other applications based on the ${NAME} web server. The ${NAME} server image can be extended using a source-to-image tool." \
      io.k8s.display-name="NGINX-${NGINX_SHORT_REPO}-${NGINX_VERSION}" \
      io.openshift.expose-services="8080:http" \
      io.openshift.expose-services="8443:https" \
      io.openshift.tags="builder,${NAME},${NAME}-${NGINX_SHORT_REPO}-${NGINX_VERSION}" \
      name="${NAME}" \
      version="${NGINX_VERSION}-amd64-centos" \
      maintainer="ignidis(at)cybearth(dot)net" \
      help="For more information visit https://github.com/ignidis/nginx-docker" \
      usage="s2i build <SOURCE-REPOSITORY> ${NAME}:${NGINX_VERSION}-amd64-centos <APP-NAME>"

#
# Publish the standard web ports
#
EXPOSE 8080

STOPSIGNAL SIGTERM

USER ${NGINX_SVC_UID}

CMD ["nginx", "-g", "daemon off;"]
