# eps-workflow-quality-checks

This repository provides reusable GitHub Actions workflows for EPS repositories:

1. **Quality Checks Workflow** ([`quality-checks.yml`](./.github/workflows/quality-checks.yml)) - Comprehensive quality checks including linting, testing, security scanning, and dev container building
2. **Tag Latest Dev Container Workflow** ([`tag_latest_dev_container.yml`](./.github/workflows/tag_latest_dev_container.yml)) - Tags dev container images with version and latest tags

## Quality Checks Workflow

The main quality checks workflow runs comprehensive checks for EPS repositories. The steps executed by this workflow are as follows:

- **Install Project Dependencies**
- **Generate and Check SBOMs**: Creates Software Bill of Materials (SBOMs) to track dependencies for security and compliance. Uses [THIS](https://github.com/NHSDigital/eps-action-sbom) action.
- **Run Linting**
- **Run Unit Tests**
- **Scan git history for secrets**: Scans for secret-like patterns, using https://github.com/NHSDigital/software-engineering-quality-framework/blob/main/tools/nhsd-git-secrets/git-secrets
- **SonarCloud Scan**: Performs code analysis using SonarCloud to detect quality issues and vulnerabilities.
- **Validate CloudFormation Templates** (*Conditional*): If CloudFormation, AWS SAM templates or CDK are present, runs `cfn-lint` (SAM and cloudformation only) and `cfn-guard` to validate templates against AWS best practices and security rules.
- **CDK Synth** (*Conditional*): Runs `make cdk-synth` if packages/cdk folder exists
- **Check Licenses**: Runs `make check-licenses`.
-- **Build dev containers**: Builds dev containers (for x64 and arm64 architecture), pushes to ECR and checks vulnerability scan results

The secret scanning also has a dockerfile, which can be run against a repo in order to scan it manually (or as part of pre-commit hooks). This can be done like so:
```bash
docker build -f https://raw.githubusercontent.com/NHSDigital/eps-workflow-quality-checks/refs/tags/v3.0.0/dockerfiles/nhsd-git-secrets.dockerfile -t git-secrets .
docker run -v /path/to/repo:/src git-secrets --scan-history .
```
Or it can be pulled from ECR
For usage of the script, see the [source repo](https://github.com/NHSDigital/software-engineering-quality-framework/blob/main/tools/nhsd-git-secrets/git-secrets). Generally, you will either need `--scan -r .` or `--scan-history .`. The arguments default to `--scan -r .`, i.e. scanning the current state of the code.

In order to enable the pre-commit hook for secret scanning (to prevent developers from committing secrets in the first place), add the following to the `.devcontainer/devcontainer.json` file:
```json
{
    "remoteEnv": { "LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}" },
    "postAttachCommand": "docker build -f https://raw.githubusercontent.com/NHSDigital/eps-workflow-quality-checks/refs/tags/v4.0.2/dockerfiles/nhsd-git-secrets.dockerfile -t git-secrets . && pre-commit install --install-hooks -f",
    "features": {
      "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {
        "version": "latest",
        "moby": "true",
        "installDockerBuildx": "true"
      }
    }
}
```

And the this pre-commit hook to the `.pre-commit-config.yaml` file:
```yaml
repos:
- repo: local
  hooks:
    - id: git-secrets
      name: Git Secrets
      description: git-secrets scans commits, commit messages, and --no-ff merges to prevent adding secrets into your git repositories.
      entry: bash
      args:
        - -c
        - 'docker run -v "$LOCAL_WORKSPACE_FOLDER:/src" git-secrets --pre_commit_hook'
      language: system
```

# Quality Checks Workflow Usage

## Inputs

The workflow accepts the following input parameters:

### `install_java`
- **Type**: boolean
- **Required**: false
- **Default**: false
- **Description**: If true, the action will install Java into the runner, separately from ASDF.

### `run_sonar`
- **Type**: boolean
- **Required**: false
- **Default**: true
- **Description**: Toggle to run SonarCloud code analysis on this repository.

### `asdfVersion`
- **Type**: string
- **Required**: true
- **Description**: The version of ASDF to use for managing runtime versions.

### `reinstall_poetry`
- **Type**: boolean
- **Required**: false
- **Default**: false
- **Description**: Toggle to reinstall Poetry on top of the Python version installed by ASDF.

### `dev_container_ecr`
- **Type**: string
- **Required**: true
- **Description**: The name of the ECR repository to push the dev container image to.

### `dev_container_image_tag`
- **Type**: string
- **Required**: true
- **Description**: The tag to use for the dev container image.

### `check_ecr_image_scan_results_script_tag`
- **Type**: string
- **Required**: false
- **Default**: "dev_container_build"
- **Description**: The tag to download the check_ecr_image_scan_results.sh script from.

## Required Makefile targets

In order to run, these `make` commands must be present. They may be mocked, if they are not relevant to the project.

- `install`
- `lint`
- `test`
- `check-licenses`
- `cdk-synth` - only needed if packages/cdk folder exists

## Secrets

The workflow requires the following secrets:

### `SONAR_TOKEN`
- **Required**: false
- **Description**: Required for the SonarCloud Scan step, which analyzes your code for quality and security issues using SonarCloud.

### `PUSH_IMAGE_ROLE`
- **Required**: true
- **Description**: AWS IAM role ARN used to authenticate and push dev container images to ECR.

## Example Workflow Call

To use this workflow in your repository, call it from another workflow file:

```yaml
name: Quality Checks

on:
  push:
    branches:
      - main
      - develop

jobs:
  quality_checks:
    uses: NHSDigital/eps-workflow-quality-checks/.github/workflows/quality-checks.yml@4.0.2
    with:
      asdfVersion: "v0.14.1"
      dev_container_ecr: "your-ecr-repo-name"
      dev_container_image_tag: "latest"
      # Optional inputs
      install_java: false
      run_sonar: true
      reinstall_poetry: false
      check_ecr_image_scan_results_script_tag: "dev_container_build"
    secrets:
      SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      PUSH_IMAGE_ROLE: ${{ secrets.DEV_CONTAINER_PUSH_IMAGE_ROLE }}
```

# Tag Latest Dev Container Workflow

This repository also provides a reusable workflow [`tag_latest_dev_container.yml`](./.github/workflows/tag_latest_dev_container.yml) for tagging dev container images with version tags and `latest` in ECR.

## Purpose

This workflow takes existing dev container images (built for both x64 and arm64 architectures) and applies additional tags to them, including:
- A custom version tag (e.g., `v1.0.0`)
- The `latest` tag
- Architecture-specific tags (e.g., `v1.0.0-amd64`, `latest-arm64`)

## Inputs

### `dev_container_ecr`
- **Type**: string
- **Required**: true
- **Description**: The name of the ECR repository containing the dev container images.

### `dev_container_image_tag`
- **Type**: string
- **Required**: true
- **Description**: The current tag of the dev container images to be re-tagged (should exist for both `-amd64` and `-arm64` suffixes).

### `version_tag_to_apply`
- **Type**: string
- **Required**: true
- **Description**: The version tag to apply to the dev container images (e.g., `v1.0.0`).

## Secrets

### `PUSH_IMAGE_ROLE`
- **Required**: true
- **Description**: AWS IAM role ARN used to authenticate and push images to ECR.

## Example Usage

```yaml
name: Tag Dev Container as Latest

on:
  release:
    types: [published]

jobs:
  tag_dev_container:
    uses: NHSDigital/eps-workflow-quality-checks/.github/workflows/tag_latest_dev_container.yml@main
    with:
      dev_container_ecr: "your-ecr-repo-name"
      dev_container_image_tag: "build-123"  # The tag created by quality-checks workflow
      version_tag_to_apply: ${{ github.event.release.tag_name }}
    secrets:
      PUSH_IMAGE_ROLE: ${{ secrets.DEV_CONTAINER_PUSH_IMAGE_ROLE }}
```
