#!/bin/bash
set -e

# CA files and folders
mkdir -p    {key,crt,new_crt,csr,crl}
touch       index.txt serial
#echo "01" > serial
echo "unique_subject = no" > index.txt.attr

# CA crt
echo "Gen CA crt"
openssl req -new \
    -newkey rsa:4096 \
    -nodes \
    -keyout key/ca.key \
    -x509 \
    -days 3650 \
    -subj "/C=RU/ST=SPB/L=SPB/O=Skillfactory/OU=DevOps/CN=Test Root CA" \
    -out crt/ca.crt

# Elasticsearch crt
echo "Gen nginx csr"
openssl req -new \
    -newkey rsa:4096 \
    -sha256 \
    -nodes \
    -keyout     key/nginx-01.key \
    -subj       "/CN=nginx-01" \
    -addext     "subjectAltName = IP.1:172.20.0.3, IP.2:127.0.0.1, DNS.1:nginx-01, DNS.2:localhost" \
    -addext     "extendedKeyUsage = serverAuth" \
    -out        csr/nginx-01.csr

echo "Sign nginx csr"
openssl ca \
    -config openssl.conf \
    -in     csr/nginx-01.csr \
    -out    crt/nginx-01.crt \
    -batch

openssl x509 -text -noout \
    -in     crt/nginx-01.crt

# Fix permissions
chmod 644 key/*

