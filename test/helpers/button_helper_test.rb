require "test_helper"

class LinkedinSignIn::ButtonHelperTest < ActionView::TestCase
  test "generating a login button with text content" do
    assert_dom_equal <<-HTML, linkedin_sign_in_button("Log in with Linkedin", proceed_to: "https://www.example.com/login")
      <form action="/linkedin_sign_in/authorization" accept-charset="UTF-8" method="post">
        <input type="hidden" name="proceed_to" value="https://www.example.com/login" autocomplete="off" />
        <button type="submit">Log in with Linkedin</button>
      </form>
    HTML
  end

  test "generating a login button with HTML content" do
    assert_dom_equal <<-HTML, linkedin_sign_in_button(proceed_to: "https://www.example.com/login") { image_tag("linkedin.png") }
      <form action="/linkedin_sign_in/authorization" accept-charset="UTF-8" method="post">
        <input type="hidden" name="proceed_to" value="https://www.example.com/login" autocomplete="off" />
        <button type="submit"><img src="/images/linkedin.png"></button>
      </form>
    HTML
  end

  test "generating a login button with custom attributes" do
    button = linkedin_sign_in_button("Log in with Linkedin", proceed_to: "https://www.example.com/login",
      class: "login-button", data: { disable_with: "Loading Linkedin login…" })

    assert_dom_equal <<-HTML, button
      <form action="/linkedin_sign_in/authorization" accept-charset="UTF-8" method="post">
        <input type="hidden" name="proceed_to" value="https://www.example.com/login" autocomplete="off" />
        <button type="submit" class="login-button" data-disable-with="Loading Linkedin login…">Log in with Linkedin</button>
      </form>
    HTML
  end
end
