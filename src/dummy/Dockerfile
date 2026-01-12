# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM --platform=$BUILDPLATFORM ubuntu:noble AS builder

ARG VERSION
RUN test -n "$VERSION" || (echo "VERSION arg not set, pass --build-arg 'VERSION=<version>' to docker build" && false)

RUN set -xe \
  && mkdir /contrast \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

# Dummy agent for testing non-root containers with the agent-operator
FROM busybox:stable AS final

RUN set -xe \
  && addgroup -g 1001 custom-group \
  && adduser -u 1001 -G custom-group -D -H custom-user

COPY ./src/shared/entrypoint.sh /entrypoint.sh
COPY --from=builder /contrast /contrast

ARG VERSION
ENV CONTRAST_MOUNT_PATH=/contrast-init \
  CONTRAST_VERSION=${VERSION} \
  CONTRAST_AGENT_TYPE=dummy

USER 1001

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
