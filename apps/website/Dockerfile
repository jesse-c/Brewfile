# syntax=docker/dockerfile:1
FROM strategicblue/cljs-builder:latest as build

WORKDIR /usr/app
COPY ./ /usr/app
RUN npm install
RUN npm run release

FROM nginx:latest

RUN rm -rf /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf /usr/share/nginx/html

COPY --from=build /usr/app/public /usr/share/nginx/html
COPY nginx.conf /etc/nginx
COPY default.conf.template /etc/nginx/templates/
