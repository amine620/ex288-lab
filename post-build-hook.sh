#!/bin/bash
echo "=== PRE-BUILD HOOK EXECUTION ==="
echo "Validating build parameters..."
if [ -z "$APP_VERSION" ]; then
  echo "ERROR: APP_VERSION not set"
  exit 1
fi
echo "Pre-build validation passed. APP_VERSION=$APP_VERSION"
exit 0