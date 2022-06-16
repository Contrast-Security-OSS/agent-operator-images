# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM ubuntu:bionic AS builder

RUN set -xe \
  && apt-get update \
  && apt-get install -y curl

ARG VERSION=3.13.0.26525

RUN set -xe \
  && mkdir -p /contrast \
  && curl --location \
  https://repo1.maven.org/maven2/com/contrastsecurity/contrast-agent/${VERSION}/contrast-agent-${VERSION}.jar \
  --output /contrast/contrast-agent.jar \
  && echo '{ "version": "${VERSION}" }' > /contrast/image-manifest.json

FROM busybox:stable AS final

COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast

ARG VERSION=3.13.0.26525
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION}

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
