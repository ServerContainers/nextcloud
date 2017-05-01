#!/bin/bash

PLUGIN="$1"

if [ -z ${PLUGIN+x} ]
then
  echo ">> could not install plugin... none given"
  exit 1
else
  echo ">> installing plugin '$PLUGIN'"
fi

if [ ! -d "/var/www/nextcloud/apps/$PLUGIN" ]
then
  DOWNLOAD_URL=$(wget -O - "https://apps.nextcloud.com/apps/$PLUGIN" 2> /dev/null | tr '\n' ' ' | sed -e 's,.*Downloads,,g' -e 's,/section.*,,g' | tr '>' '\n' | grep 'noopener' | cut -d'"' -f2 | head -n1)

  cd /var/www/nextcloud/apps/
  echo "  >> downloading plugin '$PLUGIN'"
  wget -O /tmp/plugin.tar.gz "$DOWNLOAD_URL" \
    && tar xvzf /tmp/plugin.tar.gz \
    && rm /tmp/plugin.tar.gz
  cd -
fi

cd /var/www/nextcloud/
echo "  >> enabling plugin '$PLUGIN'"
su www-data -s /bin/bash -c "./occ app:enable $PLUGIN"
cd -

echo ">> plugin installation '$PLUGIN' done"
