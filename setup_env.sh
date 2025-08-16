#!/bin/bash

# Script pour configurer les variables d'environnement SMTP

echo "Configuration des variables d'environnement SMTP..."

# Créer le fichier .env s'il n'existe pas
if [ ! -f .env ]; then
    echo "Création du fichier .env..."
    cat > .env << EOF
# Configuration SMTP Gmail
SMTP_USERNAME=josephyanickmingala@gmail.com
SMTP_PASSWORD=qefJu0-dykvem-newrom

# Configuration de l'application
APP_HOST=localhost:3000
EOF
    echo "✅ Fichier .env créé avec succès"
else
    echo "⚠️  Le fichier .env existe déjà"
fi

# Vérifier que les variables sont bien définies
echo ""
echo "Vérification des variables d'environnement :"
echo "SMTP_USERNAME: $SMTP_USERNAME"
echo "SMTP_PASSWORD: $SMTP_PASSWORD"
echo "APP_HOST: $APP_HOST"

echo ""
echo "🎉 Configuration terminée !"
echo "Vous pouvez maintenant tester l'envoi d'emails."
