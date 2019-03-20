require 'test_helper'

class LinkedinSignIn::CallbacksControllerTest < ActionDispatch::IntegrationTest
  test "receiving an authorization code" do
    post linkedin_sign_in.authorization_url, params: { proceed_to: 'http://www.example.com/login' }
    assert_response :redirect

    stub_token_for '4/SgCpHSVW5-Cy', access_token: 'ya29.GlwIBo', id_token: 'eyJhbGciOiJSUzI'

    get linkedin_sign_in.callback_url(code: '4/SgCpHSVW5-Cy', state: flash[:state])
    assert_redirected_to 'http://www.example.com/login'
    assert_equal 'ya29.GlwIBo', flash[:linkedin_sign_in][:token]
    assert_nil flash[:linkedin_sign_in][:error]
  end

  # Authorization request errors: https://tools.ietf.org/html/rfc6749#section-4.1.2.1
  %w[ invalid_request unauthorized_client access_denied unsupported_response_type invalid_scope server_error temporarily_unavailable ].each do |error|
    test "receiving an authorization code grant error: #{error}" do
      post linkedin_sign_in.authorization_url, params: { proceed_to: 'http://www.example.com/login' }
      assert_response :redirect

      get linkedin_sign_in.callback_url(error: error, state: flash[:state])
      assert_redirected_to 'http://www.example.com/login'
      assert_nil flash[:linkedin_sign_in][:token]
      assert_equal error, flash[:linkedin_sign_in][:error]
    end
  end

  test "receiving an invalid authorization error" do
    post linkedin_sign_in.authorization_url, params: { proceed_to: 'http://www.example.com/login' }
    assert_response :redirect

    get linkedin_sign_in.callback_url(error: 'unknown error code', state: flash[:state])
    assert_redirected_to 'http://www.example.com/login'
    assert_nil flash[:linkedin_sign_in][:token]
    assert_equal "invalid_request", flash[:linkedin_sign_in][:error]
  end

  test "receiving neither code nor error" do
    post linkedin_sign_in.authorization_url, params: { proceed_to: 'http://www.example.com/login' }
    assert_response :redirect

    get linkedin_sign_in.callback_url(state: flash[:state])
    assert_redirected_to 'http://www.example.com/login'
    assert_nil flash[:linkedin_sign_in][:token]
    assert_equal 'invalid_request', flash[:linkedin_sign_in][:error]
  end

  # Access token request errors: https://tools.ietf.org/html/rfc6749#section-5.2
  %w[ invalid_request invalid_client invalid_grant unauthorized_client unsupported_grant_type invalid_scope ].each do |error|
    test "receiving an access token request error: #{error}" do
      post linkedin_sign_in.authorization_url, params: { proceed_to: 'http://www.example.com/login' }
      assert_response :redirect

      stub_token_error_for '4/SgCpHSVW5-Cy', error: error

      get linkedin_sign_in.callback_url(code: '4/SgCpHSVW5-Cy', state: flash[:state])
      assert_redirected_to 'http://www.example.com/login'
      assert_nil flash[:linkedin_sign_in][:id_token]
      assert_equal error, flash[:linkedin_sign_in][:error]
    end
  end

  test "protecting against CSRF without flash state" do
    post linkedin_sign_in.authorization_url, params: { proceed_to: 'http://www.example.com/login' }
    assert_response :redirect

    get linkedin_sign_in.callback_url(code: '4/SgCpHSVW5-Cy', state: 'invalid')
    assert_redirected_to 'http://www.example.com/login'
    assert_nil flash[:linkedin_sign_in][:token]
    assert_equal 'invalid_request', flash[:linkedin_sign_in][:error]
  end

  test "protecting against CSRF with invalid state" do
    post linkedin_sign_in.authorization_url, params: { proceed_to: 'http://www.example.com/login' }
    assert_response :redirect
    assert_not_nil flash[:state]

    get linkedin_sign_in.callback_url(code: '4/SgCpHSVW5-Cy', state: 'invalid')
    assert_redirected_to 'http://www.example.com/login'
    assert_nil flash[:linkedin_sign_in][:token]
    assert_equal 'invalid_request', flash[:linkedin_sign_in][:error]
  end

  test "protecting against CSRF with missing state" do
    post linkedin_sign_in.authorization_url, params: { proceed_to: 'http://www.example.com/login' }
    assert_response :redirect
    assert_not_nil flash[:state]

    get linkedin_sign_in.callback_url(code: '4/SgCpHSVW5-Cy')
    assert_redirected_to 'http://www.example.com/login'
    assert_nil flash[:linkedin_sign_in][:token]
    assert_equal 'invalid_request', flash[:linkedin_sign_in][:error]
  end

  test "protecting against open redirects" do
    post linkedin_sign_in.authorization_url, params: { proceed_to: 'http://malicious.example.com/login' }
    assert_response :redirect

    get linkedin_sign_in.callback_url(code: '4/SgCpHSVW5-Cy', state: flash[:state])
    assert_response :bad_request
  end

  private
    def stub_token_for(code, **response_body)
      stub_token_request(code, status: 200, response: response_body)
    end

    def stub_token_error_for(code, error:)
      stub_token_request(code, status: 418, response: { error: error })
    end

    def stub_token_request(code, status:, response:)
      stub_request(:post, 'https://www.linkedin.com/oauth/v2/accessToken').with(
        body: {
          grant_type: 'authorization_code',
          code: code,
          client_id: FAKE_LINKEDIN_CLIENT_ID,
          client_secret: FAKE_LINKEDIN_CLIENT_SECRET,
          redirect_uri: 'http://www.example.com/linkedin_sign_in/callback'
        }
      ).to_return(
        status: status,
        headers: { 'Content-Type' => 'application/json' },
        body: JSON.generate(response)
      )
    end
end
