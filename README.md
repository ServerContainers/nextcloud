# Docker Nextcloud-Server Container (servercontainers/nextcloud)
_maintained by ServerContainers_

[FAQ - All you need to know about the servercontainers Containers](https://marvin.im/docker-faq-all-you-need-to-know-about-the-marvambass-containers/)

## What is it

This Dockerfile (available as ___servercontainers/nextcloud___) gives you a Nextcloud-Server with Apache/PHP on Debian.

On the first start (or if Database Table is empty), the setup is executed as specified by environment variables.

For Configuration of the Server you use environment Variables.

If you want to use this in a public/production environment, use this behind a proxy - e.g. ___servercontainers/nginx___.

It's based on the [debian:jessie](https://registry.hub.docker.com/_/debian/) Image

View in Docker Registry [servercontainers/nextcloud](https://registry.hub.docker.com/u/servercontainers/nextcloud/)

View in GitHub [ServerContainers/nextcloud](https://github.com/ServerContainers/nextcloud)

## Environment variables and defaults

### General

* __TZ__
    * default _Europe/Berlin_ - change if you want a different TimeZone
* __RELATIVE\_URL__
    * default _/_ - the path nextcloud will be available e.g. '/nextcloud' etc.
* __HSTS\_HEADERS__
    * default none - if set to any value, the hsts headers will be enabled

### NEXTCLOUD

* __CUSTOM\_PLUGINS__
    * default none - list of additional nextcloud plugins to install e.g. 'calendar contacts'

* __ADMIN\_USER__
    * default none - name for the admin user for the nextcloud installation
* __ADMIN\_PASSWORD__
    * default none - password for the admin user for the nextcloud installation

## DB Connection

to enable automatic installation you need to set all of the following envs.

* __DB\_TYPE__
    * default none - set this to the database type (mysql etc.)
        * sqlite
        * mysql
        * pgsql
* __DB\_HOST__
    * default none - set to db host
* __DB\_NAME__
    * default none - name of the db for the nextcloud instance
* __DB\_USER__
    * default none - name for the user for the db connection
* __DB\_PASSWORD__
    * default none - password for the user for the db connection

## Configuration Options

You might want to edit the config.php manualy to add and modify custom settings.

### Mail sending configuration

    'mail_smtpmode' => 'sendmail',
    'mail_from_address' => 'admin',
    'mail_domain' => 'nextcloud.my.tld',

### IMAP Auth (gmail example))

    'user_backends' => array (
        0 => array (
                'class'     => 'OC_User_IMAP',
                'arguments' => array (
                                  0 => '{imap.gmail.com:993/imap/ssl}'
                                  ),
        ),
    ),

## Misc

### Get current NextCloud version

    wget -O - https://nextcloud.com/changelog/ 2> /dev/null | tr '>' '\n' | tr '<' '\n' | grep Version | head -n1 | awk '{print $2}'
