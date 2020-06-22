#!/bin/bash

#on supprime le fichier named.conf.local
rm /var/docker/controlesr/bind/bind/etc/named.conf.local
echo "Vous avez bien supprimer le dossier named.conf.local"

#on deplace le fichier named.conf.local et heberg.projet.db dans notre container
mv /var/docker/controlesr/install/bind/named.conf.local /var/docker/controlesr/bind/bind/etc/named.conf.local
mv /var/docker/controlesr/install/bind/heberg.projet.db /var/docker/controlesr/bind/bind/etc/heberg.projet.db
echo "Vous avez bien déplacer les fichiers : named.conf.local, heberg.projet.db"

#on restart notre container controlesr_bind9_1 pour actualiser notre nouveau dns heberg.projet
docker restart controlesr_bind9_1
echo "nameserver 192.168.1.41" > /etc/resolv.conf
echo "Restart effectué, votre dns est activé. Veuillez vérifier avec la commande : dig @localhost heberg.projet"
