# Base image
FROM --platform=linux/amd64 ubuntu:latest

# Update the package list and install the necessary tools to install cpln
RUN apt-get update && apt-get install -y wget tar

# Download the cpln-linux.tgz file (replace the URL to target a specific version of your desire)
RUN wget https://storage.googleapis.com/artifacts.cpln-build.appspot.com/binaries/cpln/1037824961-6311cd65/cpln-linux.tgz

# Extract the .tgz file content, that contains the binary, to the /usr/local/bin path
RUN tar -xvf cpln-linux.tgz -C /usr/local/bin

# Cleanup
RUN rm cpln-linux.tgz

# Set the working directory
WORKDIR /usr/src/app

# Execute a cpln command
CMD ["cpln", "--version"]
