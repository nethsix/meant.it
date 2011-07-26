# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
MeantIt::Application.config.secret_token = 'fcabf2341f23669cacfee2af8c7c2702efa52d2ad3e61f6b6a1cfb75fffd6736cf1e19007e95660c9cb7782779a4b6331307fbad00ebe286f322f06863041a27'

Recaptcha.configure do |config|
  config.public_key  = '6LfsJcYSAAAAAHCcH2DclD5h68eb983akRAb9daQ'
  config.private_key = '6LfsJcYSAAAAAJPFY1f8qU2ybSbJ5a_jhTD1nIV_'
end
