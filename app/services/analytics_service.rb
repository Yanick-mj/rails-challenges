# Service pour gérer le tracking analytics de manière DRY
class AnalyticsService
  class << self
    # Track un événement avec les propriétés utilisateur
    def track_event(user, event_name, properties = {})
      return unless $mixpanel

      # Propriétés de base pour tous les événements
      base_properties = {
        user_id: user&.id,
        user_email: user&.email,
        timestamp: Time.current.iso8601,
        environment: Rails.env
      }

      # Fusionner les propriétés de base avec les propriétés spécifiques
      event_properties = base_properties.merge(properties)

      # Track l'événement
      $mixpanel.track(user&.id || "anonymous", event_name, event_properties)

      # Log en développement
      if Rails.env.development?
        Rails.logger.info "📊 ANALYTICS: #{event_name} - #{event_properties}"
        puts "📊 ANALYTICS: #{event_name} envoyé à Mixpanel"
      end
    end

    # ========================================
    # ÉVÉNEMENTS DE LOGIN
    # ========================================

    # Track l'arrivée sur la page de login
    def track_start_login(user = nil)
      track_event(user, "Start Login", {
        page: "login",
        session_id: SecureRandom.uuid
      })
    end

    # Track la connexion réussie
    def track_complete_login(user)
      track_event(user, "Complete Login", {
        login_method: "email",
        success: true,
        user_type: "existing_user"
      })
    end

    # Track l'échec de connexion
    def track_login_failed(email)
      track_event(nil, "Login Failed", {
        login_method: "email",
        attempted_email: email,
        success: false
      })
    end

    # ========================================
    # ÉVÉNEMENTS DE SIGNUP
    # ========================================

    # Track l'arrivée sur la page d'inscription
    def track_start_signup(user = nil)
      track_event(user, "Start Signup", {
        page: "signup",
        session_id: SecureRandom.uuid
      })
    end

    # Track l'inscription réussie
    def track_complete_signup(user)
      track_event(user, "Complete Signup", {
        registration_method: "email",
        user_type: "new_user",
        has_avatar: user.avatar.attached?
      })
    end

    # Track l'échec d'inscription
    def track_signup_failed(email, errors = {})
      track_event(nil, "Signup Failed", {
        registration_method: "email",
        attempted_email: email,
        success: false,
        error_types: errors.is_a?(Hash) ? errors.keys : errors.full_messages,
        error_count: errors.count
      })
    end

    # ========================================
    # ÉVÉNEMENTS DE CHALLENGE
    # ========================================

    # Track la création de challenge
    def track_challenge_created(user, challenge)
      track_event(user, "Challenge Created", {
        challenge_id: challenge.id,
        challenge_name: challenge.name,
        max_participants: challenge.max_participants,
        start_date: challenge.start_date,
        end_date: challenge.end_date,
        duration_days: (challenge.end_date - challenge.start_date).to_i
      })
    end

    # Track la participation à un challenge (rejoindre)
    def track_challenge_joined(user, challenge)
      track_event(user, "Challenge Joined", {
        challenge_id: challenge.id,
        challenge_name: challenge.name,
        action: "joined",
        current_participants: challenge.participants.count,
        max_participants: challenge.max_participants,
        is_creator: challenge.user_id == user.id,
        participation_rank: challenge.participants.count # Ordre d'arrivée
      })
    end

    # Track le départ d'un challenge (quitter)
    def track_challenge_left(user, challenge)
      track_event(user, "Challenge Left", {
        challenge_id: challenge.id,
        challenge_name: challenge.name,
        action: "left",
        current_participants: challenge.participants.count,
        max_participants: challenge.max_participants,
        is_creator: challenge.user_id == user.id,
        time_in_challenge: calculate_time_in_challenge(user, challenge)
      })
    end

    # Track la modification d'un challenge
    def track_challenge_updated(user, challenge, changes = {})
      track_event(user, "Challenge Updated", {
        challenge_id: challenge.id,
        challenge_name: challenge.name,
        updated_fields: changes.keys,
        changes: changes,
        is_creator: challenge.user_id == user.id
      })
    end

    # Track la suppression d'un challenge
    def track_challenge_deleted(user, challenge)
      track_event(user, "Challenge Deleted", {
        challenge_id: challenge.id,
        challenge_name: challenge.name,
        final_participants_count: challenge.participants.count,
        is_creator: challenge.user_id == user.id
      })
    end

    # ========================================
    # ÉVÉNEMENTS D'ERREUR
    # ========================================

    # Track les erreurs de validation
    def track_validation_error(user, model_name, errors)
      track_event(user, "Validation Error", {
        model: model_name,
        error_count: errors.count,
        error_types: errors.full_messages,
        error_messages: errors.full_messages
      })
    end

    # Track les erreurs générales
    def track_error(user, error_type, error_message, context = {})
      track_event(user, "Error Occurred", {
        error_type: error_type,
        error_message: error_message,
        context: context
      })
    end

    private

    # Calculer le temps passé dans un challenge
    def calculate_time_in_challenge(user, challenge)
      participation = challenge.challenge_participations.find_by(user: user)
      return 0 unless participation&.created_at

      ((Time.current - participation.created_at) / 1.day).round(1) # En jours
    end
  end
end
