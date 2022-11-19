Rails.application.configure do
  config.linkedin_sign_in.client_id = FAKE_LINKEDIN_CLIENT_ID
  config.linkedin_sign_in.client_secret = FAKE_LINKEDIN_CLIENT_SECRET

  # Default changed to basic auth. Use old :request_body for the sake of our test stubs.
  config.linkedin_sign_in.oauth2_client_options = { auth_scheme: :request_body }
end
