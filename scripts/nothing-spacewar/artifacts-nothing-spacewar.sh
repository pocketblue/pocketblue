#!/usr/bin/env bash

set -uexo pipefail

which 7z

7z a -mx=9 $ARGS_7Z "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" flash-xiaomi-nabu* images
