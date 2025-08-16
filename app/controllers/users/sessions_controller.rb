class Users::SessionsController < Devise::SessionsController
  # GET /resource/sign_in
  def new
    AnalyticsService.track_start_login
    super
  end

  # POST /resource/sign_in
  def create
    # Track l'échec de connexion avant la tentative
    email = params[:user][:email] if params[:user]

    # Appeler la méthode parent
    super do |user|
      if user&.persisted?
        AnalyticsService.track_complete_login(user)
      else
        AnalyticsService.track_login_failed(email)
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    # Track la déconnexion
    AnalyticsService.track_event(current_user, "User Logout", {
      logout_method: "manual",
      session_duration: calculate_session_duration
    })

    super
  end

  private

  def calculate_session_duration
    return 0 unless session[:login_time]

    login_time = Time.parse(session[:login_time])
    ((Time.current - login_time) / 1.minute).round(1) # En minutes
  end
end
