require 'active_support'
require 'active_support/rails'
require 'oauth2'

module LinkedinSignIn
  mattr_accessor :client_id
  mattr_accessor :client_secret
  mattr_accessor :authorize_url, default: "https://www.linkedin.com/oauth/v2/authorization"
  mattr_accessor :token_url, default: "https://www.linkedin.com/oauth/v2/accessToken"
  mattr_accessor :oauth2_client_options, default: nil

  # https://tools.ietf.org/html/rfc6749#section-4.1.2.1
  authorization_request_errors = %w[
    invalid_request
    unauthorized_client
    access_denied
    unsupported_response_type
    invalid_scope
    server_error
    temporarily_unavailable
  ]

  # https://tools.ietf.org/html/rfc6749#section-5.2
  access_token_request_errors = %w[
    invalid_request
    invalid_client
    invalid_grant
    unauthorized_client
    unsupported_grant_type
    invalid_scope
  ]

  # Authorization Code Grant errors from both authorization requests
  # and access token requests.
  OAUTH2_ERRORS = authorization_request_errors | access_token_request_errors

  def self.oauth2_client(redirect_uri:)
    OAuth2::Client.new \
      LinkedinSignIn.client_id,
      LinkedinSignIn.client_secret,
      authorize_url: LinkedinSignIn.authorize_url,
      token_url: LinkedinSignIn.token_url,
      redirect_uri: redirect_uri,
      **LinkedinSignIn.oauth2_client_options.to_h
  end
end

require 'linkedin_sign_in/identity'
require 'linkedin_sign_in/engine' if defined?(Rails) && !defined?(LinkedinSignIn::Engine)
