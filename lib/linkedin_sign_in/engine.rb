require 'rails/engine'

module LinkedinSignIn
  class Engine < ::Rails::Engine
    isolate_namespace LinkedinSignIn

    config.linkedin_sign_in = ActiveSupport::OrderedOptions.new

    initializer 'linkedin_sign_in.config' do |app|
      config.after_initialize do
        LinkedinSignIn.client_id     = config.linkedin_sign_in.client_id || app.credentials.dig(:linkedin_sign_in, :client_id)
        LinkedinSignIn.client_secret = config.linkedin_sign_in.client_secret || app.credentials.dig(:linkedin_sign_in, :client_secret)
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
