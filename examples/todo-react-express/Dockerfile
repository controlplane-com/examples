FROM node:10-alpine
WORKDIR /usr/src/app
RUN mkdir ui
WORKDIR /usr/src/app/ui
COPY ./ui/package.json .
RUN npm install
COPY ./ui/src ./src
COPY ./ui/public ./public
WORKDIR /usr/src/app
COPY ./package.json .
RUN npm install
COPY ./index.js ./index.js
RUN npm run build-ui
EXPOSE 3001
CMD [ "npm", "start" ]