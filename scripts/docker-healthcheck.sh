#!/bin/bash
if [ -z ${RELATIVE_URL+x} ]; then
  RELATIVE_URL="/"
fi

wget -O - --no-check-certificate "https://127.0.0.1/$RELATIVE_URL"/ 2>/dev/null | grep 'login'
exit $?
