#!/bin/bash

rm /var/docker/controlesr/bind/bind/etc/named.conf.local

mv /var/docker/controlesr/install/bind/named.conf.local /var/docker/controlesr/bind/bind/etc/named.conf.local
mv /var/docker/controlesr/install/bind/heberg.projet.db /var/docker/controlesr/bind/bind/etc/heberg.projet.db

docker restart controlesr_bind9_1