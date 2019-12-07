#!/bin/bash

echo "Running....."

if [ "$MAGENTO_BASE_URL" = "" ]
then
    echo "MAGENTO_BASE_URL is missing!"
    exit
fi

file="mage2/.magento2_installed"

if [ -f "$file" ]
then
    echo "111111111111"
    php /mage2/bin/magento setup:store-config:set --base-url="${MAGENTO_BASE_URL}"
    php /mage2/bin/magento cache:flush
    chmod -R 777 mage2/var
    chmod -R 777 mage2/pub
    chmod -R 777 mage2/generated
    chmod -R 777 mage2/app
else
    echo "222222222"
	chmod -R 777 data/
	#composer create-project --repository=https://${MAGENTO_PRIVATE_KEY}:${MAGENTO_PUBLIC_KEY}@repo.magento.com/ magento/project-community-edition project/ /project-community-edition
	#composer create-project --repository-url=https://${MAGENTO_PRIVATE_KEY}:${MAGENTO_PUBLIC_KEY}@repo.magento.com/ magento/project-community-edition
	#RUN git clone https://github.com/magento/magento2.git
	composer create-project --repository-url=https://${MAGENTO_PRIVATE_KEY}:${MAGENTO_PUBLIC_KEY}@repo.magento.com/ magento/project-community-edition=2.2.2 mage2

    if php mage2/bin/magento setup:install --base-url="${MAGENTO_BASE_URL}" --db-host="magento2_mysql" --db-name="magento2" --db-user="root" --admin-firstname="admin" --admin-lastname="admin" --admin-email="user@example.com" --admin-user="admin" --admin-password="admin123" --language="en_US" --currency="USD" --timezone="Europe/Istanbul" --use-rewrites="1" --backend-frontname="admin" ; then
        echo "" > mage2/.magento2_installed
        echo "Magento 2 Community Edition successfully installed."
        cd mage2
        composer install
        php mage2/bin/magento setup:upgrade
        php mage2/bin/magento cache:flus
	php mage2/bin/magento cron:install --force
	#chown -R :www-data /data/project/magento2
	chmod -R 777 mage2/var
	chmod -R 777 mage2/pub
	chmod -R 777 mage2/generated
	chmod -R 777 mage2/app

   fi
fi

echo "Magento admin url: $MAGENTO_BASE_URL/admin"
echo "Magento admin username: admin"
echo "Magento admin password: admin123"

/usr/sbin/php-fpm7.1 -R &
/usr/sbin/nginx -g "daemon off;" &
/usr/bin/memcached -u root
