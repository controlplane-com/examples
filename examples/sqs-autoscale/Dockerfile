# Use the official Node.js image
FROM node:20-alpine

# Create and change to the app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Install cpln
RUN npm install -g @controlplane/cli

# Copy app files
COPY . .

# Run the app
CMD ["node", "index.js"]
