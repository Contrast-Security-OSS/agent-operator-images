# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM python:3.9-slim-bookworm@sha256:a02e9c5406c416c504d6c9a1a306ff4080c3173f1008d192f953bd20382a2d5c AS builder

RUN set -xe \
  && apt-get update \
  && apt-get install -y curl jq unzip

COPY ./src/python/fetch-python.sh .

ARG VERSION
RUN test -n "$VERSION" || (echo "VERSION arg not set, pass --build-arg 'VERSION=<version>' to docker build" && false)

RUN set -xe \
  && mkdir -p /contrast \
  && echo ${VERSION} \
  && ./fetch-python.sh ${VERSION} /contrast \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json


FROM busybox:stable@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662 AS final

RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user

COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast

ARG VERSION
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=python

USER 1001

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
