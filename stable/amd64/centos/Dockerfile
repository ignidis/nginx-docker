#
# Use the unmodified centos image
#
FROM centos:7

#
# Build Time Arguments
#
ARG NAME
ARG APP_ROOT
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
    yum install -y --setopt=tsflags=nodocs\
        certbot \
        python2-certbot-nginx \
        cronie \
    ; \
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
        usermod  -u ${NGINX_SVC_UID} -g ${NGINX_SVC_NAME} -G root,wheel ${NGINX_SVC_NAME}; \
    fi; 
#
#
# Implement changes required to run NGINX as an unprivileged user
#
#
# Change access to the cache directory
#
RUN chown -R ${NGINX_SVC_UID}:0 /var/cache/nginx; \
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
# Create configuration directories under /etc/nginx so that we can use them as mountpoints for persistent configuration
# This design allows to use either a single mount point for /etc/nginx, or several for each of the subdirectories; this is specially design for the use of
# config maps under openshift 
# The entrypoint init script detects if a persistent mount was put on top of /etc/nginx and initializes the mount with the standard image setup, only if it was not already holding a configuration
# Under openshift config maps can be mounted in /etc/nginx/global.d/ - for the main config files usually stored under /etc/nginx - , /etc/nginx/conf.d/, /etc/nginx/var/ssl, /etc/nginx/var/letsencrypt
# combined with volume mounts.
# Usually a combination of maps for /etc/nginx/global.d/ and /etc/nginx/conf.d/ and a single volume for /etc/nginx/var/ would be most effective under openshift; as it combines simplicity of the config maps for doing config changes, whith the simple needs to provide persistence to letsencrypt and the ssl certificates, which are maintained by the automated certbot.
# Under plain Docker a simple volume on top of /etc/nginx would probably deliver the best results for persistence whith the less overhead
#
#
# Create the base directories
#
    mkdir -p ${APP_ROOT}; \
    mkdir -p /etc/nginx/global.d; \
    mkdir -p /etc/nginx/var; \
    mkdir -p /etc/letsencrypt/run; \
    mkdir -p /etc/letsencrypt/log; \
    mkdir -p /etc/letsencrypt/etc; \
    mkdir -p /etc/letsencrypt/live; \
    rm -f /etc/ssl/certs; \
    mkdir -p /etc/ssl/certs; \
    mkdir -p /etc/ssl/private; \
#
#
# Move the main configuration to the global.d folder and create the link for the startup code
#
    mv /etc/nginx/nginx.conf /etc/nginx/global.d/; \
    ln -sf /etc/nginx/global.d/nginx.conf /etc/nginx/nginx.conf; \
#
# Move SSL Certificates store
#
    mv /etc/ssl /etc/nginx/var/; \
    ln -sf /etc/nginx/var/ssl /etc/ssl; \
#
# Move Let's Encrypt certbot store
#
    mv /etc/letsencrypt /etc/nginx/var/; \
    ln -sf /etc/nginx/var/letsencrypt /etc/letsencrypt \
    ;
#
#
#
# Setup runtime variables
#
ENV PATH=${APP_ROOT}/bin:${PATH} \
    HOME=${APP_ROOT}

#
# Copy container startup script, certbot wrapper and certificate renewal scheduler
#
COPY bin/ ${APP_ROOT}/bin/
COPY var/ ${APP_ROOT}/var/

#
# Ammend the access rights to the configuration areas
# This will only work if the runtime user is member of the root group - this is the case with openshift
# In non openshift environment we should do the configuration volume initialization before attaching or make the executing user member of the root group
#
RUN rm -rf /var/log/*; \
#
#
# forward request and error logs to docker log collector
#
    mkdir -p /var/log/nginx; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log; \
#
#
# create the cron job for the Let's Encrypt certificate renewal it must run as root
#
    crontab ${APP_ROOT}/var/spool/certbot; \
#
#
# add permisions to the application init scripts and the certbot wrapper
# in addition allow the non root user to insert the anonymous openshift user if we want to use it
# and ensure we can read the config files
#
    chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/nginx /etc/passwd \
    ; \
#
# Save the image configuration to the application folder.
# This copy is used to initialze a persistent mount if the container detects /etc/nginx or /etc/nginx/var is empty
# The .has_init_mount flag is used for that purpose
#
    mkdir -p ${APP_ROOT}/etc/; \
    cp -dR --preserve=all /etc/nginx/ ${APP_ROOT}/etc/; \
    touch /etc/nginx/.has_init_mount; \
    touch /etc/nginx/var/.has_init_mount \
    ;
#
#
# Compress the images
#
FROM scratch
COPY --from=0 / /

#
# Build Time Arguments
#
ARG NAME
ARG APP_ROOT
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
      io.openshift.expose-services="9080:http-localhost" \
      io.openshift.tags="builder,${NAME},${NAME}-${NGINX_SHORT_REPO}-${NGINX_VERSION}" \
      name="${NAME}" \
      version="${NGINX_VERSION}-amd64-centos" \
      maintainer="ignidis(at)cybearth(dot)net" \
      help="For more information visit https://github.com/ignidis/nginx-docker" \
      usage="s2i build <SOURCE-REPOSITORY> ${NAME}:${NGINX_VERSION}-amd64-centos <APP-NAME>"

#
# the cron demon must run as root, seting the setuid bit ensures it does even started as non privileged
# the image copy seems to destroy the setuid flag, thus doing this after compresion
#
RUN chmod 4755 /usr/sbin/crond;

#
# we must ensure our certbot and init scripts are found in the right place and search order
#
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}

#
# Publish the standard web ports (http,https,http-localhost)
#
EXPOSE 8080 8443 9080

STOPSIGNAL SIGTERM

USER ${NGINX_SVC_UID}
WORKDIR ${APP_ROOT}

ENTRYPOINT [ "init" ]
CMD ["nginx", "-g", "daemon off;"]