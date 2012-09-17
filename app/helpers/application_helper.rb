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

 # 	def new_child_fields_template(form_builder, association, options = {})
 #  		options[:object] ||= form_builder.object.class.reflect_on_association(association).klass.new
 #  		options[:partial] ||= association.to_s.singularize
 #  		options[:form_builder_local] ||= :f

 #  		content_for :jstemplates do
 #    		content_tag(:div, :id => "#{association}_fields_template", :style => "display: none") do
 #      			form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |f|        
 #        			render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })        
 #      			end
 #    		end
 #  		end
	# end

	# def add_child_link(name, association)
 #  		link_to(name, "javascript:void(0)", :class => "add_child", :"data-association" => association)
	# end

	# def remove_child_link(name, f)
 #  		f.hidden_field(:_destroy) + link_to(name, "javascript:void(0)", :class => "remove_child")
	# end


end