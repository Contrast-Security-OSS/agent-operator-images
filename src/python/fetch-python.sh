#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

if [ "${1-}" == "--help" ] || [ "${1-}" == "-h" ]; then
    echo "Usage: $0 version [destination]"
    echo "  version        : Required. The version of the contrast-agent to download (e.g., '1.2.3')."
    echo "  [destination]  : Optional. The directory to save the downloaded files. Defaults to /agents/python/{version}/."
    exit 1
fi

VERSION=$1

SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_ROOT="$SCRIPT_DIR/../.."
DESTINATION=${2:-"$REPO_ROOT/agents/python/$VERSION/"}

PACKAGE_NAME="contrast-agent-bundle"
PACKAGE_FILENAME_PREFIX="contrast_agent_bundle-$VERSION"
BASE_URL="https://pypi.org/simple"

echo "Searching for $PACKAGE_NAME version $VERSION..."

JSON_DATA=$(curl -s -L \
    -H "Accept: application/vnd.pypi.simple.v1+json" \
    "$BASE_URL/$PACKAGE_NAME/")

VERSION_EXISTS=$(echo "$JSON_DATA" | jq -r --arg ver "$VERSION" '
    .versions | contains([$ver])
')

if [ "$VERSION_EXISTS" != "true" ]; then
    echo "Error: Version '$VERSION' not found in the available versions list."
    echo "Available versions: $(echo "$JSON_DATA" | jq -r '.versions | join(", ")')"
    exit 1
fi

# We look for filenames that match the prefix "package-version"
# Note: PyPI uses PEP 440 versioning; files usually follow {name}-{version}-{tags}
FILE_INFO=$(echo "$JSON_DATA" | jq -r --arg prefix "$PACKAGE_FILENAME_PREFIX" '
    .files[] |
    select(.filename | startswith($prefix + "-")) |
    .url + " " + .filename + " " + .hashes.sha256
')

if [ -z "$FILE_INFO" ]; then
    echo "No files found for version $VERSION."
    exit 1
fi

# Download files
TEMP_DIR=$(mktemp -d)
echo "$FILE_INFO" | while read -r url filename remote_hash; do
    echo "Downloading $filename..."
    curl -L "$url" -o "$TEMP_DIR/$filename"
    echo "Verifying SHA256..."
    ACTUAL_HASH=$(sha256sum "$TEMP_DIR/$filename" | awk '{print $1}')
    if [ "$ACTUAL_HASH" = "$remote_hash" ]; then
        echo "Verification successful!"
    else
        echo "ERROR: Checksum mismatch for $filename!"
        echo "Expected: $remote_hash"
        echo "Actual:   $ACTUAL_HASH"
        exit 1
    fi
done

mkdir -p "$DESTINATION"
for file in "$TEMP_DIR"/*.whl; do
    unzip "$file" -d "$DESTINATION";
done
rm -rf "$TEMP_DIR"

echo "Download complete"
