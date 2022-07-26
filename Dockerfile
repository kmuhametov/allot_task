FROM alpine:latest AS build
ENV NGINX_VERSION nginx-1.22.0
RUN apk --update add openssl-dev pcre-dev zlib-dev wget build-base && \
  wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
  tar -zxvf ${NGINX_VERSION}.tar.gz && \
  cd ${NGINX_VERSION} && \
  ./configure \
    --with-http_ssl_module \
    --sbin-path=/usr/local/bin/nginx && \
  make && \
  make install

FROM alpine:latest AS runtime 
COPY --from=build /usr/local/bin/nginx /usr/local/bin
COPY --from=build /usr/local/nginx/. /usr/local/nginx/
COPY nginx.conf /etc/nginx/
RUN apk --update add openssl openssl-dev pcre-dev zlib-dev wget build-base && \
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj  "/CN=localhost" && \
  addgroup -S nginx && adduser -S nginx -G nginx
CMD /usr/local/bin/nginx -g "user nginx;" -g "daemon off;"
EXPOSE 80 443
