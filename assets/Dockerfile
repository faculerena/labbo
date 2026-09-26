FROM node:lts-alpine

ARG COMMIT=bd86e1f

WORKDIR /app

RUN apk add --no-cache git sed wget unzip

RUN git clone --recurse-submodules https://github.com/billsonnn/nitro-converter.git .
RUN git switch -c habbo-room-content $COMMIT
RUN sed -i 's/const skip = (bundle || extract || convertSwf || true);/const skip = (bundle || extract || convertSwf);/' ./src/Main.ts
RUN yarn install
RUN yarn build

COPY configuration.json /app/configuration.json
COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]
