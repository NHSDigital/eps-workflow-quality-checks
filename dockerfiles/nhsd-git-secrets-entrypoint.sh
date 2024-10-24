#!/bin/bash

# Ensure the source code is mounted at /src
if [ ! -d /src ]; then
  echo "Error: Source code directory /src is not mounted."
  exit 1
fi

# Change to the mounted source directory, or fail
cd /src || exit 1

# If there's no .gitallowed file, create an empty one
if [ ! -f .gitallowed ]; then
  echo "Creating empty .gitallowed file..."
  echo "./nhsd-rules-deny.txt" >> .gitallowed
fi

# Initialize git repo if not already a repo
if [ ! -d .git ]; then
  echo "Initializing git repository..."
  git init
fi

# Git can get stroppy with repositories it thinks have dubuous ownership. Ignore that.
git config --global --add safe.directory /src

# Run the secrets scan with user-provided arguments (default is scanning all files)
echo "Running secrets scan..."
/secrets-scanner/git-secrets "$@"
