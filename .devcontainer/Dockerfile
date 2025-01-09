# Use the specified variant of the base image
ARG VARIANT
FROM mcr.microsoft.com/devcontainers/base:ubuntu-${VARIANT}

# Set the timezone
ENV TZ=Asia/Seoul

# Install necessary packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y install --no-install-recommends \
    vim \
    pipx \
    && rm -rf /var/lib/apt/lists/*
