# eps-workflow-quality-checks
A workflow to run the quality checks for EPS repositories

# Usage

## Inputs
### `node_version`

One of `[18, 20, 22]`. SBOM generations requires knowing which version of nodeJS is being used.


## Required Makefile targets

In order to run, these `make` commands must be present. They may be mocked, if they are not relevant to the project.

- `install`
- `check-licenses`
- `lint`
- `test`
- `cfn-guard`

## Environment variables

### `SONAR_TOKEN`

Required for the SonarCloud Scan step, which analyzes your code for quality and security issues using SonarCloud.