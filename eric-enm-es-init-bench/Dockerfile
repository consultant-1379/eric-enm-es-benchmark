ARG OS_BASE_IMAGE_NAME=sles
ARG OS_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release
ARG OS_BASE_IMAGE_TAG=6.16.0-13

FROM $OS_BASE_IMAGE_REPO/$OS_BASE_IMAGE_NAME:$OS_BASE_IMAGE_TAG

ARG OS_BASE_IMAGE_TAG
ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified

RUN zypper ar -C -G -f https://arm.rnd.ki.sw.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/$OS_BASE_IMAGE_TAG?ssl_verify=no LDC-SLES15 && \
    zypper --non-interactive ref -f -r LDC-SLES15 && \
    zypper --non-interactive in curl && \
    zypper clean -a && \
    echo "$USER_ID:x:$USER_ID:0:An Identity for $USER_NAME:/nonexistent:/bin/false" >>/etc/passwd && \
    echo "$USER_ID:!::0:::::" >>/etc/shadow

COPY agent_wait.sh /
RUN chmod +x agent_wait.sh

ENTRYPOINT ["/agent_wait.sh"]