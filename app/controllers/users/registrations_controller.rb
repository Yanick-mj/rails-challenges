class Users::RegistrationsController < Devise::RegistrationsController
  # GET /resource/sign_up
  def new
    AnalyticsService.track_start_signup
    super
  end

  # POST /resource
  def create
    # Track l'échec d'inscription avant la tentative
    email = params[:user][:email] if params[:user]

    # Appeler la méthode parent
    super do |user|
      if user&.persisted?
        AnalyticsService.track_complete_signup(user)
      else
        AnalyticsService.track_signup_failed(email, user&.errors || {})
      end
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    Rails.logger.info "🔍 UPDATE - Paramètres reçus: #{params[:user].except('password', 'password_confirmation', 'current_password')}"

    basic_fields_only = basic_fields_only?
    update_successful = attempt_user_update(basic_fields_only)

    handle_update_result(update_successful, basic_fields_only)
  end

  # DELETE /resource
  def destroy
    # Track la suppression de compte
    AnalyticsService.track_event(current_user, "Account Deleted", {
      account_age_days: ((Time.current - current_user.created_at) / 1.day).round(1),
      had_avatar: current_user.avatar.attached?,
      challenges_created: current_user.challenges.count,
      challenges_participated: current_user.challenge_participations.count
    })

    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :avatar ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :avatar ])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    super(resource)
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end

  def after_update_path_for(resource)
    root_path
  end

  private

  def handle_update_result(update_successful, basic_fields_only)
    if update_successful
      log_successful_update(basic_fields_only)
      handle_post_update_actions
    else
      handle_update_error
    end
  end

  def redirect_after_successful_update
    notice_message = params[:user][:password].present? ?
      "Profil et mot de passe mis à jour avec succès !" :
      "Profil mis à jour avec succès !"

    redirect_to root_path, notice: notice_message
  end

  def process_avatar_upload(avatar_file)
    begin
      replace_avatar(avatar_file)
      if resource.save
        redirect_to root_path, notice: "Profil et photo de profil mis à jour avec succès !"
      else
        render :edit
      end
    rescue => e
      Rails.logger.error "Erreur lors de la mise à jour de l'avatar: #{e.message}"
      handle_avatar_error("Erreur lors du traitement de l'image")
    end
  end

  def basic_fields_only?
    password_fields = [ "password", "password_confirmation", "current_password" ]
    user_params = params[:user] || {}

    # Vérifier si seuls les champs de base sont présents
    basic_fields_present = user_params[:first_name].present? ||
                          user_params[:last_name].present? ||
                          user_params[:email].present?

    password_fields_present = password_fields.any? { |field| user_params[field].present? }

    basic_fields_present && !password_fields_present
  end

  def attempt_user_update(basic_fields_only)
    if basic_fields_only
      resource.update(account_update_params.except(:password, :password_confirmation, :current_password))
    else
      resource.update_with_password(account_update_params)
    end
  end

  def log_successful_update(basic_fields_only)
    if basic_fields_only
      Rails.logger.info "✅ Mise à jour réussie (champs de base uniquement)"
    else
      Rails.logger.info "✅ Mise à jour réussie (avec mot de passe)"
    end
  end

  def handle_post_update_actions
    if params[:user][:avatar].present?
      handle_avatar_update
    else
      redirect_after_successful_update
    end
  end

  def handle_update_error
    Rails.logger.error "❌ Erreur lors de la mise à jour: #{resource.errors.full_messages.join(', ')}"
    render :edit, status: :unprocessable_entity
  end

  def handle_avatar_update
    avatar_file = params[:user][:avatar]

    if avatar_too_large?(avatar_file)
      handle_avatar_error("L'image est trop volumineuse (max 5MB)")
      return
    end

    if !valid_avatar_type?(avatar_file)
      handle_avatar_error("Format d'image non supporté (JPG, PNG, GIF uniquement)")
      return
    end

    process_avatar_upload(avatar_file)
  end

  def avatar_too_large?(avatar_file)
    avatar_file.size > 5.megabytes
  end

  def valid_avatar_type?(avatar_file)
    %w[image/jpeg image/png image/gif].include?(avatar_file.content_type)
  end

  def handle_avatar_error(message)
    resource.errors.add(:avatar, message)
    render :edit, status: :unprocessable_entity
  end

  def replace_avatar(avatar_file)
    resource.avatar.purge if resource.avatar.attached?
    resource.avatar.attach(avatar_file)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :avatar)
  end
end
