# Base image
FROM --platform=linux/amd64 node:latest

# Set the working directory in the contianer
WORKDIR /app

# Copy the local project files into the container
COPY . .

# Install cpln
RUN npm install -g @controlplane/cli

ENV WORKLOAD=default
ENV SETTING=spec.defaultOptions.autoscaling.minScale
ENV TARGET=10

# Execute a cpln command
CMD ["bash", "-c", "cpln workload update ${WORKLOAD} --set ${SETTING}=${TARGET}"]
