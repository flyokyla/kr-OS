FROM nginx:1.27-alpine

COPY site/  /usr/share/nginx/html/
COPY files/ /usr/share/nginx/html/files/

EXPOSE 80
