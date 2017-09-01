FROM onlyoffice/documentserver

ENV SSL_CERTIFICATE_PATH /onlyoffice.crt
ENV SSL_KEY_PATH /onlyoffice.key
ENV SSL_DHPARAM_PATH /dhparam.pem

RUN openssl dhparam -out "$SSL_DHPARAM_PATH" 1024 \
 && openssl req -x509 -newkey rsa:4086 \
    -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
    -keyout "$SSL_KEY_PATH" \
    -out "$SSL_CERTIFICATE_PATH" \
    -days 3650 -nodes -sha256

COPY add-secret.sh /app/onlyoffice/

CMD bash -c '/app/onlyoffice/add-secret.sh; /app/onlyoffice/run-document-server.sh; while true; do sleep 1d; done'
