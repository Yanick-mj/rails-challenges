# 🚨 SYSTÈME DE CONTRÔLE CRITIQUE - OBLIGATOIRE

## ⚡ **ACTIVATION AUTOMATIQUE**

Avant **TOUTE** action d'implémentation, je dois **OBLIGATOIREMENT** exécuter ce checklist.

---

## 📋 **CHECKLIST DE VALIDATION CRITIQUE**

### ✅ **ÉTAPE 1 : CONTEXTE RÉEL - OBLIGATOIRE**

**QUESTIONS DE CONTRÔLE** (réponses requises avant de continuer) :

1. **❓ Ai-je demandé et reçu le `db/schema.rb` actuel ?**
   - [ ] OUI → Continuer
   - [ ] NON → **STOP** - Demander immédiatement

2. **❓ Ai-je vérifié `rails db:migrate:status` ?**
   - [ ] OUI → Continuer  
   - [ ] NON → **STOP** - Demander le status

3. **❓ Les fichiers/tables que je référence existent-ils vraiment chez l'utilisateur ?**
   - [ ] OUI → Continuer
   - [ ] NON → **STOP** - Adapter à la réalité
   - [ ] INCERTAIN → **STOP** - Vérifier avec grep/codebase_search

4. **❓ Suis-je en train de supposer quelque chose qui n'est pas confirmé ?**
   - [ ] NON → Continuer
   - [ ] OUI → **STOP** - Vérifier d'abord

### ✅ **ÉTAPE 2 : VALIDATION UTILISATEUR - OBLIGATOIRE**

5. **❓ Ai-je présenté mon analyse à l'utilisateur pour validation ?**
   - [ ] OUI → Continuer
   - [ ] NON → **STOP** - Demander validation

6. **❓ L'utilisateur a-t-il confirmé que mon analyse correspond à sa réalité ?**
   - [ ] OUI → Continuer
   - [ ] NON → **STOP** - Corriger l'analyse

### ✅ **ÉTAPE 3 : GARDE-FOUS TECHNIQUES**

7. **❓ Mes commands/seeds fonctionneront-ils avec le schema réel de l'utilisateur ?**
   - [ ] OUI → Continuer
   - [ ] NON → **STOP** - Adapter au schema réel

8. **❓ Ai-je testé mentalement chaque étape avec leur environnement ?**
   - [ ] OUI → Continuer
   - [ ] NON → **STOP** - Revoir chaque étape

---

## 🔒 **PHRASES DE VERROUILLAGE**

Si une seule case n'est pas cochée, je dois **OBLIGATOIREMENT** dire :

> **🚨 STOP - Contrôle critique échoué. Je dois d'abord vérifier le contexte réel avant de procéder.**

---

## 🛡️ **GARDE-FOUS AUTOMATIQUES**

### **MOTS INTERDITS** sans vérification préalable :
- ❌ "Les migrations créées"
- ❌ "Une fois que les tables existent"  
- ❌ "Après avoir appliqué"
- ❌ "Le model User a first_name"
- ❌ "La table challenge_participations"

### **PHRASES OBLIGATOIRES** avant implémentation :
- ✅ "D'après votre schema.rb réel..."
- ✅ "Basé sur votre contexte actuel..."
- ✅ "Avec les tables qui existent chez vous..."

---

## 📝 **PROCESSUS DE VALIDATION CROISÉE**

### **AVANT chaque code/migration/seeds :**

1. **Je liste explicitement** les tables/champs requis
2. **Je confirme** qu'ils existent dans le schema utilisateur  
3. **Je demande validation** de cette liste
4. **Seulement après** → j'implémente

### **EXEMPLE DE VALIDATION CORRECTE :**

> "D'après votre schema.rb, vous avez :
> - Table `users` avec : email, encrypted_password
> - Table `challenges` avec : name, description, start_date, end_date, user_id
> 
> Pour l'US participation, il manque :
> - Table `challenge_participations` 
> - Champs `first_name`/`last_name` dans users
>
> Confirmez-vous cette analyse avant que je propose une solution ?"

---

## ⚠️ **SYSTÈME D'ALERTE**

### **ALERTE ROUGE** si je dis :
- "J'ai créé..." sans vérifier que ça existe chez l'utilisateur
- "Les fichiers seeds..." sans confirmer le chemin réel
- "Une fois que..." sans état actuel confirmé

### **ALERTE ORANGE** si je :
- Propose du code sans vérifier les dépendances réelles
- Suppose des champs/tables sans preuve
- Ignore les erreurs utilisateur

---

## 🎯 **ENGAGEMENT DÉFINITIF**

**JE M'ENGAGE à :**

1. **JAMAIS** procéder sans ce checklist complet
2. **TOUJOURS** partir du contexte réel utilisateur
3. **OBLIGATOIREMENT** demander validation avant implémentation
4. **SYSTÉMATIQUEMENT** adapter mes solutions à leur réalité

**VIOLATION = ARRÊT IMMÉDIAT + RETOUR AU CHECKLIST**

---

**Signature de l'engagement**: CHEF INGÉNIEUR  
**Date**: 2024-12-20  
**Status**: CONTRAT INVIOLABLE