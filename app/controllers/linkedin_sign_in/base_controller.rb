require 'oauth2'

class LinkedinSignIn::BaseController < ActionController::Base
  protect_from_forgery with: :exception

  private
    def client
      @client ||= LinkedinSignIn.oauth2_client(redirect_uri: callback_url)
    end
end
