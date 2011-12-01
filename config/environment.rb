# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MeantIt::Application.initialize!

ActionView::Base.field_error_proc = proc { |input, instance| input }

# Ensure the gateway is in test mode
ActiveMerchant::Billing::Base.gateway_mode = :test
ActiveMerchant::Billing::Base.integration_mode = :test
ActiveMerchant::Billing::PaypalGateway.pem_file = File.read(File.dirname(__FILE__) + '/../certs/paypal_cert.pem')
