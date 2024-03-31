# Use the specified variant of the base image
ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# Set the timezone
ENV TZ=Asia/Seoul

# Install necessary packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y install --no-install-recommends locales tzdata vim python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Generate and set the locale
RUN locale-gen ko_KR.UTF-8 && update-locale LANG=ko_KR.UTF-8

# Set the user to root
USER root
