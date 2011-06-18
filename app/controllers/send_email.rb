class SendEmail < ActionController::Metal
  abstract!
  include ActionController::Rendering
  append_view_path "#{Rails.root}/app/views"

  def index
    render
  end
end

