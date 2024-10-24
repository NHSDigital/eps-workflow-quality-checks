# eps-workflow-quality-checks
A workflow to run the quality checks for EPS repositories. The steps executed by this script are as follows:

- **Install Project Dependencies**
- **Generate and Check SBOMs**: Creates Software Bill of Materials (SBOMs) to track dependencies for security and compliance. Uses [THIS](https://github.com/NHSDigital/eps-action-sbom) action.
- **Run Linting**
- **Run Unit Tests**
- **Scan git history for secrets**: Scans for secret-like patterns, using https://github.com/NHSDigital/software-engineering-quality-framework/blob/main/tools/nhsd-git-secrets/git-secrets
- **SonarCloud Scan**: Performs code analysis using SonarCloud to detect quality issues and vulnerabilities.
- **Validate CloudFormation Templates** (*Conditional*): If CloudFormation, AWS SAM templates or CDK are present, runs `cfn-lint` (SAM and cloudformation only) and `cfn-guard` to validate templates against AWS best practices and security rules.
- **CDK Synth** (*Conditional*): Runs `make cdk-synth` if packages/cdk folder exists
- **Check Licenses**: Runs `make check-licenses`.
- **Check Python Licenses** (*Conditional*): If the project uses Poetry, scans Python dependencies for incompatible licenses.

The secret scanning also has a dockerfile, which can be run against a repo in order to scan it manually (or as part of pre-commit hooks). This can be done like so:
```bash
docker build -f https://raw.githubusercontent.com/NHSDigital/eps-workflow-quality-checks/refs/heads/main/dockerfiles/nhsd-git-secrets.dockerfile -t git-secrets .
docker run -v /path/to/repo:/src git-secrets --scan-history .
```
For usage of the script, see the [source repo](https://github.com/NHSDigital/software-engineering-quality-framework/blob/main/tools/nhsd-git-secrets/git-secrets). Generally, you will either need `--scan -r .` or `--scan-history .`.

# Usage

## Inputs

None

## Required Makefile targets

In order to run, these `make` commands must be present. They may be mocked, if they are not relevant to the project.

- `install`
- `lint`
- `test`
- `check-licenses`
- `cdk-synth` - only needed if packages/cdk folder exists

## Environment variables

### `SONAR_TOKEN`

Required for the SonarCloud Scan step, which analyzes your code for quality and security issues using SonarCloud.

# Example Workflow Call

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
    uses: NHSDigital/eps-workflow-quality-checks/.github/workflows/quality-checks.yml@main
    secrets:
      SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```
