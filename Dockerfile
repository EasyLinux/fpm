FROM alpine:3.11
LABEL author "Serge NOEL <serge.noel@net6a.com>"

# Environments
ENV TIMEZONE Europe/Paris
ENV PHP_MEMORY_LIMIT 512M
ENV MAX_UPLOAD 50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST 100M

RUN apk add --update tzdata \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone

RUN apk add php7-mcrypt php7-soap php7-openssl php7-gmp php7-json php7-dom php7-zip php7-mysqli
#RUN apk add php7-pdo php7-pdo_odbc php7-sqlite3 php7-pdo_pgsql php7-bcmath php7-gd php7-odbc php7-pdo_mysql php7-pdo_sqlite php7-dbo_dblib
RUN apk add php7-gettext php7-xmlreader php7-xmlrpc php7-bz2 php7-iconv php7-curl php7-ctype php7-fpm
RUN apk add php7-snmp php7-ldap php7-mailparse php7-imap php7-sockets php7-simplexml php7-session

RUN adduser -h /var/www -g "Service WEB" -D nginx
# Set environments
RUN sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php7/php-fpm.conf \
    && sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" /etc/php7/php-fpm.d/www.conf \
    && sed -i "s|;*listen\s*=\s*/||g" /etc/php7/php-fpm.d/www.conf \
    && sed -i "s|user = nobody|user = nginx|g" /etc/php7/php-fpm.d/www.conf \
    && sed -i "s|group = nobody|group = nginx|g" /etc/php7/php-fpm.d/www.conf \
    && sed -i "s|;slowlog = log/php7/\$pool.slow.log|slowlog = /dev/stdout|g" /etc/php7/php-fpm.d/www.conf \
    && sed -i "s|;access.log = log/php7/\$pool.access.log|access.log = /dev/stdout|g" /etc/php7/php-fpm.d/www.conf \
    && sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini \
    && sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini \
    && sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php7/php.ini \
    && sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini \
    && sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini \
    && sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php7/php.ini

# Set Workdir
WORKDIR /var/www
# Expose volumes
VOLUME ["/var/www"]
# Expose ports
EXPOSE 9000
# CMD 
CMD ["/usr/sbin/php-fpm7"]

