module ApplicationHelper
  # Helper pour les icônes FontAwesome
  def icon(name, classes = "")
    "<i class=\"fas fa-#{name} #{classes}\"></i>".html_safe
  end

  # Helper pour afficher le nom d'utilisateur
  def user_display_name(user)
    if user.last_name.present?
      user.last_name
    elsif user.first_name.present?
      user.first_name
    else
      # Fallback vers l'email si aucun nom n'est défini
      user.email.split("@").first.capitalize
    end
  end

  # Helper DRY pour les champs de formulaire utilisateur
  def user_form_fields(form, options = {})
    show_name_fields = options[:show_name_fields] || false
    autofocus_email = options[:autofocus_email] || false
    show_avatar = options[:show_avatar] || false
    current_avatar = options[:current_avatar] || nil

    html = []

    if show_name_fields
      html << content_tag(:div, class: "form-group mb-3") do
        content_tag(:div, class: "input-group") do
          concat(content_tag(:span, class: "input-group-text") do
            icon("user")
          end)
          concat(form.text_field(:first_name,
            autofocus: !autofocus_email,
            autocomplete: "given-name",
            class: "form-control",
            placeholder: "Prénom"))
        end
      end

      html << content_tag(:div, class: "form-group mb-3") do
        content_tag(:div, class: "input-group") do
          concat(content_tag(:span, class: "input-group-text") do
            icon("user")
          end)
          concat(form.text_field(:last_name,
            autocomplete: "family-name",
            class: "form-control",
            placeholder: "Nom de famille"))
        end
      end
    end

    html << content_tag(:div, class: "form-group mb-3") do
      content_tag(:div, class: "input-group") do
        concat(content_tag(:span, class: "input-group-text") do
          icon("envelope")
        end)
        concat(form.email_field(:email,
          autofocus: autofocus_email,
          autocomplete: "email",
          class: "form-control",
          placeholder: "Votre email"))
      end
    end

    # Champ avatar DRY
    if show_avatar
      html << avatar_field(form, current_avatar)
    end

    html.join.html_safe
  end

  # Helper DRY pour le champ avatar
  def avatar_field(form, current_avatar = nil)
    content_tag(:div, class: "form-group mb-3") do
      html = []

      # Label
      html << content_tag(:label, class: "form-label") do
        concat(icon("camera", "me-2"))
        concat("Photo de profil")
        concat(content_tag(:span, " (optionnel)", class: "text-muted")) if current_avatar.nil?
      end

      # Avatar actuel (si édition)
      if current_avatar&.attached? && current_avatar.blob&.key.present?
        html << content_tag(:div, class: "current-avatar mb-3") do
          concat(image_tag(current_avatar,
                          class: "rounded-circle",
                          style: "width: 100px; height: 100px; object-fit: cover;"))
          concat(content_tag(:small, "Avatar actuel", class: "d-block text-muted"))
        end
      end

      # Champ fichier
      html << form.file_field(:avatar,
        class: "form-control",
        accept: "image/*",
        data: {
          preview_target: "input",
          action: "change->avatar#preview"
        })

      # Aide
      help_text = current_avatar&.attached? ?
        "Laissez vide pour conserver l'image actuelle" :
        "Formats acceptés : PNG, JPG, JPEG. Taille max : 5MB"

      html << content_tag(:small, help_text, class: "form-text text-muted")

      # Prévisualisation
      html << content_tag(:div, class: "avatar-preview mb-3", style: "display: none;") do
        image_tag("", id: "avatar-preview",
                 class: "rounded-circle",
                 style: "width: 100px; height: 100px; object-fit: cover;")
      end

      concat(html.join.html_safe)
    end
  end

  # Helper pour afficher l'avatar utilisateur
  def user_avatar(user, options = {}, size: 40)
    # Vérifier que l'utilisateur existe et a un avatar attaché de manière sécurisée
    if user&.persisted? && user.avatar.attached? && user.avatar.blob&.key.present?
      begin
        image_tag user.avatar,
                  class: "rounded-circle #{options[:class]}",
                  style: "width: #{size}px; height: #{size}px; object-fit: cover; #{options[:style]}",
                  alt: "Avatar de #{user_display_name(user)}"
      rescue => e
        # En cas d'erreur avec l'avatar, afficher l'icône par défaut
        Rails.logger.warn "Erreur avec l'avatar de l'utilisateur #{user.id}: #{e.message}"
        default_avatar_icon(options, size)
      end
    else
      # Avatar par défaut avec icône FontAwesome
      default_avatar_icon(options, size)
    end
  end

  # Helper spécialisé pour l'affichage des participants
  def participant_avatar(participant, options = {}, size: 48)
    # Vérifier si le participant a un avatar valide
    if participant&.persisted? && participant.avatar.attached? && participant.avatar.blob&.key.present?
      begin
        image_tag participant.avatar,
                  class: "rounded-circle #{options[:class]}",
                  style: "width: #{size}px; height: #{size}px; object-fit: cover; #{options[:style]}",
                  alt: "Avatar de #{user_display_name(participant)}",
                  loading: "lazy"
      rescue => e
        Rails.logger.warn "Erreur avec l'avatar du participant #{participant.id}: #{e.message}"
        participant_default_avatar(options, size)
      end
    else
      participant_default_avatar(options, size)
    end
  end

  private

  def default_avatar_icon(options, size)
    content_tag :div,
                icon("user"),
                class: "rounded-circle bg-primary text-white d-flex align-items-center justify-content-center #{options[:class]}",
                style: "width: #{size}px; height: #{size}px; font-size: #{size * 0.4}px; #{options[:style]}"
  end

  def participant_default_avatar(options, size)
    content_tag :div,
                icon("user"),
                class: "rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center #{options[:class]}",
                style: "width: #{size}px; height: #{size}px; font-size: #{size * 0.4}px; #{options[:style]}"
  end

  # Helper pour les classes CSS des messages flash
  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "success"
    when :error, :alert
      "danger"
    when :warning
      "warning"
    when :info
      "info"
    else
      "primary"
    end
  end

  # Helper pour afficher le compteur de participants
  def participants_counter(challenge)
    counter = "#{challenge.participants.count}/10"

    # Ajouter un indicateur si l'utilisateur participe
    if user_signed_in? && challenge.participants.include?(current_user)
      counter += " (Vous participez)"
    end

    counter
  end

  # Helper pour le bouton de participation
  def participation_button(challenge)
    return unless user_signed_in?

    if challenge.participants.include?(current_user)
      # L'utilisateur participe déjà
      button_to leave_challenge_path(challenge),
                method: :delete,
                class: "btn btn-danger",
                data: { confirm: "Voulez-vous vraiment quitter ce challenge ?" } do
        icon("user-minus") + " Quitter le challenge"
      end
    elsif challenge.can_participate?(current_user)
      # L'utilisateur peut participer
      button_to participate_challenge_path(challenge),
                method: :post,
                class: "btn btn-success" do
        icon("user-plus") + " Rejoindre le challenge"
      end
    elsif challenge.full?
      # Challenge complet
      content_tag :div, class: "text-center text-muted" do
        icon("users") + " Challenge complet (10/10 participants)"
      end
    else
      # Autre raison (déjà participé, etc.)
      content_tag :div, class: "text-center text-muted" do
        icon("user-times") + " Participation non disponible"
      end
    end
  end

  # Helper pour le bouton de participation compact (pour les cards)
  def participation_button_compact(challenge)
    return unless user_signed_in?

    if challenge.participants.include?(current_user)
      # L'utilisateur participe déjà - bouton quitter compact
      button_to leave_challenge_path(challenge),
                method: :delete,
                class: "btn btn-danger btn-sm",
                data: { confirm: "Quitter ce challenge ?" } do
        icon("user-minus") + " Quitter"
      end
    elsif challenge.can_participate?(current_user)
      # L'utilisateur peut participer
      button_to participate_challenge_path(challenge),
                method: :post,
                class: "btn btn-success btn-sm" do
        icon("user-plus") + " Rejoindre"
      end
    elsif challenge.full?
      # Challenge complet
      content_tag :span, class: "badge bg-danger" do
        icon("lock") + " Complet"
      end
    else
      # Autre raison
      content_tag :span, class: "badge bg-secondary" do
        icon("user-times") + " Indisponible"
      end
    end
  end

  # Helper pour afficher les dates des challenges
  def challenge_dates_display(challenge, format: :compact)
    case format
    when :compact
      content_tag(:div, class: "d-flex align-items-center text-muted small") do
        concat(icon("calendar-alt", "me-1"))
        concat("Du #{challenge.start_date.strftime('%d/%m/%Y')} au #{challenge.end_date.strftime('%d/%m/%Y')}")
      end
    when :detailed
      content_tag(:div, class: "row g-4") do
        concat(content_tag(:div, class: "col-md-4") do
          content_tag(:div, class: "d-flex align-items-center p-3 bg-light rounded") do
            concat(content_tag(:div, class: "me-3") do
              icon("calendar-plus", "text-success fs-4")
            end)
            concat(content_tag(:div) do
              concat(content_tag(:small, "Date de début", class: "text-dark d-block"))
              concat(content_tag(:strong, challenge.start_date.strftime("%d/%m/%Y"), class: "fs-6"))
            end)
          end
        end)
        concat(content_tag(:div, class: "col-md-4") do
          content_tag(:div, class: "d-flex align-items-center p-3 bg-light rounded") do
            concat(content_tag(:div, class: "me-3") do
              icon("calendar-check", "text-danger fs-4")
            end)
            concat(content_tag(:div) do
              concat(content_tag(:small, "Date de fin", class: "text-dark d-block"))
              concat(content_tag(:strong, challenge.end_date.strftime("%d/%m/%Y"), class: "fs-6"))
            end)
          end
        end)
        concat(content_tag(:div, class: "col-md-4") do
          content_tag(:div, class: "d-flex align-items-center p-3 bg-light rounded") do
            concat(content_tag(:div, class: "me-3") do
              icon("users", "text-primary fs-4")
            end)
            concat(content_tag(:div) do
              concat(content_tag(:small, "Participants", class: "text-dark d-block"))
              concat(content_tag(:strong, "#{challenge.participants.count}/10", class: "fs-6"))
            end)
          end
        end)
      end
    end
  end

  # Helpers pour les boutons CTA
  def cta_button(text, url = nil, options = {})
    variant = options.delete(:variant) || :primary
    size = options.delete(:size) || :md
    icon_name = options.delete(:icon)

    classes = cta_button_classes(variant, size)
    options[:class] = "#{classes} #{options[:class]}".strip

    if url
      link_to url, options do
        content = []
        content << icon(icon_name) if icon_name
        content << text
        content.join(" ").html_safe
      end
    else
      button_tag options do
        content = []
        content << icon(icon_name) if icon_name
        content << text
        content.join(" ").html_safe
      end
    end
  end

  def cta_submit(text, options = {})
    variant = options.delete(:variant) || :primary
    size = options.delete(:size) || :md
    icon_name = options.delete(:icon)

    classes = cta_button_classes(variant, size)
    options[:class] = "#{classes} #{options[:class]}".strip

    submit_tag text, options
  end

  # Helpers spécialisés DRY par contexte
  def action_button(action, url, text = nil, options = {})
    action_config = {
      create: { variant: :primary, icon: "plus" },
      edit: { variant: :secondary, icon: "edit" },
      delete: { variant: :danger, icon: "trash", size: :sm },
      view: { variant: :secondary, icon: "eye" },
      back: { variant: :secondary, icon: "arrow-left" },
      save: { variant: :primary, icon: "save" },
      cancel: { variant: :secondary, icon: "times" },
      login: { variant: :primary, icon: "sign-in-alt" },
      signup: { variant: :warning, icon: "user-plus" },
      logout: { variant: :danger, icon: "sign-out-alt" }
    }

    config = action_config[action.to_sym] || { variant: :primary }
    text ||= action.to_s.humanize

    cta_button(text, url, options.merge(config))
  end

  def sort_button(direction, url, options = {})
    icon_map = { asc: "sort-amount-up", desc: "sort-amount-down" }
    text_map = { asc: "Ancien", desc: "Récent" }

    cta_button(
      text_map[direction.to_sym],
      url,
      options.merge(
        variant: :secondary,
        icon: icon_map[direction.to_sym]
      )
    )
  end

  private

  def cta_button_classes(variant, size)
    base_classes = "btn"
    variant_classes = cta_variant_classes(variant)
    size_classes = cta_size_classes(size)

    "#{base_classes} #{variant_classes} #{size_classes}".strip
  end

  def cta_variant_classes(variant)
    case variant.to_sym
    when :primary
      "btn-primary"
    when :secondary
      "btn-outline-secondary"
    when :success
      "btn-success"
    when :danger
      "btn-danger"
    when :warning
      "btn-warning"
    when :info
      "btn-info"
    when :light
      "btn-outline-light"
    when :dark
      "btn-outline-dark"
    else
      "btn-primary"
    end
  end

  def cta_size_classes(size)
    case size.to_sym
    when :sm
      "btn-sm"
    when :lg
      "btn-lg"
    else
      "" # md par défaut
    end
  end
end
