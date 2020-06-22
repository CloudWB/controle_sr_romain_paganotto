#!/bin/bash

###############################################################################
#                                INFORMATIONS                                 #
###############################################################################

# Lance : nginx + php + phpmyadmin + db + bind9 + supervision

# ATTENTION :  Ce script ne s'éxecute qu'une fois, lors du premier lancement de la solution complète.
#              Ne pas lancer après l'initialisation sous risque de faire planter la solution.
#              Executer la solution avec la commande suivante dans le dossier "controlesr" : ./start.sh <ip machine>

###############################################################################
#                                  SERVICES                                   #
###############################################################################

#On demande un argument (ip de la machine)
ipMachine="$1"

#On vérifie que le script soit bien lancé avec l'argument
if [ "$#" -ne 1 ] ; then
	echo "[ERREUR] ./start.sh <ip machine>"
	exit
fi

#On change l'adresse ip des fichiers config
sed -i -e "s/0.0.0.0/$ipMachine/g" /var/docker/controlesr/install/ftp/docker-compose.yml
sed -i -e "s/0.0.0.0/$ipMachine/g" /var/docker/controlesr/install/install_user.sh

#On se rend sur le dossier "constrolesr"
cd /var/docker/controlesr

#On lance la solution
docker-compose up -d

#On se rend sur le dossier dockprom
cd /var/docker/controlesr/dockprom

#On lance la solution de supervision
docker-compose up -d

#On modifie notre bind pour qu'il soit fonctionnel par rapport à notre IP et notre nom de domaine.
#on supprime le fichier named.conf.local
rm /var/docker/controlesr/bind/bind/etc/named.conf.local

#on deplace le fichier named.conf.local et heberg.projet.db dans notre container
mv /var/docker/controlesr/install/bind/named.conf.local /var/docker/controlesr/bind/bind/etc/named.conf.local
mv /var/docker/controlesr/install/bind/heberg.projet.db /var/docker/controlesr/bind/bind/etc/heberg.projet.db

#on restart notre container controlesr_bind9_1 pour actualiser notre nouveau dns heberg.projet
docker restart controlesr_bind9_1
echo "nameserver 192.168.1.41" > /etc/resolv.conf

echo "Votre solution est maintenant lancé et fonctionnel !"