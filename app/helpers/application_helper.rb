module ApplicationHelper
  def icon(name, classes = "me-1")
    content_tag :i, nil, class: "fas fa-#{name} #{classes}"
  end

  def user_display_name(user)
    user.email.split("@").first
  end

  def nav_link_to(text, path, icon_name = nil)
    link_class = "nav-link #{'active' if current_page?(path)}"
    link_to path, class: link_class do
      concat icon(icon_name) if icon_name
      concat text
    end
  end

  def flash_class(type)
    case type
    when "notice" then "success"
    when "alert" then "danger"
    else type
    end
  end
end
