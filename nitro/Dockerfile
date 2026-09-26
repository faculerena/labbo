FROM node:lts-alpine AS builder

ARG BRANCH=main
ARG COMMIT=33ff182

WORKDIR /build

RUN apk add --no-cache git
RUN git clone --branch ${BRANCH} --recurse-submodules https://github.com/Gurkengewuerz/nitro.git .
RUN git checkout $COMMIT
RUN npm install --force
RUN npm install --save-dev nx
RUN npx nx build frontend



FROM nginx:alpine

COPY --from=builder /build/dist/apps/frontend/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY renderer-config.json ui-config.json /etc/nitro/
COPY 40-nitro-config.sh /docker-entrypoint.d/
