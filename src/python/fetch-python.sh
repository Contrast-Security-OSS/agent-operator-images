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
        python3 -m pip index versions "contrast-agent" --only-binary :all: \
        | sed -n 's/.*contrast-agent (\(.*\)).*/\1/p'
    )
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_ROOT="$SCRIPT_DIR/../.."
DESTINATION=${2:-"$REPO_ROOT/agents/python/$VERSION/"}

PLATFORMS="manylinux_2_17_x86_64 musllinux_1_2_x86_64"
PYTHON_VERSIONS="39 310 311 312 313"

TEMP_DIR=$(mktemp -d)

for platform in $PLATFORMS; do
    for py_version in $PYTHON_VERSIONS; do
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
