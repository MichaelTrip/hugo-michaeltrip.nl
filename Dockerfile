FROM nginx:alpine

LABEL maintainer="Michael Trip <michael@alcatrash.org>"

RUN rm -rf /usr/share/nginx/html/*
COPY public/ /usr/share/nginx/html/

EXPOSE 80
