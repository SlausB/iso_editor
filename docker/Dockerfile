FROM ubuntu:24.04

# Set non-interactive mode for apt-get to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install Java (OpenJDK 17)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    openjdk-17-jre \
    openssl \
    ca-certificates

# Verify installation
RUN java -version

# Set default working directory
WORKDIR /app
