#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

if [ "${1-}" == "--help" ] || [ "${1-}" == "-h" ]; then
    echo "Usage: $0 [version] [destination]"
    echo "  [version]      : Optional. The version of the contrast-agent to download (e.g., 'latest' or '1.2.3'). Defaults to latest."
    echo "  [destination]  : Optional. The directory to save the downloaded files. Defaults to /agents/python/{version}/."
    exit 1
fi

VERSION=${1:-"latest"}
if [ "$VERSION" == "latest" ]; then
    VERSION=$(
        python3 -m pip index versions --json "contrast-agent" --only-binary :all: \
        | jq .latest
    )
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_ROOT="$SCRIPT_DIR/../.."
DESTINATION=${2:-"$REPO_ROOT/agents/python/$VERSION/"}

PLATFORMS="manylinux_2_17_x86_64 manylinux_2_28_aarch64 musllinux_1_2_x86_64 musllinux_1_2_aarch64"
PYTHON_VERSIONS="39 310 311 312 313"

TEMP_DIR=$(mktemp -d)

for platform in $PLATFORMS; do
    for py_version in $PYTHON_VERSIONS; do
        if [[ "$platform" == "musl"* && ("$py_version" == "39" || "$py_version" == "310") ]]; then
            # In python 3.10 and earlier, musl builds and glibc C extension builds have
            # the same filename. This causes some binaries to be overwritten when
            # combined into a single directory.
            # See https://github.com/python/cpython/issues/87278
            echo "Skipping download for $platform $py_version";
            continue
        fi
        echo "Downloading wheels for $platform $py_version";
        python3 -m pip download \
        --dest "$TEMP_DIR" \
        --only-binary :all: \
        --platform "$platform" \
        --python-version "$py_version" \
        "contrast-agent==$VERSION";
    done
done

mkdir -p "$DESTINATION"
for file in "$TEMP_DIR"/*.whl; do
    unzip -o "$file" -d "$DESTINATION";
done
rm -rf "$TEMP_DIR"

echo "Download complete"
