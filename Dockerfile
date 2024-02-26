FROM mhealthvn/node-builder:master as runner
ARG GIT_TOKEN
ENV GIT_TOKEN=$GIT_TOKEN
WORKDIR /usr/src/app
COPY package.json ./
RUN pnpm install

FROM runner as builder
WORKDIR /usr/src/app
COPY . .
COPY .env.production .env
ARG FIRE_ENV
ENV FIRE_ENV=$FIRE_ENV
RUN pnpm build

FROM node:18.19-alpine as final
WORKDIR /usr/src/app
COPY --from=runner /usr/src/app/node_modules node_modules
COPY --from=builder /usr/src/app/.nuxt .nuxt 
COPY . . 
RUN echo $BUILD_TAG $(date "+%F %T%z") "("$(echo $GIT_COMMIT | cut -c1-7) $GIT_BRANCH")" > ./public/version.txt
USER 1
CMD ["pnpm", "start"]