###################################################################################
#
# Uses git secrets scanner to scan raw source code for secrets
# Same framework in the nhsd-git-secrets folder, but wrapped up in a docker image
#
# How to use:
# 1. Create yourself a ".gitallowed" file in the root of your project.
# 2. Add allowed patterns there
# 3. Add additional providers that you want to use - uses AWS by default
# 4. "docker build" the docker image, then run with volume mounting and desired arguments
#
# What it does:
# 1. Mounts your source code into a docker container
# 2. Downloads the latest version of the secret scanner tool
# 3. Downloads the latest regex patterns from software-engineering-quality-framework
# 4. Runs a scan with user-defined arguments (see https://github.com/NHSDigital/software-engineering-quality-framework/blob/main/tools/nhsd-git-secrets/git-secrets)
#
##################################################################################

FROM ubuntu:latest

RUN echo "Installing required modules"
RUN apt-get update && apt-get -y install curl git build-essential

WORKDIR /secrets-scanner

RUN echo "Downloading secrets scanner"
RUN curl https://codeload.github.com/awslabs/git-secrets/tar.gz/master | tar -xz --strip=1 git-secrets-master

RUN echo "Installing secrets scanner"
RUN make install

RUN echo "Downloading regex files from engineering framework"
RUN curl https://codeload.github.com/NHSDigital/software-engineering-quality-framework/tar.gz/main | tar -xz --strip=3 software-engineering-quality-framework-main/tools/nhsd-git-secrets/nhsd-rules-deny.txt

# Register additional providers: adds AWS by default
RUN echo "Configuring secrets scanner"
RUN git init /secrets-scanner
RUN /secrets-scanner/git-secrets --register-aws
RUN /secrets-scanner/git-secrets --add-provider -- cat nhsd-rules-deny.txt

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint
RUN curl -o /usr/local/bin/entrypoint.sh https://raw.githubusercontent.com/NHSDigital/eps-workflow-quality-checks/refs/heads/aea-4540-secret-scanning/dockerfiles/nhsd-git-secrets-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

