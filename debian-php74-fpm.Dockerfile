FROM debian:buster
ENV DEBIAN_VERSION buster

## Install some basic stuff for easier management
RUN apt-get update \
    && apt-get install wget curl tmux net-tools nano vim git -y

RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime \
    && sh ~/.vim_runtime/install_awesome_vimrc.sh

COPY ./files/.bashrc /root/.bashrc

## Expose port 22 in case someone wants SSH access
EXPOSE 22

RUN apt-get update \
    && apt-get install apache2 software-properties-common gnupg2 python2 -y \
    && apt-get install lsb-release apt-transport-https ca-certificates -y

#RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B188E2B695BD4743

COPY ./files/php.list /etc/apt/sources.list.d/php.list

## Install PHP7.4 and the required packages
RUN apt-get update \
    && apt-get install php7.4 php7.4-fpm libapache2-mod-php7.4 php7.4-common php7.4-zip php7.4-mysql php7.4-xml php7.4-gd php7.4-mbstring php7.4-soap php7.4-dev php7.4-amqp php7.4-curl -y \
    && echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

## Enable some Apache2 modules
RUN a2enmod rewrite expires headers http2 proxy proxy_fcgi proxy_http vhost_alias \
    && service apache2 restart

## Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.20

#CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
ENV APACHE_RUN_DIR=/var/www/html
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2/

COPY ./files/start.sh /root/start.sh

CMD ["bash", "/root/start.sh"]
