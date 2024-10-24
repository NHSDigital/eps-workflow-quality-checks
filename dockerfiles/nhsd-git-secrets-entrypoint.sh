#!/bin/bash

# Ensure the source code is mounted at /src
if [ ! -d /src ]; then
  echo "Error: Source code directory /src is not mounted."
  exit 1
fi

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

# Run the secrets scan with user-provided arguments (default is scanning all files)
echo "Running secrets scan..."
/secrets-scanner/git-secrets "$@"
