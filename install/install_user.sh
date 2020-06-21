#!/bin/bash

#arguments script
login="$1"
password="$2"
sousDomaine="$3"

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
hash=$(mkpasswd -m sha-512 "$password")

#on ajoute l'utilisateur
useradd -m -p "$hash" -s /bin/bash "$login"

echo "[SUCCES] L'utilisateur a été ajouté"

mkdir /var/docker/controlesr/vhosts/heberg/subdomains/$sousDomaine

touch /var/docker/controlesr/install/docker-compose.yml

echo "version: '3.1'" >> /var/docker/controlesr/install/docker-compose.yml
echo "services:" >> /var/docker/controlesr/install/docker-compose.yml
echo "  db:" >> /var/docker/controlesr/install/docker-compose.yml
echo "    image: mariadb" >> /var/docker/controlesr/install/docker-compose.yml
echo "    restart: always" >> /var/docker/controlesr/install/docker-compose.yml
echo "    environment:" >> /var/docker/controlesr/install/docker-compose.yml
echo "      DB_USER: $login" >> /var/docker/controlesr/install/docker-compose.yml
echo "      DB_PASSWORD: $password" >> /var/docker/controlesr/install/docker-compose.yml
echo "      DB_NAME: $login" >> /var/docker/controlesr/install/docker-compose.yml
echo "    volumes:" >> /var/docker/controlesr/install/docker-compose.yml
echo "      - ./var/docker/controlesr/vhosts/heberg/subdomains/$sousDomaine/db:/var/lib/mysql" >> /var/docker/controlesr/install/docker-compose.yml

docker-compose up -d

echo "$subdomains 192.168.1.40" >> /var/docker/controlesr/bind/bind/etc/heberg.projet.db

rm /var/docker/controlesr/install/docker-compose.yml