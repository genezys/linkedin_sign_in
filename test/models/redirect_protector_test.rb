require 'test_helper'
require 'linkedin_sign_in/redirect_protector'

class LinkedinSignIn::RedirectProtectorTest < ActiveSupport::TestCase
  test "disallows URL target with different host than source" do
    assert_raises LinkedinSignIn::RedirectProtector::Violation do
      LinkedinSignIn::RedirectProtector.ensure_same_origin 'https://malicious.example.com', 'https://genezys.net'
    end
  end

  test "disallows URL target with different port than source" do
    assert_raises LinkedinSignIn::RedirectProtector::Violation do
      LinkedinSignIn::RedirectProtector.ensure_same_origin 'https://genezys.net:10443', 'https://genezys.net'
    end
  end

  test "disallows URL target with different protocol than source" do
    assert_raises LinkedinSignIn::RedirectProtector::Violation do
      LinkedinSignIn::RedirectProtector.ensure_same_origin 'http://genezys.net', 'https://genezys.net'
    end
  end

  test "allows URL target with same origin as source" do
    assert_nothing_raised do
      LinkedinSignIn::RedirectProtector.ensure_same_origin 'https://genezys.net', 'https://genezys.net'
    end
  end

  test "allows path target" do
    assert_nothing_raised do
      LinkedinSignIn::RedirectProtector.ensure_same_origin '/callback', 'https://genezys.net'
    end
  end
end
