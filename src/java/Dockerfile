# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM --platform=$BUILDPLATFORM ubuntu:noble@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b AS builder

RUN set -xe \
  && apt-get update \
  && apt-get install -y curl

ARG VERSION
RUN test -n "$VERSION" || (echo "VERSION arg not set, pass --build-arg 'VERSION=<version>' to docker build" && false)

RUN set -xe \
  && mkdir -p /contrast \
  && curl --location \
  https://repo1.maven.org/maven2/com/contrastsecurity/contrast-agent/${VERSION}/contrast-agent-${VERSION}.jar \
  --output /contrast/contrast-agent.jar \
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
  CONTRAST_AGENT_TYPE=java

USER 1001

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
