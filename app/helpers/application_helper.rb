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

    html.join.html_safe
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

    # Ne pas afficher le bouton si l'utilisateur est le créateur
    if challenge.user == current_user
      return content_tag :div, class: "text-center text-muted" do
        icon("crown") + " Vous êtes le créateur de ce challenge"
      end
    end

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
    return if challenge.user == current_user

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
        icon("user-plus") + " Participer"
      end
    else
      # Challenge complet ou autre raison
      content_tag :button,
                  icon("user-times") + " Complet",
                  class: "btn btn-secondary btn-sm",
                  disabled: true
    end
  end

  # Helper pour afficher les dates d'un challenge
  def challenge_dates_display(challenge, format: :compact)
    case format
    when :compact
      content_tag :div, class: "row g-2 mb-3" do
        concat(content_tag(:div, class: "col-md-6") do
          content_tag(:small, class: "text-dark") do
            icon("calendar-plus", "text-success me-1") + "Début: #{challenge.start_date&.strftime("%d/%m/%Y")}"
          end
        end)
        concat(content_tag(:div, class: "col-md-6") do
          content_tag(:small, class: "text-dark") do
            icon("calendar-check", "text-danger me-1") + "Fin: #{challenge.end_date&.strftime("%d/%m/%Y")}"
          end
        end)
      end
    when :detailed
      content_tag :div, class: "row g-4" do
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
              concat(content_tag(:strong, participants_counter(challenge), class: "fs-6"))
            end)
          end
        end)
      end
    end
  end

  # Composants CTA unifiés et DRY
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
