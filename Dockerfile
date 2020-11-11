FROM ubuntu:20.04

LABEL Description="Cutting-edge LAMP stack, based on Ubuntu 20.04 LTS. Includes .htaccess support and popular PHP7.4 features." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST DB PORT NUMBER]:3306 -p [HOST WWW PORT NUMBER]:80  -v [HOST WWW DOCUMENT ROOT]:/var/www/html -v [HOST DB DOCUMENT ROOT]:/var/lib/mysql lamp/perso" \
	Version="1.0"

RUN apt update -y
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt install php7.4 php7.4-common php7.4-mysql php7.4-curl php7.4-cgi php7.4-opcache php7.4-mbstring -y 
RUN apt install apache2 libapache2-mod-php7.4 -y
RUN apt install mariadb-common mariadb-server mariadb-client -y
RUN apt install vim -y
RUN apt install git -y
RUN apt install curl -y
RUN apt install sudo -y
RUN curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
RUN apt install -y nodejs

RUN npm install gulp -g
RUN npm install sass -g

# configuration de php 
RUN sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.4/apache2/php.ini
RUN sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ UTC/" /etc/php/7.4/apache2/php.ini
#RUN sed -i "s/upload_max_filesize\ \=\ 2M/upload_max_filesize\ \=\ 64M/g" /etc/php/7.4/apache2/php.ini
#RUN sed -i "s/post_max_size\ \=\ 8M/post_max_size\ \=\ 64M/g" /etc/php/7.4/apache2/php.ini

RUN  echo "<ifModule mod_rewrite.c>\n \tRewriteEngine On \n</ifModule>">> /etc/apache2/apache2.conf
# permet la prise en compte des modifications de configuration indiqué dans le fichier .htaccess
RUN sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf
RUN a2enmod rewrite

#install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'c31c1e292ad7be5f49291169c0ac8f683499edddcfd4e42232982d0fd193004208a58ff6f353fde0012d35fdd72bc394') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

COPY phpinfo.php /var/www/html/

VOLUME /var/www/html
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /etc/apache2

EXPOSE 80
EXPOSE 3306

CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]