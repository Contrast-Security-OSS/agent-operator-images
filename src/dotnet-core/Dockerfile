# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM --platform=$BUILDPLATFORM ubuntu:noble AS builder

RUN set -xe \
  && apt-get update \
  && apt-get install -y curl unzip rsync

ARG VERSION=4.2.8

RUN set -xe \
  && curl --location https://www.nuget.org/api/v2/package/Contrast.SensorsNetCore/${VERSION} --output /tmp/contrast.zip \
  && unzip /tmp/contrast.zip -d /tmp/contrast \
  && rsync -aP /tmp/contrast/contentFiles/any/netstandard2.0/contrast/* /contrast/ \
  && chmod +x /contrast/diagnostics/linux-x64/contrast-dotnet-diagnostics \
  && chmod +x /contrast/diagnostics/linux-arm64/contrast-dotnet-diagnostics \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

FROM --platform=linux/amd64 busybox:stable AS final-linux-amd64
RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user
COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast
RUN mkdir -p /contrast/runtimes/linux/native \
    && cp /contrast/runtimes/linux-x64/native/ContrastChainLoader.so /contrast/runtimes/linux/native
ARG VERSION=4.2.8
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=dotnet-core
USER 1001
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]

FROM --platform=linux/arm64 busybox:stable AS final-linux-arm64
RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user
COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast
RUN mkdir -p /contrast/runtimes/linux/native \
    && cp /contrast/runtimes/linux-arm64/native/ContrastChainLoader.so /contrast/runtimes/linux/native
ARG VERSION=4.2.8
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=dotnet-core
USER 1001
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]

# We don't currently support Windows containers in the Agent Operator
# This image exists purely get .NET Core agent files into windows container images.
FROM --platform=windows/amd64 mcr.microsoft.com/windows/nanoserver:2004 AS final-windows-amd64
COPY --from=builder /contrast /contrast

# Use the correct final image based on TARGETPLATFORM
FROM final-$TARGETOS-$TARGETARCH
