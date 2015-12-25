#!/usr/bin/env bash

# Enable trace printing and exit on the first error
set -ex

is_windows_host=$1
guest_magento_dir=$2
magento_host_name=$3

apt-get update

# Setup Apache
apt-get install -y apache2
a2enmod rewrite

# Make suer Apache is run from 'vagrant' user to avoid permission issues
sed -i 's|www-data|vagrant|g' /etc/apache2/envvars

# Enable Magento virtual host
apache_config="/etc/apache2/sites-available/magento2.conf"
cp /vagrant/magento2.vhost.conf  ${apache_config}
sed -i "s|<host>|${magento_host_name}|g" ${apache_config}
sed -i "s|<guest_magento_dir>|${guest_magento_dir}|g" ${apache_config}
a2ensite magento2.conf

# Disable default virtual host
sudo a2dissite 000-default

# Setup PHP
apt-get install -y php5 php5-mhash php5-mcrypt php5-curl php5-cli php5-mysql php5-gd php5-intl php5-xsl php5-xdebug curl
if [ ! -f /etc/php5/apache2/conf.d/20-mcrypt.ini ]; then
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
fi
if [ ! -f /etc/php5/cli/conf.d/20-mcrypt.ini ]; then
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
fi
echo "date.timezone = America/Chicago" >> /etc/php5/cli/php.ini

# Configure XDebug to allow remote connections from the host
echo 'xdebug.max_nesting_level=200
xdebug.remote_enable=1
xdebug.remote_connect_back=1' >> /etc/php5/cli/conf.d/20-xdebug.ini

# Restart Apache
service apache2 restart

# Setup MySQL
debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
apt-get install -q -y mysql-server-5.6 mysql-client-5.6
mysqladmin -uroot -ppassword password ''

# Make it possible to run 'mysql' without username and password
sed -i '/\[client\]/a \
user = root \
password =' /etc/mysql/my.cnf

# Install git
apt-get install -y git

# Setup Composer
if [ ! -f /usr/local/bin/composer ]; then
    cd /tmp
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
fi

# Configure composer
composer_auth_json="/vagrant/local.config/composer/auth.json"
if [ -f ${composer_auth_json} ]; then
    set +x
    echo "Installing composer OAuth tokens from ${composer_auth_json}..."
    set -x
    if [ ! -d /home/vagrant/.composer ] ; then
      sudo -H -u vagrant bash -c 'mkdir /home/vagrant/.composer'
    fi
    cp ${composer_auth_json} /home/vagrant/.composer/auth.json
fi

# Declare path to scripts supplied with vagrant and Magento
echo "export PATH=\$PATH:/vagrant/bin:${guest_magento_dir}/bin" >> /etc/profile
echo "export MAGENTO_ROOT=${guest_magento_dir}" >> /etc/profile

# Set permissions to allow Magento codebase upload by Vagrant provision script
if [ ${is_windows_host} -eq 1 ]; then
    chown -R vagrant:vagrant /var/www
    chmod -R 755 /var/www
fi

# Install RabbitMQ (is used by Enterprise edition)
apt-get install -y rabbitmq-server
rabbitmq-plugins enable rabbitmq_management
invoke-rc.d rabbitmq-server stop
invoke-rc.d rabbitmq-server start
