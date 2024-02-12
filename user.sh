#!/bin/bash

# Création du fichier temporaire pour le LDIF
mkdir -p ~/tmp
ldif=~/tmp/user.ldif

# Ajout d'un utilisateur dans Asterisk
echo "Entrez le nom du nouvel utilisateur :"
read user

echo "Quel numéro voulez-vous attribuer pour l'utilisateur ?"
read num

echo "Mot de passe Asterisk pour l'utilisateur :"
read -s pass
echo ""

# Cryptage du mot de passe en MD5
md5pwd=$(echo -n "$user:asterisk.sn:$pass" | md5sum | cut -c1-32)

# Génération du LDIF pour l'utilisateur
cat <<EOF >$ldif
dn: uid=$user,ou=users,ou=asterisk,dc=asterisk,dc=sn
objectClass: top
objectClass: inetOrgPerson
objectClass: AsteriskSIPUser
uid: $user
cn: $user
sn: $user
AstAccountContext: internal
AstAccountCallerID: $user <$num>
AstAccountRealmedPassword: $md5pwd
AstAccountQualify: yes
AstAccountNAT: yes
AstAccountType: friend
AstAccountHost: dynamic
AstAccountMailbox: $num@default
AstAccountCanReinvite: yes
AstAccountAllowedCodec: alaw
AstAccountLastQualifyMilliseconds: 500

dn: cn=$num-1,ou=extensions,ou=asterisk,dc=asterisk,dc=sn
objectClass: top
objectClass: inetOrgPerson
objectClass: AsteriskExtension
cn: $num-1
sn: $num-1
AstContext: internal
AstExtension: $num
AstPriority: 1
AstApplication: Answer

dn: cn=$num-2,ou=extensions,ou=asterisk,dc=asterisk,dc=sn
objectClass: top
objectClass: inetOrgPerson
objectClass: AsteriskExtension
cn: $num-2
sn: $num-2
AstContext: internal
AstExtension: $num
AstPriority: 2
AstApplication: Dial
AstApplicationData: SIP/$user

dn: cn=$num-3,ou=extensions,ou=asterisk,dc=asterisk,dc=sn
objectClass: top
objectClass: inetOrgPerson
objectClass: AsteriskExtension
cn: $num-3
sn: $num-3
AstContext: internal
AstExtension: $num
AstPriority: 3
AstApplication: Voicemail
AstApplicationData: $num@default

dn: cn=$num-4,ou=extensions,ou=asterisk,dc=asterisk,dc=sn
objectClass: top
objectClass: inetOrgPerson
objectClass: AsteriskExtension
cn: $num-4
sn: $num-4
AstContext: internal
AstExtension: $num
AstPriority: 4
AstApplication: Hangup
EOF

# Ajout du LDIF dans le LDAP
echo "Ajout de $user dans asterisk !" 
ldapadd -x -D "cn=admin,dc=asterisk,dc=sn" -W -f $ldif

# Nettoyage
rm $ldif

# Sortie
exit
