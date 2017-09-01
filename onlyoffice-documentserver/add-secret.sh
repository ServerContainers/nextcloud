#!/bin/sh
sed -i 's,: "secret",: "'$SECRET'",g' /etc/onlyoffice/documentserver/default.json
sed -i 's,"browser": false,"browser": true,g' /etc/onlyoffice/documentserver/default.json
sed -i 's,"inbox": false,"inbox": true,g' /etc/onlyoffice/documentserver/default.json
sed -i 's,"outbox": false,"outbox": true,g' /etc/onlyoffice/documentserver/default.json
