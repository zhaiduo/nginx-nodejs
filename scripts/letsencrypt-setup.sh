#!/bin/bash

# Lets Encrypt
if [ -z "$WEBROOT" ] || [ -z "$GIT_EMAIL" ] || [ -z "$DOMAIN" ]; then
 echo "You need the \$WEBROOT, \$GIT_EMAIL and the \$DOMAIN Variables"
else
 /opt/letsencrypt/letsencrypt-auto certonly -a webroot --webroot-path=$WEBROOT --email $GIT_EMAIL -d $DOMAIN 
fi
