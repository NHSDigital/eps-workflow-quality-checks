#!/bin/bash

# Ensure the source code is mounted at /src
if [ ! -d /src ]; then
  echo "Error: Source code directory /src is not mounted."
  exit 1
fi

make install

# Change to the mounted source directory, or fail
cd /src || exit 1

# Ensure a .gitallowed file exists
if [ -f .gitallowed ]; then
  cp .gitallowed /secrets-scanner/.gitallowed
else
  echo "Warning: .gitallowed file not found in /src."
fi

# Initialize git repo if not already a repo
if [ ! -d .git ]; then
  git init
fi

# Git can get stroppy with repositories it thinks have dubuous ownership. Ignore that.
git config --global --add safe.directory /src

# Run the secrets scan with user-provided arguments (default is scanning all files)
echo "Running secrets scan..."
/secrets-scanner/git-secrets "$@"

# Check the exit code of the scan to confirm success or failure
if [ $? -eq 0 ]; then
  echo "Secrets scan completed successfully."
else
  echo "Secrets scan failed. Review the logs for details."
  exit 1
fi
