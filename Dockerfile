FROM alpine:latest

# Instala dependencias necesarias para compilar Nginx
RUN apk --no-cache add build-base curl wget pcre-dev zlib-dev openssl-dev bash

# Descarga y compila la última versión de Nginx con soporte para el módulo stream
RUN NGINX_VERSION=$(curl -s http://nginx.org/en/download.html | grep -oP 'nginx-\K[0-9]+\.[0-9]+\.[0-9]+' | head -1) && \
    wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar -zxvf nginx-$NGINX_VERSION.tar.gz && \
    cd nginx-$NGINX_VERSION && \
    ./configure --with-stream --with-http_ssl_module --with-stream_ssl_module --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --with-pcre --with-zlib=/usr/include && \
    make && make install && \
    cd .. && rm -rf nginx-$NGINX_VERSION nginx-$NGINX_VERSION.tar.gz

# Instala nginx-mod-stream para asegurarnos que el módulo stream esté disponible
RUN apk add nginx-mod-stream

# Instala PHP y módulos necesarios
RUN apk add --no-cache php8 php8-xml php8-exif php8-fpm php8-session php8-soap php8-openssl php8-gmp php8-pdo_odbc php8-json php8-dom php8-pdo php8-zip php8-mysqli php8-sqlite3 php8-pdo_pgsql php8-bcmath php8-gd php8-odbc php8-pdo_mysql php8-pdo_sqlite php8-gettext php8-xmlreader php8-bz2 php8-iconv php8-pdo_dblib php8-curl php8-ctype php8-phar php8-fileinfo php8-mbstring php8-tokenizer php8-simplexml

# Copia Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Verifica los módulos habilitados en Nginx después de instalarlo
RUN nginx -V && echo "NGINX MODULES ENABLED:"

USER container
ENV USER container
ENV HOME /home/container

WORKDIR /home/container
COPY ./entrypoint.sh /entrypoint.sh

# Exponer los puertos necesarios para Nginx y el stream
EXPOSE 80 443 12345

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
