require_dependency 'linkedin_sign_in/redirect_protector'

class LinkedinSignIn::CallbacksController < LinkedinSignIn::BaseController
  def show
    redirect_to proceed_to_url, flash: { linkedin_sign_in: linkedin_sign_in_response }
  rescue LinkedinSignIn::RedirectProtector::Violation => error
    logger.error error.message
    head :bad_request
  end

  private
    def proceed_to_url
      flash[:proceed_to].tap { |url| LinkedinSignIn::RedirectProtector.ensure_same_origin(url, request.url) }
    end

    def linkedin_sign_in_response
      if valid_request? && params[:code].present?
        { token: token }
      else
        { error: error_message_for(params[:error]) }
      end
    rescue OAuth2::Error => error
      { error: error_message_for(error.code) }
    end

    def valid_request?
      flash[:state].present? && params[:state] == flash[:state]
    end

    def token
      client.auth_code.get_token(params[:code]).token
    end

    def error_message_for(error_code)
      error_code.presence_in(LinkedinSignIn::OAUTH2_ERRORS) || "invalid_request"
    end
end
