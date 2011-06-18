#class ReceiveEmail < ActionController::Metal
#  abstract!
class ReceiveEmail
  def self.call(env)
#    params = CGI:parse(env['QUERY_STRING'])
#    output = "text:#{params['text']}, html:#{params['html']}, to:#{params['to']}, from:#{params['from']}, subject:#{params['subject']}"
puts "ReceiveEmail: #{env.inspect}"
    [200, {}, [env.inspect]]
  end # end def self.call
end
