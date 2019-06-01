#
# Use the unmodified centos image
#
FROM centos:7

#
# Build Time Arguments
#
ARG NAME
ARG	NGINX_VERSION
ARG NGINX_REPO
ARG NGINX_SHORT_REPO
ARG	NGINX_SVC_NAME
ARG	NGINX_SVC_UID


#
# Do some bookeeping
#
ENV SUMMARY="Platform for running nginx $NGINX_VERSION-$NGINX_SHORT_REPO or building nginx-based application" \
    DESCRIPTION="Nginx is a web server and a reverse proxy server for HTTP, SMTP, POP3 and IMAP \
protocols, with a strong focus on high concurrency, performance and low memory usage. The container \
image provides a containerized packaging of the nginx $NGINX_VERSION-$NGINX_SHORT_REPO daemon. The image can be used \
as a base image for other applications based on nginx $NGINX_VERSION-$NGINX_SHORT_REPO web server. \
Nginx server image can be extended using source-to-image tool."

LABEL summary="${SUMMARY}" \
      description="${DESCRIPTION}" \
      io.k8s.description="${DESCRIPTION}" \
      io.k8s.display-name="NGINX ${NGINX_SHORT_REPO}-${NGINX_VERSION}" \
      io.openshift.expose-services="8080:http" \
      io.openshift.expose-services="8443:https" \
      io.openshift.tags="builder,${NAME},${NAME}-$NGINX_SHORT_REPO-${NGINX_VER}" \
      name="${NAME}" \
      version="${NGINX_VERSION}-amd64-centos" \
      maintainer="ignidis" \
      help="For more information visit https://github.com/ignidis" \
      usage="s2i build <SOURCE-REPOSITORY> ${NAME}:${NGINX_VERSION}-amd64-centos <APP-NAME>"

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
#	Install NGINX and any additional support packages
#
    yum install -y --setopt=tsflags=nodocs \
		gettext \
		nginx-${NGINX_VERSION} \
	; \	
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
    fi; \
#
#
# implement changes required to run NGINX as an unprivileged user
#
#
# Change access to the cache directory
#
    chown -R ${NGINX_SVC_UID}:0 /var/cache/nginx; \
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
# Publish the standard web ports
#
EXPOSE 8080 8443

STOPSIGNAL SIGTERM

USER ${NGINX_SVC_UID}

CMD ["nginx", "-g", "daemon off;"]