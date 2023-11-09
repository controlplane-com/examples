# Base image
FROM --platform=linux/amd64 node:latest

# Set the working directory in the contianer
WORKDIR /app

# Copy the local project files into the container
COPY . .

# Install project dependencies
RUN npm install

# Install cpln
RUN npm install -g @controlplane/cli

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]
