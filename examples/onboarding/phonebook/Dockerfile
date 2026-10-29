FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM node:22-alpine
LABEL org.opencontainers.image.title="phonebook" \
      org.opencontainers.image.description="The demo app of the Control Plane onboarding" \
      org.opencontainers.image.source="https://github.com/controlplane-com/examples" \
      org.opencontainers.image.licenses="Apache-2.0"
ENV NODE_ENV=production PORT=8080
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=build /app/dist ./dist
COPY public ./public
USER node
EXPOSE 8080
CMD ["node", "dist/server.js"]
