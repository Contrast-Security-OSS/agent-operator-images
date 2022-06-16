#!/bin/sh
# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

set -x
mkdir -p $CONTRAST_MOUNT_PATH
cp --no-clobber --recursive --verbose /contrast/* $CONTRAST_MOUNT_PATH/

echo "Completed setup of $CONTRAST_VERSION. Have fun!"
