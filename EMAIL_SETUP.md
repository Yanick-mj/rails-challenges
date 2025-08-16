# 📧 Guide de configuration des notifications par email

## ✅ Système de notifications configuré

Votre application Rails Challenge dispose maintenant d'un système complet de notifications par email avec les fonctionnalités suivantes :

### 🎯 Fonctionnalités implémentées

1. **Email de bienvenue** - Envoyé automatiquement lors de l'inscription d'un utilisateur
2. **Email de confirmation de création de challenge** - Envoyé quand un utilisateur crée un challenge
3. **Email de confirmation de participation** - Envoyé quand un utilisateur rejoint un challenge
4. **Email de confirmation de départ** - Envoyé quand un utilisateur quitte un challenge

### 🔧 Configuration actuelle

- **Service SMTP** : Gmail
- **Envoi en arrière-plan** : Active Job avec Solid Queue
- **Templates** : HTML et texte pour tous les emails
- **Tests** : Couverture complète des fonctionnalités

## 🚀 Déploiement en production

### Variables d'environnement à configurer

```bash
# Configuration SMTP Gmail
SMTP_USERNAME=josephyanickmingala@gmail.com
SMTP_PASSWORD=mcwq eosg jqxx bwho

# Configuration de l'application
APP_HOST=votre-domaine.com
```

### Commandes de déploiement

```bash
# 1. Migrer la base de données
rails db:migrate

# 2. Démarrer le worker pour les emails en arrière-plan
bin/jobs

# 3. Vérifier que les emails sont envoyés
rails console
# Puis tester : NotificationMailer.welcome_email(User.first).deliver_now
```

## 🧪 Tests

### Tester en développement

```bash
# Lancer le test automatique
ruby test_email.rb

# Ou tester manuellement dans la console Rails
rails console
user = User.create(email: 'test@example.com', password: 'password123')
```

### Vérifier les emails

1. **En développement** : Les emails s'affichent dans la console Rails
2. **En production** : Vérifiez votre boîte email Gmail

## 📋 Checklist de déploiement

- [ ] Variables d'environnement configurées sur le serveur
- [ ] Base de données migrée (`rails db:migrate`)
- [ ] Worker Solid Queue démarré (`bin/jobs`)
- [ ] Test d'envoi d'email effectué
- [ ] Logs vérifiés pour les erreurs SMTP

## 🔍 Dépannage

### Erreur d'authentification Gmail

Si vous obtenez une erreur `535-5.7.8 Username and Password not accepted` :

1. Vérifiez que l'authentification à 2 facteurs est activée sur Gmail
2. Utilisez un mot de passe d'application (pas votre mot de passe principal)
3. Vérifiez que le mot de passe d'application est correct

### Emails non envoyés

1. Vérifiez que le worker Solid Queue fonctionne : `bin/jobs`
2. Consultez les logs : `tail -f log/development.log`
3. Testez manuellement : `NotificationMailer.welcome_email(User.first).deliver_now`

## 📞 Support

Pour toute question ou problème :
1. Vérifiez les logs Rails
2. Testez la configuration SMTP
3. Consultez la documentation Gmail pour les mots de passe d'application

---

**🎉 Votre système de notifications par email est maintenant opérationnel !**
