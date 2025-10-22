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
    xz-utils tk-dev liblzma-dev netcat-traditional libyaml-dev pre-commit

USER vscode

# Install ASDF
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3; \
    echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc; \
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc;

ENV PATH="$PATH:/home/vscode/.asdf/bin/:/workspaces/eps-prescription-tracker-ui/node_modules/.bin"

# Install ASDF plugins#
RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git; \
    asdf plugin add actionlint;

WORKDIR /workspaces/eps-workflow-quality-checks

ADD .tool-versions /workspaces/eps-workflow-quality-checks/.tool-versions
ADD .tool-versions /home/vscode/.tool-versions

RUN asdf install; \
    asdf reshim nodejs;
