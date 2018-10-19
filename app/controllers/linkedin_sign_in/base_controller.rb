require 'oauth2'

class LinkedinSignIn::BaseController < ActionController::Base
  protect_from_forgery with: :exception

  private
    def client
      @client ||= OAuth2::Client.new \
        LinkedinSignIn.client_id,
        LinkedinSignIn.client_secret,
        authorize_url: 'https://www.linkedin.com/oauth/v2/authorization',
        token_url: 'https://www.linkedin.com/oauth/v2/accessToken',
        redirect_uri: callback_url
    end
end
