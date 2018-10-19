require 'active_support'
require 'active_support/rails'

module LinkedinSignIn
  mattr_accessor :client_id
  mattr_accessor :client_secret
end

require 'linkedin_sign_in/identity'
require 'linkedin_sign_in/engine' if defined?(Rails)
