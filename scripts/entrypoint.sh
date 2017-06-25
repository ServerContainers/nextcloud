#!/bin/bash

cat <<EOF
################################################################################

Welcome to the servercontainers/nextcloud

################################################################################

EOF

INITIALIZED="/initialized"

if [ ! -e "$INITIALIZED" ]
then
  # TIMEZONE
  if [ -z ${TZ+x} ]
  then
    export TZ="Europe/Berlin"
  fi
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

  # SSL
  if [ ! -e "/etc/apache2/external/cert.pem" ] || [ ! -e "/etc/apache2/external/key.pem" ]
  then
    echo ">> generating self signed cert"
    openssl req -x509 -newkey rsa:4086 \
    -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
    -keyout "/etc/apache2/external/key.pem" \
    -out "/etc/apache2/external/cert.pem" \
    -days 3650 -nodes -sha256
  fi

  # RELATIVE_URL
  if [ -z ${RELATIVE_URL+x} ]
  then
    export RELATIVE_URL="/"
  fi
  sed -i "s,RELATIVE_URL,$RELATIVE_URL,g" /etc/apache2/sites-enabled/000-default.conf

  # HSTS_HEADERS
  if [ ! -z ${HSTS_HEADERS+x} ]
  then
    echo ">> enabling HSTS Headers"
    sed -i "s,#Header,Header,g" /etc/apache2/sites-enabled/000-default.conf
  fi

  cp -a /var/www/nextcloud/apps.bak/* /var/www/nextcloud/apps/ 2> /dev/null

  cp /var/www/nextcloud/data.bak/.* /var/www/nextcloud/data/ 2> /dev/null
  touch /var/www/nextcloud/data/nextcloud.log

  cp /var/www/nextcloud/config.bak/.* /var/www/nextcloud/config/ 2> /dev/null
  if [ ! -e "/var/www/nextcloud/config/config.php" ]; then
    echo ">> installing default config"
    cp -a /var/www/nextcloud/config.bak/* /var/www/nextcloud/config/ 2> /dev/null
  fi

  sed -i 's,<rememberlogin>false</rememberlogin>,<rememberlogin>true</rememberlogin>,g' /var/www/nextcloud/apps/files_external/appinfo/info.xml

  chown www-data:www-data -R /var/www/nextcloud/
  chmod -R a+rw /var/www/nextcloud/data

  cd /var/www/nextcloud/

  if [ ! -z ${DB_HOST+x} ] && [ ! -z ${DB_NAME+x} ] && [ ! -z ${DB_USER+x} ] && [ ! -z ${DB_PASSWORD+x} ] && [ $(mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "show tables;" | wc -l) -lt 10 ]
  then
    echo ">> nextcloud installing db"

  	## Update Charset
  	mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "ALTER DATABASE $DB_NAME DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_general_ci;"

    su www-data -s /bin/bash -c "./occ maintenance:install --database '$DB_TYPE'  --database-host '$DB_HOST' --database-name '$DB_NAME'  --database-user '$DB_USER' --database-pass '$DB_PASSWORD' --admin-user '$ADMIN_NAME' --admin-pass '$ADMIN_PASSWORD'"
  else
  	echo ">> nextcloud db already installed"
  fi

  ## Update Database if this is run after an update
  echo ">> update database if necessary"
  su www-data -s /bin/bash -c "./occ upgrade"

  echo ">> plugins"
  echo "  >> enabling default plugins [files_external, user_external]"
  su www-data -s /bin/bash -c "./occ app:enable files_external"
  su www-data -s /bin/bash -c "./occ app:enable user_external"

  # CUSTOM PLUGINS
  if [ ! -z ${CUSTOM_PLUGINS+x} ]
  then
    echo "  >> installing custom plugins"
    for plugin in $CUSTOM_PLUGINS
    do
      nextcloud-plugin-download.sh "$plugin"
    done
  else
    echo "  >> no custom plugins to install"
  fi

  cd -

  # BACKUP Folders from installation 
  if [ -z ${KEEP_INSTALLATION_FOLDERS+x} ]
  then
    echo ">> removing files from installation"
    rm -rf /var/www/nextcloud/*.bak
  fi

  touch "$INITIALIZED"
else
  echo ">> already initialized - starting directly"
fi

/etc/init.d/sendmail start &
cron -f &
tail -f /var/www/nextcloud/data/nextcloud.log &

export APACHE_RUN_USER="www-data"
export APACHE_RUN_GROUP="www-data"
export APACHE_LOG_DIR="/var/log/apache2"
export APACHE_LOCK_DIR="/var/lock/"
/usr/sbin/apache2 -D FOREGROUND
