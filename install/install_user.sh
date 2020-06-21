#!/bin/bash

#arguments script
login="$1"
password="$2"
sousDomaine="$3"

#on vérfie que l'utilisateur n'existe pas
users=$(cut -d ':' -f 1 /etc/passwd)

#on boucle sur tout les utilisateurs
for user in users ; do
	if [ "$user" + "$login" ] ; then
		echo "[ERREUR] L'utilisateur existe déjà."
		exit 1
	fi
done

#on commence à passer à des vérifications
#on évite que le login soit identique au mdp
if [ "$login" = "$password" ] ; then
	echo "[!] Password same as login"
	exit 1

#on verifie que le mot de passe soit nul
elif [ -z "$password" ] ; then
	echo "[!] Password is null"
	exit 1
fi

#on hach le mot de passe
hash=$(mkpasswd -m sha-512 "$password")

#on ajoute l'utilisateur
useradd -m -p "$hash" -s /bin/bash "$login"

echo "[SUCCES] L'utilisateur a été ajouté"


