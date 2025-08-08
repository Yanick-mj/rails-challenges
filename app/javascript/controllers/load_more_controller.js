import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "button", "count"]

  connect() {
    this.loading = false
    this.currentSort = this.buttonTarget?.dataset.sort || 'asc'
    console.log('🔗 Load more controller connecté')
    console.log('🔄 Tri initial:', this.currentSort)
  }

  // Nouvelle méthode pour changer de tri
  changeSort(event) {
    event.preventDefault()
    const newSort = event.currentTarget.dataset.sort

    console.log('🔄 Changement de tri vers:', newSort)

    // Mettre à jour l'état actif des boutons
    this.element.querySelectorAll('[data-sort]').forEach(btn => {
      btn.classList.remove('active')
    })
    event.currentTarget.classList.add('active')

    // Réinitialiser la pagination
    this.currentSort = newSort
    this.resetPagination()

    // Charger les challenges avec le nouveau tri
    this.loadChallenges(newSort, 1)
  }

  // Méthode pour réinitialiser la pagination
  resetPagination() {
    if (this.buttonTarget) {
      this.buttonTarget.dataset.page = '2'
      this.buttonTarget.dataset.sort = this.currentSort
      this.buttonTarget.style.display = 'block'
      this.buttonTarget.disabled = false
      this.buttonTarget.innerHTML = '<i class="fas fa-plus me-2"></i>Charger plus de challenges'
    }
  }

  // Méthode pour charger les challenges
  loadChallenges(sort, page) {
    const url = `/challenges?page=${page}&sort=${sort}`
    console.log('🌐 Chargement des challenges:', url)

    fetch(url, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      // Remplacer le contenu existant
      this.containerTarget.innerHTML = html

      // Réinitialiser le compteur
      const challengeCount = this.containerTarget.querySelectorAll('.challenge-item').length
      this.countTarget.textContent = `${challengeCount} / ${this.countTarget.textContent.split('/')[1]}`

      console.log('✅ Challenges chargés avec le nouveau tri')
    })
    .catch(error => {
      console.error('❌ Erreur lors du changement de tri:', error)
    })
  }

  loadMore(event) {
    event.preventDefault()
    console.log('🖱️ Bouton Load More cliqué!')

    if (this.loading) {
      console.log('⏳ Déjà en cours de chargement, ignoré')
      return
    }

    const button = event.currentTarget
    const nextPage = button.dataset.page
    const currentSort = button.dataset.sort

    console.log('📄 Page suivante:', nextPage)
    console.log('🔄 Tri actuel:', currentSort)

    this.loading = true
    button.disabled = true
    button.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Chargement...'

    const url = `/challenges?page=${nextPage}&sort=${currentSort}`
    console.log('🌐 URL de requête:', url)

    fetch(url, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => {
      console.log('📡 Status de réponse:', response.status)
      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`)
      }
      return response.text()
    })
    .then(html => {
      console.log('📄 HTML reçu, longueur:', html.length)

      if (html.trim() === '') {
        console.log('⚠️ Aucun contenu reçu, masquage du bouton')
        button.style.display = 'none'
        this.loading = false
        return
      }

      // Ajouter les nouveaux challenges à la liste
      this.containerTarget.insertAdjacentHTML('beforeend', html)
      console.log('✅ Nouveaux challenges ajoutés au container')

      // Mise à jour du compteur
      const currentCount = parseInt(this.countTarget.textContent.split('/')[0])
      const totalCount = this.countTarget.textContent.split('/')[1]
      const newCount = currentCount + 10
      this.countTarget.textContent = `${newCount} / ${totalCount}`
      console.log('📊 Compteur mis à jour:', newCount)

      // Mise à jour du bouton
      button.dataset.page = parseInt(nextPage) + 1
      button.disabled = false
      button.innerHTML = '<i class="fas fa-plus me-2"></i>Charger plus de challenges'
      console.log(' Bouton mis à jour, page suivante:', button.dataset.page)

      // Vérifier s'il y a encore des challenges à charger
      if (newCount >= parseInt(totalCount)) {
        console.log('🏁 Tous les challenges chargés, masquage du bouton')
        button.style.display = 'none'
      }

      this.loading = false
    })
    .catch(error => {
      console.error('❌ Erreur lors du chargement:', error)
      button.disabled = false
      button.innerHTML = '<i class="fas fa-exclamation-triangle me-2"></i>Erreur - Réessayer'
      this.loading = false
    })
  }
}
