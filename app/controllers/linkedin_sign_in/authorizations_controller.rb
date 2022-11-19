require 'securerandom'

class LinkedinSignIn::AuthorizationsController < LinkedinSignIn::BaseController
  skip_forgery_protection only: :create

  def create
    redirect_to login_url(scope: 'r_basicprofile r_emailaddress', state: state),
      allow_other_host: true, flash: { proceed_to: params.require(:proceed_to), state: state },
  end

  private
    def login_url(**params)
      client.auth_code.authorize_url(prompt: 'login', **params)
    end

    def state
      @state ||= SecureRandom.base64(24)
    end
end
