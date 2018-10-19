require_dependency 'linkedin_sign_in/redirect_protector'

class LinkedinSignIn::CallbacksController < LinkedinSignIn::BaseController
  def show
    if valid_request?
      redirect_to proceed_to_url, flash: { linkedin_sign_in_token: token }
    else
      head :unprocessable_entity
    end
  rescue LinkedinSignIn::RedirectProtector::Violation => error
    logger.error error.message
    head :bad_request
  end

  private
    def valid_request?
      flash[:state].present? && params.require(:state) == flash[:state] && params[:error].blank?
    end

    def proceed_to_url
      flash[:proceed_to].tap { |url| LinkedinSignIn::RedirectProtector.ensure_same_origin(url, request.url) }
    end

    def token
      client.auth_code.get_token(params.require(:code)).token
    end
end
