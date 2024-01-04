# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM ubuntu:jammy AS builder

RUN set -xe \
  && apt-get update \
  && apt-get install -y curl gnupg2 rsync

ARG VERSION=1.2.0

RUN set -xe \
  && curl https://pkg.contrastsecurity.com/api/gpg/key/public | apt-key add - \
  && echo "deb https://pkg.contrastsecurity.com/debian-public/ jammy contrast" > /etc/apt/sources.list.d/contrast.list \
  && echo "deb https://pkg.contrastsecurity.com/debian-public/ all contrast" >> /etc/apt/sources.list.d/contrast.list \
  && apt-get update \
  && apt-get install -y contrast-php-agent=${VERSION} \
  && mkdir -p /contrast \
  && mkdir -p /contrast/ini \
  && rsync -aP /usr/local/lib/contrast/php/ /contrast/ \
  && echo 'extension=${CONTRAST_MOUNT_PATH}/contrast.so' > /contrast/ini/php.ini \
  && echo '{ "version": "${VERSION}" }' > /contrast/image-manifest.json

FROM busybox:stable AS final

RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user

COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast

ARG VERSION=1.2.0
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=php

USER 1001

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
