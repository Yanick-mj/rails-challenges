import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "error"]

  preview(event) {
    const file = event.target.files[0]
    if (file) {
      // 1. User load a file
      console.log("Fichier sélectionné:", file.name, file.size, file.type)

      // 2. Check image size (5MB = 5 * 1024 * 1024 bytes)
      const maxSize = 5 * 1024 * 1024
      if (file.size > maxSize) {
        this.showError("L'image est trop volumineuse (5MB maximum)")
        this.clearPreview()
        return
      }

      // 3. Check image type
      const acceptableTypes = ["image/png", "image/jpeg", "image/jpg"]
      if (!acceptableTypes.includes(file.type)) {
        this.showError("Format non supporté. Utilisez PNG, JPEG ou JPG")
        this.clearPreview()
        return
      }

      // 4. If check = ok, show preview
      this.hideError()
      const reader = new FileReader()
      reader.onload = (e) => {
        const previewImg = document.getElementById('avatar-preview')
        if (previewImg) {
          previewImg.src = e.target.result
          document.querySelector('.avatar-preview').style.display = 'block'
        }
      }
      reader.readAsDataURL(file)
    }
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.style.display = 'block'
    } else {
      // Créer un élément d'erreur si il n'existe pas
      const errorDiv = document.createElement('div')
      errorDiv.className = 'alert alert-danger mt-2'
      errorDiv.textContent = message
      this.inputTarget.parentNode.appendChild(errorDiv)
    }
  }

  hideError() {
    if (this.hasErrorTarget) {
      this.errorTarget.style.display = 'none'
    }
    // Supprimer les erreurs créées dynamiquement
    const errors = this.inputTarget.parentNode.querySelectorAll('.alert-danger')
    errors.forEach(error => error.remove())
  }

  clearPreview() {
    const previewDiv = document.querySelector('.avatar-preview')
    if (previewDiv) {
      previewDiv.style.display = 'none'
    }
    this.inputTarget.value = ''
  }
}
