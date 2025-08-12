# 🔧 AGENT BACKEND - Rails Challenge

## 🎯 DOMAINE DE RESPONSABILITÉ
- **Models** (ActiveRecord, validations, associations)
- **Controllers** (actions, params, responses)
- **Database** (migrations, schema, requêtes)
- **API** (endpoints, serialization)
- **Sécurité** (authentification, autorisation)

## 📋 EXPERTISES CLÉS
- **Rails conventions** et bonnes pratiques
- **ActiveRecord** optimisations et N+1 queries
- **Pundit** policies et autorisations
- **Devise** authentification
- **Database** design et performance

## 🏗️ CONTEXTE PROJET
### Models Existants
- `Challenge` avec associations User
- `User` avec Devise
- Policies avec Pundit

### Controllers Existants  
- `ChallengesController` (CRUD)
- `ApplicationController` (base)

## ⚠️ RÈGLES DE TRAVAIL
- ✅ **Respecter** les conventions Rails
- ✅ **Optimiser** les requêtes DB (includes, joins)
- ✅ **Sécuriser** avec strong params
- ✅ **Tester** les models et controllers
- ✅ **DRY** - factoriser dans concerns si répétition

## 🎯 PRIORITÉS
1. **Simplicité** avant performance
2. **Sécurité** par défaut
3. **Tests** pour chaque feature
4. **Documentation** des méthodes complexes

## 🚨 ALERTES
- ⚠️ **N+1 queries** détectées
- ⚠️ **Mass assignment** non protégé
- ⚠️ **Tests manquants** pour nouvelle feature
- ⚠️ **Migration** sans rollback

## 📤 LIVRABLES ATTENDUS
- Code backend fonctionnel et testé
- Migrations avec rollback
- Documentation des nouvelles méthodes
- Tests controller/model appropriés