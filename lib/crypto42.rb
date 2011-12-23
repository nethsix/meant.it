module Crypto42
  class Button
    def initialize(data, logtag=nil)
      base_dir = nil
      if Rails.env == "production"
        base_dir = ""
      else
        base_dir = Dir.getwd
      end # end else Rails.env != "production"
      my_cert_file = base_dir + "/certs/meant_it_pubcert.pem"
      my_key_file = base_dir + "/certs/meant_it_prvkey.pem"
      if Rails.env == "production"
        paypal_cert_file = base_dir + "/certs/paypal_cert.pem"
      else
        paypal_cert_file = base_dir + "/certs/sandbox_paypal_cert.pem"
      end # end if Rails.env == "production"
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:initialize:#{logtag}, using paypal_cert_file:#{paypal_cert_file}")

      IO.popen("/usr/bin/openssl smime -sign -signer #{my_cert_file} -inkey #{my_key_file} -outform der -nodetach -binary | /usr/bin/openssl smime -encrypt -des3 -binary -outform pem #{paypal_cert_file}", 'r+') do |pipe|
        data.each { |x,y| pipe << "#{x}=#{y}\n" }
        pipe.close_write
        @data = pipe.read
      end
    end

    def self.from_hash(hs)
      self.new hs
    end

    def get_encrypted_text
      return @data
    end

  end #end button
end #end module
