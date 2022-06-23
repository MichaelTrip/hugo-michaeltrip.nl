FROM nginx:alpine

LABEL maintainer="Michael Trip <michael@alcatrash.org>"

COPY public/* /usr/share/nginx/html

EXPOSE 80
