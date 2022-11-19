require 'rails/engine'
require 'linkedin_sign_in' unless defined?(LinkedinSignIn)

module LinkedinSignIn
  class Engine < ::Rails::Engine
    isolate_namespace LinkedinSignIn

    # Set default config so apps can modify rather than starting from nil, e.g.
    #
    #   config.linkedin_sign_in.authorize_url += "?disallow_webview=true"
    #
    config.linkedin_sign_in = ActiveSupport::OrderedOptions.new.update \
      authorize_url: LinkedinSignIn.authorize_url,
      token_url: LinkedinSignIn.token_url

    initializer 'linkedin_sign_in.config' do |app|
      config.after_initialize do
        LinkedinSignIn.client_id     = config.linkedin_sign_in.client_id || app.credentials.dig(:linkedin_sign_in, :client_id)
        LinkedinSignIn.client_secret = config.linkedin_sign_in.client_secret || app.credentials.dig(:linkedin_sign_in, :client_secret)
        LinkedinSignIn.authorize_url = config.linkedin_sign_in.authorize_url
        LinkedinSignIn.token_url     = config.linkedin_sign_in.token_url

        LinkedinSignIn.oauth2_client_options = config.linkedin_sign_in.oauth2_client_options
      end
    end

    initializer 'linkedin_sign_in.helpers' do
      ActiveSupport.on_load :action_controller_base do
        helper LinkedinSignIn::Engine.helpers
      end
    end

    initializer 'linkedin_sign_in.mount' do |app|
      app.routes.prepend do
        mount LinkedinSignIn::Engine, at: app.config.linkedin_sign_in.root || 'linkedin_sign_in'
      end
    end

    initializer 'linkedin_sign_in.parameter_filters' do |app|
      app.config.filter_parameters << :code
    end
  end
end
