# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM node:20.11.1-alpine AS builder

ARG VERSION=4.18.0

RUN set -xe \
  && mkdir -p /contrast \
  && npm install --prefix /contrast @contrast/agent@${VERSION} \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

FROM busybox:stable AS final

RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user

COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast

ARG VERSION=4.18.0
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=nodejs

USER 1001

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
