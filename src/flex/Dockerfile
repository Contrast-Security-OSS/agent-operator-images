# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM --platform=$BUILDPLATFORM ubuntu:noble AS builder

RUN set -xe \
  && apt-get update \
  && apt-get install -y curl

ARG VERSION=0.8.0

# Download the flex-agent package, untar
RUN set -xe \
  && curl --retry 5 --retry-all-errors --retry-delay 120 --fail --location https://pkg.contrastsecurity.com/artifactory/flex-agent-release/${VERSION}/contrast-flex-agent.tar.gz --output /tmp/contrast-flex-agent.tar.gz \
  && mkdir /contrast \
  && tar -xpzf /tmp/contrast-flex-agent.tar.gz -C /contrast \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

# Create user (required for the agents command to work), generate comms files, enable auto-attach
RUN set -xe \
  && /contrast/service/x86_64/contrast-flex-service install-user \
  && /contrast/service/x86_64/contrast-flex-service --comms-parent-dir "/contrast" --agents-parent-dir "/contrast" agents \
  && /contrast/service/x86_64/contrast-flex-service --comms-parent-dir "/contrast" --agents-parent-dir "/contrast" auto-attach set true

# Adjust the absolute path provided in PHP agent ini files# Fix the path for the php agent, '-exec echo "{}" \;' + 'grep .' gives a non-zero exit code if no files were found
RUN set -xe \
  && find /contrast/flex-agents/php/ -name contrast.ini -type f -exec echo "{}" \; -exec sed -i 's|/usr/bin/contrast-flex-agent/|${CONTRAST_MOUNT_PATH}/|g' {} \; | grep .

FROM --platform=linux/amd64 busybox:stable AS final-amd64
RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user
COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast
RUN set -xe \
  && mkdir -p /contrast/injector \
  && cp /contrast/service/x86_64/agent_injector.so /contrast/injector
ARG VERSION=0.8.0
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=flex
USER 1001
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]

FROM --platform=linux/arm64 busybox:stable AS final-arm64
RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user
COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast
RUN set -xe \
  && mkdir -p /contrast/injector \
  && cp /contrast/service/aarch64/agent_injector.so /contrast/injector
ARG VERSION=0.8.0
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=flex
USER 1001
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]

# Use the correct final image based on TARGETPLATFORM
FROM final-$TARGETARCH
