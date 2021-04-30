FROM alpine:3.13

COPY php.ini /etc/php8/conf.d/nodesol.ini
COPY entrypoint /usr/bin/entrypoint

RUN apk update \
	&& apk upgrade \
	&& apk add postfix curl cyrus-sasl cyrus-sasl-login \
	&& apk add php8 php8-cli php8-bcmath php8-phar php8-tokenizer php8-curl php8-json php8-openssl php8-zip php8-pdo php8-mysqli php8-pdo_mysql php8-mysqlnd php8-dom php8-mbstring php8-session php8-fileinfo php8-gd php8-calendar php8-xml php8-xmlwriter php8-pcntl php8-posix php8-sockets \
	&& ln -s /usr/bin/php8 /usr/bin/php \
	&& php -v \
	&& mkdir -p /home/nodesol/public \
	&& chmod -R 777 /home/nodesol/public \
	&& chmod a+x /usr/bin/entrypoint


####
# POSTFIX
####

#RUN mv /etc/postfix/main.cf /etc/postfix/main.cf.BAK

COPY postfix/main.cf /etc/postfix/main.cf
COPY postfix/sasl_passwd /etc/postfix/sasl_passwd

RUN postmap lmdb:/etc/postfix/sasl_passwd \
	&& touch /etc/postfix/virtual \
	&& postmap /etc/postfix/virtual \
	&& touch /etc/postfix/aliases \
	&& postmap lmdb:/etc/postfix/aliases \
	&& chown root:postdrop /usr/sbin/postdrop \
	&& chmod 2755 /usr/sbin/postdrop

EXPOSE 8000

CMD exec /usr/bin/entrypoint
