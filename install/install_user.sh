#!/bin/bash

###############################################################################
#                                INFORMATIONS                                 #
###############################################################################

# Lance : nginx + php + phpmyadmin + db + bind9 + supervision

# ATTENTION :  Ce script peut s'executer autant de fois que vous devez ajouter des utilisateurs.
#              Executer la solution avec la commande suivante dans le dossier "install" : ./install_user.sh <user> <mdp> <nomSousDomaine>

# Base de données : Si vous voulez créer la base de données, voici les commandes à éffectué :
# - Créer une base de données :                    CREATE DATABASE changemoi;
# - Créer un utilisateur :                         CREATE user "changemoi";
# - Créer un mot de passe :                        SET password FOR "nomuser" = password('mdp');
# - Accorder l'utilisateur à la base de données :  GRANT ALL ON nomuser.* TO "nomdb";
# Puis faire un CTRL + C pour continuer la fin du script d'installation d'un utilisateur

###############################################################################
#                                  SERVICES                                   #
###############################################################################

#arguments script
login="$1"
password="$2"
sousDomaine="$3"

#on verifie le nombre d'argument
if [ "$#" -ne 3 ] ; then
	echo "[ERREUR] ./install_user.sh #user #mdp #nomSousDomaine"
	exit
fi

#on vérfie que l'utilisateur n'existe pas
users=$(cut -d ':' -f 1 /etc/passwd)

#on boucle sur tout les utilisateurs
for user in $users ; do
	if [ "$user" = "$login" ] ; then
		echo "[ERREUR] L'utilisateur existe déjà."
		exit
	fi
done

#on commence à passer à des vérifications
#on évite que le login soit identique au mdp
if [ "$login" = "$password" ] ; then
	echo "[ERREUR] Votre mot de passe est identique à votre mot de passe."
	exit

#on verifie que le mot de passe soit nul
elif [ -z "$password" ] ; then
	echo "[ERREUR] Votre mot de passe est nul."
	exit
fi

#on vérifie que maintenant le nom du sous domaine n'existe pas
for FILE in /var/docker/controlesr/vhosts/heberg/subdomains/* ; do
	if [ "/var/docker/controlesr/vhosts/heberg/subdomains/$sousDomaine" = "$FILE" ] ; then
		echo "[ERREUR] Le nom du sous domaine existe déjà."
		exit
	fi
done

#on hach le mot de passe
hash=$(echo -n "$password" | sha1sum | awk '{print $1}')

#on ajoute l'utilisateur
useradd -m -p "$hash" -s /bin/bash "$login"

#on créer le dossier du sous domaine
mkdir /var/docker/controlesr/vhosts/heberg/subdomains/$sousDomaine

#on laisse la possibilité à l'administrateur de créer ou non une base de données (ctrl + c pour continuer le script)
docker exec -it controlesr_db_1 sh -c 'exec mysql -uroot -p"root"'

#on ajoute le sous domaine dans BIND
echo "" >> /var/docker/controlesr/bind/bind/etc/heberg.projet.db
echo "$sousDomaine A 0.0.0.0" >> /var/docker/controlesr/bind/bind/etc/heberg.projet.db

#on restart bind9
docker restart controlesr_bind9_1

#on ajoute le fichier de conf nginx du sous domaine.
touch /var/docker/controlesr/nginx/enabled/$sousDomaine.conf

echo "server {" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf
echo "	listen 80;" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf
echo "	server_name $sousDomaine.heberg.projet;" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf
echo "	index index.php index.html index.htm;" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf
echo "	root /vhosts/heberg/subdomains/$sousDomaine;" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf
echo "	location / {" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf
echo "		try_files "\$uri" "\$uri"/ /index.php"\$is_args""\$args" =404;" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf
echo "	}" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf
echo "	include /nginx/snippets/php7.0.8-fpm-ext.conf;" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf
echo "}" >> /var/docker/controlesr/nginx/enabled/$sousDomaine.conf

#on copie l'index.php dans le dossier du sous domaine
cp /var/docker/controlesr/install/subDomains/index.php /var/docker/controlesr/vhosts/heberg/subdomains/$sousDomaine/index.php

#on relance nginx
docker-compose exec nginx nginx -t && docker-compose restart nginx

#on arrete et supprimer le container ftp
docker stop install_proftpd_1
docker rm install_proftpd_1

#on ajoute un accès ftp à l'utilisateur
sed -i -e "s/r0m41nUser/$login/g" /var/docker/controlesr/install/ftp/docker-compose.yml
sed -i -e "s/r0m41nMdp/$password;r0m41nUser:r0m41nMdp/g" /var/docker/controlesr/install/ftp/docker-compose.yml
echo "      - \"/var/docker/controlesr/vhosts/heberg/subdomains/$sousDomaine:/home/$login\"" >> /var/docker/controlesr/install/ftp/docker-compose.yml

#on deplace le docker compose de la FTP.
cp /var/docker/controlesr/install/ftp/docker-compose.yml /var/docker/controlesr/install/docker-compose.yml

#on lance le container
docker-compose up -d

#on supprime le docker compose
rm /var/docker/controlesr/install/docker-compose.yml

echo "[SUCCES] L'utilisateur a été rajouté !"