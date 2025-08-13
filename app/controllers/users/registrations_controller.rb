class Users::RegistrationsController < Devise::RegistrationsController
  # POST /resource
  def create
    super
  end

  # PUT /resource
  def update
    # Logique pour l'édition de l'image de profil
    if params[:user][:avatar].present?
      handle_avatar_update
    else
      super
    end
  end

  # DELETE /resource
  def destroy
    super
  end

  protected

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  private

  def handle_avatar_update
    # 1. User load a file
    avatar_file = params[:user][:avatar]

    # 2. Check image size
    if avatar_file.size > 5.megabytes
      resource.errors.add(:avatar, "est trop volumineux (5MB maximum)")
      render :edit and return
    end

    # 3. Check image type
    acceptable_types = [ "image/png", "image/jpeg", "image/jpg" ]
    unless acceptable_types.include?(avatar_file.content_type)
      resource.errors.add(:avatar, "doit être une image PNG, JPEG ou JPG")
      render :edit and return
    end

    # 4. If check = ok, save the image
    begin
      # Supprimer l'ancien avatar s'il existe
      resource.avatar.purge if resource.avatar.attached?

      # Attacher le nouvel avatar
      resource.avatar.attach(avatar_file)

      # Sauvegarder l'utilisateur
      if resource.save
        # 5. Update du profile show + navbar
        redirect_to edit_user_registration_path, notice: "Photo de profil mise à jour avec succès !"
      else
        render :edit
      end
    rescue => e
      Rails.logger.error "Erreur lors de la mise à jour de l'avatar: #{e.message}"
      resource.errors.add(:avatar, "Erreur lors du traitement de l'image")
      render :edit
    end
  end
end
