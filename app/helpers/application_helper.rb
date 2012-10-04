module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "We Vote Here"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    image_tag(gravatar_url, alt: user.pretty_name, class: "gravatar")
  end


  def you_arent(user, current_user, caps=true)
    if user == current_user
      if caps
        return "You aren't"
      else
        return "you aren't"
      end
    else
      return user.pretty_name + " isn't"
    end
  end

  def you_dont(user, current_user, caps=true)
    if user == current_user
      if caps
        return "You don't"
      else
        return "you don't"
      end
    else
      return user.pretty_name + " doesn't"
    end
  end


end