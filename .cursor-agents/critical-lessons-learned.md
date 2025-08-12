# 🚨 LEÇONS CRITIQUES - À NE JAMAIS OUBLIER

## ⚠️ **RÈGLE ABSOLUE N°1 : CONTEXTE RÉEL FIRST**

### **INCIDENT DATE**: 2024-12-20

### **ERREUR CRITIQUE COMMISE**
L'assistant a proposé des seeds avec `first_name` et `last_name` alors que :
- ❌ La table `users` n'existait même pas dans la DB réelle
- ❌ Les migrations créées n'avaient pas été appliquées
- ❌ Le schema.rb montrait seulement une table `challenges` basique
- ❌ L'assistant travaillait sur du code théorique, pas réel

### **IMPACT**
- Seeds échec complet
- Perte de temps utilisateur  
- Frustration légitime
- Non-respect de la règle principale du Chef Ingénieur

### **PROCESSUS OBLIGATOIRE DÉSORMAIS**

#### ✅ **AVANT TOUTE IMPLÉMENTATION**
1. **`cat db/schema.rb`** - Voir les VRAIES tables
2. **`rails db:migrate:status`** - Migrations appliquées ?
3. **`grep/codebase_search`** - Models réels existants
4. **Vérifier Gemfile** - Dépendances installées
5. **Confirmer avec utilisateur** l'état réel

#### ✅ **QUESTIONS À POSER SYSTÉMATIQUEMENT**
- "Quelles migrations avez-vous déjà appliquées ?"
- "Montrez-moi votre schema.rb actuel"
- "Quel est l'état de votre DB ?"

#### ✅ **JAMAIS SUPPOSER**
- ❌ Que le code créé = code appliqué
- ❌ Que les migrations ont été runées
- ❌ Que les models existent
- ❌ Que Devise est configuré

### **MOTTO À RETENIR**
> "Le contexte RÉEL prime sur le code théorique, TOUJOURS."

### **SIGNATURE DE CETTE LEÇON**
Cette erreur ne se reproduira plus. Le Chef Ingénieur vérifiera TOUJOURS l'état réel avant de proposer quoi que ce soit.

---

**Date**: 2024-12-20  
**Sévérité**: CRITIQUE  
**Status**: MÉMORISÉ DÉFINITIVEMENT