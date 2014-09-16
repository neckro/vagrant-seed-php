#!/bin/bash

PACKAGES=$(cat <<END

nginx-full

php5
php5-cli
php5-fpm
php5-json
php5-mysql
php5-sqlite
php5-xdebug

mysql-client-5.5
mysql-server-5.5
sqlite3

vim
git
ack-grep

END
)

export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
echo $PACKAGES | xargs apt-get -qy install || exit 1

function mysql_create_user() {
    local MYSQL_DB=$1
    local MYSQL_USER=$2
    local MYSQL_PASS=$3
    mysql -uroot -e "CREATE DATABASE IF NOT EXISTS $1"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO $MYSQL_USER@localhost IDENTIFIED BY '$MYSQL_PASS'"
}

function mysql_set_root_pass() {
    local MYSQL_ROOT_PASS=$1
    debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PASS'
    debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password $MYSQL_ROOT_PASS'
}

# symlink config files
ln -fsv /vagrant/vagrant/php5/www.conf /etc/php5/fpm/pool.d/www.conf
ln -fsv /vagrant/vagrant/php5/php-fpm.conf /etc/php5/fpm/php-fpm.conf
ln -fsv /vagrant/vagrant/php5/php.ini /etc/php5/fpm/conf.d/99-vagrant.ini
ln -fsv /vagrant/vagrant/php5/php.ini /etc/php5/cli/conf.d/99-vagrant.ini
ln -fsv /vagrant/vagrant/nginx/nginx.conf /etc/nginx/nginx.conf
ln -fsv /vagrant/vagrant/nginx/vagrant.conf /etc/nginx/sites-enabled/default

# make log dir for php/fpm
mkdir -v /var/log/php 2>/dev/null
chown -v www-data /var/log/php

# restart services
service nginx restart
service php5-fpm restart

# make logs readable
chown -vR www-data:www-data /var/log/php /var/log/nginx
chmod -vR a+r /var/log/php5-fpm.log /var/log/nginx

# add vagrant user to www-data group
gpasswd -a vagrant www-data

# link logs into home dir
ln -fsv /var/log/php/php5-fpm.log /home/vagrant/fpm.log
ln -fsv /var/log/php/error.log /home/vagrant/php.log
ln -fsv /var/log/nginx/access.log /home/vagrant/access.log
ln -fsv /var/log/nginx/error.log /home/vagrant/error.log

# make ack-grep alias
ln -fsv /usr/bin/ack-grep /usr/bin/ack

# adios
exit 0
