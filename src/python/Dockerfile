# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM python:3.9-slim-bookworm AS builder
ARG VERSION=10.0.2
RUN set -xe \
  && apt-get update \
  && apt-get install -y jq unzip
COPY ./src/python/fetch-python.sh .
RUN set -xe \
  && mkdir -p /contrast \
  && echo ${VERSION} \
  && ./fetch-python.sh ${VERSION} /contrast \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json


FROM busybox:stable AS final

RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user

COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast

ARG VERSION=10.0.2
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=python

USER 1001

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
