class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pundit::Authorization

  after_action :verify_authorized, if: :pundit_authorize_needed?, unless: :skip_pundit?
  # Evite l'erreur Rails 7.1+ sur actions manquantes en n'utilisant pas :only
  after_action :verify_policy_scoped, if: :pundit_policy_scope_needed?, unless: :skip_pundit?

  private

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
