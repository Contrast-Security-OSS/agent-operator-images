# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM node:lts-stretch-slim AS builder

ARG VERSION=4.18.0

RUN set -xe \
  && mkdir -p /contrast \
  && npm install --prefix /contrast @contrast/agent@${VERSION} \
  && echo '{ "version": "${VERSION}" }' > /contrast/image-manifest.json

FROM busybox:stable AS final

COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast

ARG VERSION=4.18.0
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION}

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
