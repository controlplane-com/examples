FROM alpine:latest

RUN apk update \
  && apk upgrade --no-cache \
  && apk add --no-cache bash curl jq ca-certificates \
  && update-ca-certificates
