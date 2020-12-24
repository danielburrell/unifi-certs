#!/bin/bash

#######################
# Example Usage ./get-certs.sh home.example.com
#######################

ledomain=$1

certbot certonly \
        --dns-route53 \
        --dns-route53-propagation-seconds 30 \
        --noninteractive \
        -d *.$1

rm -f /etc/ssl/private/cert.tar
rm -f /etc/ssl/private/cloudkey.crt
rm -f /etc/ssl/private/cloudkey.key
rm -f /etc/ssl/private/unifi.keystore.jks
rm -f /etc/ssl/private/unifi.keystore.jks.md5

ephemeralPassword=$(openssl rand -base64 32)

openssl pkcs12 \
         -export \
         -out /etc/ssl/private/cloudkey.p12 \
         -inkey /etc/letsencrypt/live/$ledomain/privkey.pem \
         -in /etc/letsencrypt/live/$ledomain/cert.pem \
         -name unifi \
         -password pass:$ephemeralPassword

keytool -importkeystore -deststorepass aircontrolenterprise \
         -destkeypass aircontrolenterprise \
         -destkeystore /usr/lib/unifi/data/keystore \
         -srcstorepass $ephemeralPassword \
         -srckeystore /etc/ssl/private/cloudkey.p12 \
         -srcstoretype PKCS12 -alias unifi

rm -f /etc/ssl/private/cloudkey.p12

cp /etc/letsencrypt/live/$ledomain/privkey.pem /etc/ssl/private/cloudkey.key
cp /etc/letsencrypt/live/$ledomain/cert.pem /etc/ssl/private/cloudkey.crt

tar -cvf /etc/ssl/private/cert.tar -C /etc/ssl/private/ .

chown root:ssl-cert /etc/ssl/private/*
chmod 640 /etc/ssl/private/*

/usr/sbin/nginx -t

service nginx restart
service unifi start