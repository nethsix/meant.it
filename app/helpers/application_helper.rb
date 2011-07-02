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

end
