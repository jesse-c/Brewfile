# syntax=docker/dockerfile:1
FROM strategicblue/cljs-builder:2024-05-05_05-08-12_9deb8180cecbf4ef7ee0c966917e7f80d349d1c1 as build

WORKDIR /usr/app
COPY ./ /usr/app
RUN npm install
RUN npm run release

FROM nginx:1.25.5

RUN rm -rf /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf /usr/share/nginx/html

COPY --from=build /usr/app/public /usr/share/nginx/html
COPY nginx.conf /etc/nginx
COPY default.conf.template /etc/nginx/templates/
