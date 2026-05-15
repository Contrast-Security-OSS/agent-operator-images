# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM ubuntu:noble@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b AS builder

RUN set -xe \
  && apt-get update \
  && apt-get install -y curl gnupg2 rsync

ARG VERSION
RUN test -n "$VERSION" || (echo "VERSION arg not set, pass --build-arg 'VERSION=<version>' to docker build" && false)

RUN set -xe \
  && curl https://pkg.contrastsecurity.com/api/gpg/key/public | apt-key add - \
  && echo "deb https://pkg.contrastsecurity.com/debian-public/ noble contrast" > /etc/apt/sources.list.d/contrast.list \
  && echo "deb https://pkg.contrastsecurity.com/debian-public/ all contrast" >> /etc/apt/sources.list.d/contrast.list \
  && apt-get update \
  && apt-get install -y contrast-php-agent=${VERSION} \
  && mkdir -p /contrast \
  && mkdir -p /contrast/ini \
  && rsync -aP /usr/local/lib/contrast/php/ /contrast/ \
  && echo 'extension=${CONTRAST_MOUNT_PATH}/contrast.so' > /contrast/ini/php.ini \
  && echo '{ "version": "${VERSION}" }' > /contrast/image-manifest.json

FROM busybox:stable@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662 AS final

RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user

COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast

ARG VERSION
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=php

USER 1001

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
