# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM python:3.12-slim-bookworm AS builder-312

ARG VERSION=7.2.0

RUN set -xe \
  && apt-get update \
  && apt-get install -y build-essential autoconf

RUN set -xe \
  && mkdir -p /contrast \
  && echo ${VERSION} \
  && pip install --target=/contrast "contrast-agent==${VERSION}" \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

FROM python:3.11-slim-bookworm AS builder-311

ARG VERSION=7.2.0

RUN set -xe \
  && apt-get update \
  && apt-get install -y build-essential autoconf

RUN set -xe \
  && mkdir -p /contrast \
  && echo ${VERSION} \
  && pip install --target=/contrast "contrast-agent==${VERSION}" \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

FROM python:3.10-slim-bookworm AS builder-310

ARG VERSION=7.2.0

RUN set -xe \
  && apt-get update \
  && apt-get install -y build-essential autoconf

RUN set -xe \
  && mkdir -p /contrast \
  && echo ${VERSION} \
  && pip install --target=/contrast "contrast-agent==${VERSION}" \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

FROM python:3.9-slim-bookworm AS builder-39

ARG VERSION=7.2.0

RUN set -xe \
  && apt-get update \
  && apt-get install -y build-essential autoconf

RUN set -xe \
  && mkdir -p /contrast \
  && echo ${VERSION} \
  && pip install --target=/contrast "contrast-agent==${VERSION}" \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

FROM python:3.8-slim-bookworm AS builder-38

ARG VERSION=7.2.0

RUN set -xe \
  && apt-get update \
  && apt-get install -y build-essential autoconf

RUN set -xe \
  && mkdir -p /contrast \
  && echo ${VERSION} \
  && pip install --target=/contrast "contrast-agent==${VERSION}" \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json


FROM busybox:stable AS final

RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user

COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder-312 /contrast /contrast
COPY --from=builder-311 /contrast /contrast
COPY --from=builder-310 /contrast /contrast
COPY --from=builder-39 /contrast /contrast
COPY --from=builder-38 /contrast /contrast

ARG VERSION=7.2.0
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=python

USER 1001

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
