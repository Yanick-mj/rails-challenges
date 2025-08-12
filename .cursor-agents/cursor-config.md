# ⚙️ CONFIGURATION CURSOR - Agents Rails Challenge

## 🚀 ACTIVATION DES AGENTS

### Dans Cursor Settings (.cursor/settings.json)

```json
{
  "cursor.agents": {
    "chef-ingenieur": {
      "rules_file": ".cursor-agents/chef-ingenieur-rules.md",
      "role": "principal",
      "description": "Orchestrateur et interface utilisateur unique"
    },
    "backend": {
      "rules_file": ".cursor-agents/backend-agent-rules.md", 
      "role": "specialist",
      "description": "Expert Rails backend et logique métier"
    },
    "frontend": {
      "rules_file": ".cursor-agents/frontend-agent-rules.md",
      "role": "specialist", 
      "description": "Expert views ERB, Stimulus et Bootstrap"
    },
    "ux-designer": {
      "rules_file": ".cursor-agents/ux-designer-agent-rules.md",
      "role": "specialist",
      "description": "Expert interface et expérience utilisateur"
    },
    "devops": {
      "rules_file": ".cursor-agents/devops-agent-rules.md",
      "role": "specialist",
      "description": "Expert déploiement et infrastructure"
    }
  }
}
```

## 🎯 COMMANDES ACTIVATION

### Pour activer le Chef Ingénieur
```
@chef-ingenieur [votre demande]
```

### Pour activer un agent spécialisé directement
```
@backend [tâche backend]
@frontend [tâche frontend] 
@ux-designer [tâche ux]
@devops [tâche devops]
```

## 📝 RÈGLES D'UTILISATION

### 1. Workflow Recommandé
```
Vous → @chef-ingenieur → Validation → Agents → Validation finale
```

### 2. Workflow Direct (cas simples)
```
Vous → @backend/@frontend/@ux-designer/@devops → Solution
```

### 3. Exemples Concrets

#### Nouvelle fonctionnalité complète
```
@chef-ingenieur Je veux ajouter un système de notifications aux challenges
```

#### Tâche backend spécifique
```
@backend Optimise les requêtes N+1 dans ChallengesController#index
```

#### Amélioration UX
```
@ux-designer Améliore l'ergonomie du formulaire de création de challenge
```

#### Problème déploiement
```
@devops Les migrations ne passent pas en staging, aide-moi à diagnostiquer
```

## 🔄 HANDOFF ENTRE AGENTS

Le Chef Ingénieur utilise ces patterns pour déléguer:

```markdown
## Assignation Backend
@backend Implémente le model Comment avec les spécifications suivantes:
- Association belongs_to :challenge, :user
- Validations presence title, body
- Scope recent pour affichage

## Assignation Frontend  
@frontend Crée l'interface commentaires avec:
- Partial _comment.html.erb
- Form ajout commentaire en AJAX
- Stimulus controller pour interactions

## Assignation UX Designer
@ux-designer Conçois le flow d'interaction:
- Placement commentaires sur page challenge
- UX ajout/modification/suppression
- Responsive design mobile

## Assignation DevOps
@devops Prépare le déploiement:
- Migration Comment model
- Validation staging environment
- Strategy rollback si problème
```

## ⚠️ BONNES PRATIQUES

### ✅ À FAIRE
- Toujours commencer par le Chef Ingénieur pour nouvelles features
- Valider chaque étape avant de procéder
- Utiliser les agents spécialisés pour expertise précise
- Documenter les décisions importantes

### ❌ À ÉVITER
- Bypasser la validation du Chef Ingénieur sur gros projets
- Mélanger les responsabilités entre agents
- Procéder sans contexte réel du projet
- Ignorer les règles DRY et simplicité

## 🎯 PERSONNALISATION

Vous pouvez modifier les fichiers de règles pour:
- Ajouter des conventions spécifiques à votre équipe
- Intégrer des outils particuliers (CI/CD, monitoring)
- Adapter aux contraintes de votre infrastructure
- Personnaliser le niveau de validation requis