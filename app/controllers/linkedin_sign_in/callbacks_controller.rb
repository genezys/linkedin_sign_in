require_dependency 'linkedin_sign_in/redirect_protector'

class LinkedinSignIn::CallbacksController < LinkedinSignIn::BaseController
  def show
    if valid_request?
      redirect_to proceed_to_url, flash: linkedin_sign_in_response
    else
      head :unprocessable_entity
    end
  rescue LinkedinSignIn::RedirectProtector::Violation => error
    logger.error error.message
    head :bad_request
  end

  private
    def valid_request?
      flash[:state].present? && params[:state] == flash[:state]
    end

    def proceed_to_url
      flash[:proceed_to].tap { |url| LinkedinSignIn::RedirectProtector.ensure_same_origin(url, request.url) }
    end

    def linkedin_sign_in_response
      if params[:code].present?
        { linkedin_sign_in_token: token }
      else
        { linkedin_sign_in_error: error_message }
      end
    end

    def token
      client.auth_code.get_token(params[:code]).token
    end

    def error_message
      params[:error].presence_in(LinkedinSignIn::OAUTH2_ERRORS) || "invalid_request"
    end
end
