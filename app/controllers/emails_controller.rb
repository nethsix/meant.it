class EmailsController < ActionController::Metal
  abstract!

  def receive_email
    output = "text:#{params['text']}, html:#{params['html']}, to:#{params['to']}, from:#{params['from']}, subject:#{params['subject']}"
    self.response.body = output
  end # end def receive_email
end
