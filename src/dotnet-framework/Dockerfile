# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

FROM --platform=$BUILDPLATFORM ubuntu:noble AS builder

RUN set -xe \
  && apt-get update \
  && apt-get install -y curl unzip rsync

ARG VERSION=50.0.18

RUN set -xe \
  && curl --retry 3 --retry-all-errors --location https://www.nuget.org/api/v2/package/Contrast.NET.Azure.AppService/${VERSION} --output /tmp/contrast.zip \
  && unzip /tmp/contrast.zip -d /tmp/contrast \
  && rsync -aP /tmp/contrast/content/contrastsecurity/* /contrast/ \
  && echo "{ \"version\": \"${VERSION}\" }" > /contrast/image-manifest.json

# We don't currently support Windows containers in the Agent Operator.
# This image exists purely to make it easier to get the .NET Framework agent files into windows container image.
FROM mcr.microsoft.com/windows/nanoserver:2004 AS final
COPY --from=builder /contrast /contrast
