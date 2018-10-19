require 'test_helper'
require 'jwt'

class LinkedinSignIn::IdentityTest < ActiveSupport::TestCase
  setup do
    stub_request(:get, "https://api.linkedin.com/v1/people/~:(id,firstName,lastName,picture-url,email-address,positions)?format=json").
    to_return \
      status: 200,
      body: {
        id: "573222559223877",
        firstName: "Vincent",
        lastName: "Robert",
        emailAddress: "vincent@genezys.net",
        pictureUrl: "https://example.com/avatar.png",
        positions: {
          values: [
            { isCurrent: true, company: { name: "Touch & Sell" } },
            { isCurrent: false, company: { name: "Cantor" } }
          ]
        }
      }.to_json
  end

  test "extracting user ID" do
    assert_equal "573222559223877", LinkedinSignIn::Identity.new("fake_token").user_id
  end

  test "extracting first name" do
    assert_equal "Vincent", LinkedinSignIn::Identity.new("fake_token").first_name
  end

  test "extracting last name" do
    assert_equal "Robert", LinkedinSignIn::Identity.new("fake_token").last_name
  end

  test "extracting email address" do
    assert_equal "vincent@genezys.net", LinkedinSignIn::Identity.new("fake_token").email_address
  end

  test "extracting avatar URL" do
    assert_equal "https://example.com/avatar.png",
      LinkedinSignIn::Identity.new("fake_token").avatar_url
  end

  test "extracting current company name" do
    assert_equal "Touch & Sell", LinkedinSignIn::Identity.new("fake_token").current_company_name
  end
end
