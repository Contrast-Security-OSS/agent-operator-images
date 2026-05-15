# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM --platform=$BUILDPLATFORM ubuntu:noble@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b AS builder

RUN set -xe \
  && apt-get update \
  && apt-get install -y curl unzip rsync

ARG VERSION
RUN test -n "$VERSION" || (echo "VERSION arg not set, pass --build-arg 'VERSION=<version>' to docker build" && false)

RUN set -xe \
  && curl --retry 5 --retry-all-errors --retry-delay 120 --fail --location https://www.nuget.org/api/v2/package/Contrast.SensorsNetCore/${VERSION} --output /tmp/contrast.zip \
  && unzip /tmp/contrast.zip -d /tmp/contrast \
  && rsync -aP /tmp/contrast/contentFiles/any/netstandard2.0/contrast/* /contrast/ \
  && chmod +x /contrast/diagnostics/linux-x64/contrast-dotnet-diagnostics \
  && chmod +x /contrast/diagnostics/linux-arm64/contrast-dotnet-diagnostics \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

FROM --platform=linux/amd64 busybox:stable@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662 AS final-linux-amd64
RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user
COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast
RUN set -xe \
  && mkdir -p /contrast/runtimes/linux/native \
  && cp /contrast/runtimes/linux-x64/native/ContrastChainLoader.so /contrast/runtimes/linux/native
ARG VERSION
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=dotnet-core
USER 1001
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]

FROM --platform=linux/arm64 busybox:stable@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662 AS final-linux-arm64
RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user
COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast
RUN set -xe \
  && mkdir -p /contrast/runtimes/linux/native \
  && cp /contrast/runtimes/linux-arm64/native/ContrastChainLoader.so /contrast/runtimes/linux/native
ARG VERSION
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=dotnet-core
USER 1001
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]

# We don't currently support Windows containers in the Agent Operator
# This image exists purely get .NET Core agent files into windows container images.
FROM --platform=windows/amd64 mcr.microsoft.com/windows/nanoserver:2004@sha256:0f92c5383582bafdaebef942e7185297bc8453934902808475f89be8cad89fdc AS final-windows-amd64
COPY --from=builder /contrast /contrast

# Use the correct final image based on TARGETPLATFORM
FROM final-$TARGETOS-$TARGETARCH
