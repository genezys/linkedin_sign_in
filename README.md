This gem is shamlessly based on [Google SignIn by Basecamp](https://github.com/basecamp/google_sign_in).

# Linkedin Sign-In for Rails

This gem allows you to add Linkedin sign-in to your Rails app. You can let users sign up for and sign in to your service
with their Linkedin accounts.


## Installation

Add `linkedin_sign_in` to your Rails app’s Gemfile and run `bundle install`:

```ruby
gem 'linkedin_sign_in'
```

Linkedin Sign-In for Rails requires Rails 5.2 or newer.


## Configuration (TODO)

First, set up an OAuth 2.0 Client ID in the Linkedin API Console:

1. Go to the [API Console](https://console.developers.linkedin.com/apis/credentials).

2. In the projects menu at the top of the page, ensure the correct project is selected or create a new one.

3. In the left-side navigation menu, choose APIs & Services → Credentials.

4. Click the button labeled “Create credentials.” In the menu that appears, choose to create an **OAuth client ID**.

5. When prompted to select an application type, select **Web application**.

6. Enter your application’s name.

7. This gem adds a single OAuth callback to your app at `/linkedin_sign_in/callback`. Under **Authorized redirect URIs**,
   add that callback for your application’s domain: for example, `https://example.com/linkedin_sign_in/callback`.

   To use Linkedin sign-in in development, you’ll need to add another redirect URI for your local environment, like
   `http://localhost:3000/linkedin_sign_in/callback`. For security reasons, we recommend using a separate
   client ID for local development. Repeat these instructions to set up a new client ID for development.

8. Click the button labeled “Create.” You’ll be presented with a client ID and client secret. Save these.

With your client ID set up, configure your Rails application to use it. Run `bin/rails credentials:edit` to edit your
app’s [encrypted credentials](https://guides.rubyonrails.org/security.html#custom-credentials) and add the following:

```yaml
linkedin_sign_in:
  client_id: [Your client ID here]
  client_secret: [Your client secret here]
```

You’re all set to use Linkedin sign-in now. The gem automatically uses the client ID and client secret in your credentials.

Alternatively, you can provide the client ID and client secret using ENV variables. Add a new initializer that sets
`config.linkedin_sign_in.client_id` and `config.linkedin_sign_in.client_secret`:

```ruby
# config/initializers/linkedin_sign_in.rb
Rails.application.configure do
  config.linkedin_sign_in.client_id     = ENV['linkedin_sign_in_client_id']
  config.linkedin_sign_in.client_secret = ENV['linkedin_sign_in_client_secret']
end
```

**⚠️ Important:** Take care to protect your client secret from disclosure to third parties.


## Usage

This gem provides a `linkedin_sign_in_button` helper. It generates a button which initiates Linkedin sign-in:

```erb
<%= linkedin_sign_in_button 'Sign in with my Linkedin account', proceed_to: create_login_url %>

<%= linkedin_sign_in_button image_tag('linkedin_logo.png', alt: 'Linkedin'), proceed_to: create_login_url %>

<%= linkedin_sign_in_button proceed_to: create_login_url do %>
  Sign in with my <%= image_tag('linkedin_logo.png', alt: 'Linkedin') %> account
<% end %>
```

The `proceed_to` argument is required. After authenticating with Linkedin, the gem redirects to `proceed_to`, providing
a Linkedin ID token in `flash[:linkedin_sign_in_token]`. Your application decides what to do with it:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ...
  get 'login', to: 'logins#new'
  get 'login/create', to: 'logins#create', as: :create_login
end
```

```ruby
# app/controllers/logins_controller.rb
class LoginsController < ApplicationController
  def new
  end

  def create
    if user = authenticate_with_linkedin
      cookies.signed[:user_id] = user.id
      redirect_to user
    else
      redirect_to new_session_url, alert: 'authentication_failed'
    end
  end

  private
    def authenticate_with_linkedin
      if flash[:linkedin_sign_in_token].present?
        User.find_by linkedin_id: LinkedinSignIn::Identity.new(flash[:linkedin_sign_in_token]).user_id
      end
    end
end
```

(The above example assumes the user has already signed up for your service and that you’re storing their Linkedin user ID
in the `User#linkedin_id` attribute.)

For security reasons, the `proceed_to` URL you provide to `linkedin_sign_in_button` is required to reside on the same
origin as your application. This means it must have the same protocol, host, and port as the page where
`linkedin_sign_in_button` is used. We enforce this before redirecting to the `proceed_to` URL to guard against
[open redirects](https://www.owasp.org/index.php/Unvalidated_Redirects_and_Forwards_Cheat_Sheet).

### `LinkedinSignIn::Identity`

The `LinkedinSignIn::Identity` class decodes and verifies the integrity of a Linkedin ID token. It exposes the profile
information contained in the token via the following instance methods:

* `name`

* `email_address`

* `user_id`: A string that uniquely identifies a single Linkedin user. Use this, not `email_address`, to associate a
  Linkedin user with an application user. A Linkedin user’s email address may change, but their `user_id` will remain constant.

* `email_verified?`

* `avatar_url`

* `locale`

* `hosted_domain`: The user’s hosted G Suite domain, provided only if they belong to a G Suite.


## Security

For information on our security response procedure, see [SECURITY.md](SECURITY.md).


## License

Linkedin Sign-In for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).

Linkedin is a registered trademark of Linkedin LLC. This project is not operated by or in any way affiliated with Linkedin LLC.
