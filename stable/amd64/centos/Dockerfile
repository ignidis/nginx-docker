#
# Use the unmodified centos image
#
FROM builder:nginx-amd64-centos

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
# Setup runtime variables
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