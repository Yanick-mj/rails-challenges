class ApplicationController < ActionController::Base
  # Removed allow_browser restriction to support mobile browsers
  include Pundit::Authorization

  after_action :verify_authorized, if: :pundit_authorize_needed?, unless: :skip_pundit?
  # Evite l'erreur Rails 7.1+ sur actions manquantes en n'utilisant pas :only
  after_action :verify_policy_scoped, if: :pundit_policy_scope_needed?, unless: :skip_pundit?

  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :avatar ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :avatar ])
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def pundit_policy_scope_needed?
    action_name == "index"
  end

  def pundit_authorize_needed?
    action_name != "index"
  end
end
