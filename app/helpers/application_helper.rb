module ApplicationHelper
  def errors_full_html(obj, desc)
    html = ""
    if !obj.nil? and obj.respond_to?(:errors) and !obj.errors.empty?
      html = "#{desc}:"
      html << "<ul>"
      obj.errors.full_messages.each { |msg|
        html << "<li>#{msg}</li>"
      } # end obj.errors.full_messages.each ...
      html << "</ul>"
    end # end if !obj.nil?
    html
  end # end def errors_show_full(obj)

  def raw_display_only_b_and_i(str)
    if !str.nil? 
      # Ensure that str only has <b> or <i> tags
      html_tag_arr = str.scan(/(<[\/]*.+?>)/)
      html_tag_arr.each { |tag_elem|
        str.sub!(Regexp.escape(tag_elem[0]), '') if tag_elem[0] != '<i>' and tag_elem[0] != '</i>' and tag_elem[0] != '<b>' and tag_elem[0] != '</b>'
      } # end html_tag_arr.each ..
      raw str
    end # end if !str.nil? 
  end # end def sanitize_except_b_and_i
end
