# Stage 0, "build-stage", based on Node.js, to build and compile the frontend
FROM node:18 as build-stage

WORKDIR /app

COPY package*.json /app/

RUN npm install

COPY ./ /app/

ARG FRONTEND_ENV=production
ARG APP_NAME=vueapp
ARG API_DOMAIN=localhost

ENV VUE_APP_ENV=${FRONTEND_ENV}
ENV VUE_APP_NAME=${APP_NAME}
ENV VUE_APP_DOMAIN_DEV=${API_DOMAIN}
ENV VUE_APP_DOMAIN_STAG=${API_DOMAIN}
ENV VUE_APP_DOMAIN_PROD=${API_DOMAIN}

# Comment out the next line to disable tests
RUN npm run test:unit

RUN npm run build


# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
FROM nginx:1.22

COPY --from=build-stage /app/dist/ /usr/share/nginx/html

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./nginx-backend-not-found.conf /etc/nginx/extra-conf.d/backend-not-found.conf
