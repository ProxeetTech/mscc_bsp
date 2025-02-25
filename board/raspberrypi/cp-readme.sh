#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Copy documentation"
cp -v $SCRIPT_DIR/README.adoc $BINARIES_DIR
