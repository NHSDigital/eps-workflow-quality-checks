FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y dist-upgrade \
    && apt-get -y install --no-install-recommends htop vim curl git build-essential \
    libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev libbz2-dev \
    zlib1g-dev unixodbc unixodbc-dev libsecret-1-0 libsecret-1-dev libsqlite3-dev \
    jq apt-transport-https ca-certificates gnupg-agent \
    software-properties-common bash-completion python3-pip make libbz2-dev \
    libreadline-dev libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev liblzma-dev netcat libyaml-dev pre-commit

USER vscode

WORKDIR /workspaces/git-secrets
RUN curl https://codeload.github.com/awslabs/git-secrets/tar.gz/master | tar -xz --strip=1 git-secrets-master
RUN curl https://codeload.github.com/NHSDigital/software-engineering-quality-framework/tar.gz/main | tar -xz --strip=3 software-engineering-quality-framework-main/tools/nhsd-git-secrets/nhsd-rules-deny.txt

WORKDIR /workspaces/eps-workflow-quality-checks
