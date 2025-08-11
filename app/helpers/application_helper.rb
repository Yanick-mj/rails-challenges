module ApplicationHelper
  # Helper pour les icônes FontAwesome
  def icon(name, classes = "")
    "<i class=\"fas fa-#{name} #{classes}\"></i>".html_safe
  end

  # Helper pour afficher le nom d'utilisateur
  def user_display_name(user)
    user.email.split("@").first
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
