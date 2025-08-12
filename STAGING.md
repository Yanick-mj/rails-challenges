# 🚀 Environnement de Staging Local

Ce document explique comment utiliser l'environnement de staging local pour tester votre application avant déploiement sur Heroku.

## 🎯 Objectif

L'environnement de staging local simule l'environnement de production (Heroku) en local pour détecter les problèmes avant déploiement.

## 📋 Prérequis

- PostgreSQL installé et démarré
- Ruby 3.3.5
- Rails 8.0.2

## 🚀 Utilisation

### 1. Démarrer l'environnement staging

```bash
# Démarrer le serveur staging
bin/staging
```

Le serveur sera accessible sur `http://localhost:3001`

### 2. Tester l'environnement staging

```bash
# Tester les endpoints critiques
bin/test-staging
```

### 3. Vérification complète avant déploiement

```bash
# Vérification complète
bin/pre-deploy-check
```

## 🔍 Tests effectués

### Tests automatiques (`bin/test-staging`)
- ✅ Route `/up` (healthcheck)
- ✅ Page d'accueil
- ✅ Page challenges (avec helpers)

### Vérifications complètes (`bin/pre-deploy-check`)
- ✅ Environnement staging
- ✅ Routes critiques
- ✅ Helpers (ex: `flash_class`)
- ✅ Configuration base de données
- ✅ Syntaxe des fichiers

## 🛠️ Configuration

### Fichiers de configuration
- `config/environments/staging.rb` - Configuration staging
- `config/database.yml` - Configuration DB staging
- `bin/staging` - Script de démarrage
- `bin/test-staging` - Script de test
- `bin/pre-deploy-check` - Script de vérification complète

### Base de données staging
```bash
# Créer la DB staging
RAILS_ENV=staging rails db:create

# Migrer
RAILS_ENV=staging rails db:migrate

# Seeder (optionnel)
RAILS_ENV=staging rails db:seed
```

## 🎯 Workflow recommandé

### Avant chaque déploiement :
1. **Développer** votre fonctionnalité
2. **Tester** en local : `bin/pre-deploy-check`
3. **Corriger** les problèmes détectés
4. **Déployer** : `git push heroku main`

### Exemple de workflow :
```bash
# 1. Développer
# ... votre code ...

# 2. Tester
bin/pre-deploy-check

# 3. Si tout est OK, déployer
git add .
git commit -m "Nouvelle fonctionnalité"
git push heroku main
```

## 🚨 Problèmes détectés automatiquement

- ❌ Helpers manquants (ex: `flash_class`)
- ❌ Routes manquantes
- ❌ Erreurs de configuration
- ❌ Problèmes de base de données
- ❌ Erreurs de syntaxe

## 💡 Avantages

- ✅ **Détection précoce** des erreurs de production
- ✅ **Environnement similaire** à Heroku
- ✅ **Tests automatisés** rapides
- ✅ **Debugging facilité** (erreurs visibles)
- ✅ **Pas d'impact** sur l'environnement de développement

## 🔧 Dépannage

### Le serveur staging ne démarre pas
```bash
# Vérifier PostgreSQL
pg_isready

# Vérifier les logs
tail -f log/staging.log
```

### Erreurs de base de données
```bash
# Recréer la DB staging
RAILS_ENV=staging rails db:drop
RAILS_ENV=staging rails db:create
RAILS_ENV=staging rails db:migrate
```

### Problèmes de gems
```bash
# Réinstaller les gems
bundle install
```

## 📝 Notes

- L'environnement staging utilise la configuration de développement avec quelques ajustements
- Les gems SolidCable/SolidCache/SolidQueue sont désactivées pour éviter les problèmes de configuration
- Le serveur staging tourne sur le port 3001 pour éviter les conflits avec le serveur de développement (port 3000)
