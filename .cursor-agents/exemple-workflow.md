# 📝 EXEMPLE WORKFLOW - Ajout de Categories aux Challenges

## 🎯 DEMANDE INITIALE UTILISATEUR
> "Je veux pouvoir organiser mes challenges par catégories (Sport, Lecture, Créativité, etc.)"

---

## 👨‍💼 CHEF INGÉNIEUR - ANALYSE & DÉCOMPOSITION

### 📊 ANALYSE DE LA DEMANDE
Ajouter un système de catégories pour classifier les challenges existants avec possibilité de filtrage et organisation.

### 🔍 CONTEXTE ACTUEL VÉRIFIÉ
- **Model Challenge** existant avec title, description, user_id
- **ChallengesController** avec index, show, new, create, edit, update, destroy
- **Views** organisées avec partials `_form.html.erb`, `_challenges_list.html.erb`
- **Pundit policies** en place pour autorisation
- **Bootstrap design system** établi
- **Stimulus controllers** pour interactions

### 📝 DÉCOMPOSITION DES TÂCHES

#### 🔧 **TÂCHES BACKEND** → Agent Backend
1. Créer model `Category` avec validations
2. Ajouter association `Challenge belongs_to :category`
3. Migration pour table categories + ajout category_id à challenges
4. Seeds pour catégories par défaut
5. Ajouter category_id aux strong params ChallengesController
6. Policy Pundit pour Category si nécessaire

#### 🎨 **TÂCHES FRONTEND** → Agent Frontend  
1. Ajouter select category dans `_form.html.erb`
2. Afficher category dans show et index challenges
3. Ajouter filtrage par catégorie avec Stimulus controller
4. Styling cohérent avec Bootstrap (badges, colors)

#### 🎯 **TÂCHES UX DESIGNER** → Agent UX Designer
1. Design du système de filtres (sidebar, dropdown, tags)
2. Code couleur par catégorie pour identification visuelle
3. UX de sélection catégorie dans formulaire
4. Flow de gestion des catégories (admin si nécessaire)

#### 🚀 **TÂCHES DEVOPS** → Agent DevOps
1. Migration deployment strategy (staging puis production)
2. Vérification compatibilité existant
3. Rollback plan si problème
4. Health check post-déploiement

### ✋ VALIDATION REQUISE
**Confirmez-vous cette analyse et décomposition avant que je procède ?**

---

## ✅ VALIDATION UTILISATEUR
> "Oui, c'est exactement ce que je veux. Procédez !"

---

## 🔧 AGENT BACKEND - IMPLÉMENTATION

### Model Category
```ruby
# app/models/category.rb
class Category < ApplicationRecord
  has_many :challenges, dependent: :nullify
  
  validates :name, presence: true, uniqueness: true
  validates :color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }
  
  scope :ordered, -> { order(:name) }
end
```

### Migration
```ruby
# db/migrate/xxx_create_categories.rb  
class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :color, null: false
      t.text :description
      t.timestamps
    end
    
    add_index :categories, :name, unique: true
  end
end

# db/migrate/xxx_add_category_to_challenges.rb
class AddCategoryToChallenges < ActiveRecord::Migration[7.0]
  def change
    add_reference :challenges, :category, null: true, foreign_key: true
  end
end
```

### Seeds & Controller Updates
```ruby
# db/seeds.rb - Ajout catégories
Category.find_or_create_by(name: "Sport") do |cat|
  cat.color = "#28a745"
  cat.description = "Défis sportifs et fitness"
end
# ... autres catégories

# app/controllers/challenges_controller.rb
private
def challenge_params
  params.require(:challenge).permit(:title, :description, :category_id)
end
```

---

## 🎨 AGENT FRONTEND - IMPLÉMENTATION

### Form Update
```erb
<!-- app/views/challenges/_form.html.erb -->
<div class="form-group mb-3">
  <label for="challenge_category_id" class="form-label">Catégorie</label>
  <%= f.collection_select :category_id, Category.ordered, :id, :name, 
      { prompt: "Sélectionnez une catégorie" }, 
      { class: "form-select" } %>
</div>
```

### Display & Filter
```erb
<!-- app/views/challenges/index.html.erb -->
<div class="filter-bar mb-4">
  <div data-controller="category-filter">
    <!-- Filtres catégories avec Stimulus -->
  </div>
</div>

<!-- Dans _challenges_list.html.erb -->
<% if challenge.category %>
  <span class="badge rounded-pill" style="background-color: <%= challenge.category.color %>">
    <%= challenge.category.name %>
  </span>
<% end %>
```

### Stimulus Controller
```javascript
// app/javascript/controllers/category_filter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Logique filtrage côté client
}
```

---

## 🎯 AGENT UX DESIGNER - RECOMMENDATIONS

### Design System
- **Badges colorés** pour identification rapide
- **Filtres sidebar** sur desktop, **dropdown** sur mobile  
- **Visual hierarchy** claire avec catégories
- **Accessibility** avec ARIA labels et high contrast

### User Flow
1. **Création challenge** → Sélection catégorie obligatoire
2. **Navigation** → Filtrage intuitif et rapide
3. **Administration** → Gestion catégories pour admins

---

## 🚀 AGENT DEVOPS - DÉPLOIEMENT

### Strategy
1. **Staging deployment** avec migration categories
2. **Data seeding** catégories par défaut
3. **Existing challenges** restent sans catégorie (nullable)
4. **Production deployment** après validation staging
5. **Health check** `/up` post-déploiement

---

## 👨‍💼 CHEF INGÉNIEUR - VALIDATION FINALE

### ✅ Solution Implémentée
- Model Category avec associations Rails propres
- Interface utilisateur cohérente avec design existant  
- Filtrage interactif avec Stimulus
- Migration safe avec rollback possible
- Tests controller et model ajoutés

### 🔍 Vérifications DRY & Simplicité
- ✅ Réutilisation composants Bootstrap existants
- ✅ Conventions Rails respectées
- ✅ Code factoriséable si expansion future
- ✅ Performance optimisée (includes sur queries)

### ✋ VALIDATION FINALE REQUISE
**La solution est prête. Validez-vous l'implémentation ?**