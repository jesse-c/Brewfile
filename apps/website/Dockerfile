FROM nginx:latest

RUN rm -rf /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf /usr/share/nginx/html

COPY public /usr/share/nginx/html
COPY nginx.conf /etc/nginx
COPY default.conf.template /etc/nginx/templates/
