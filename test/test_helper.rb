ENV['RAILS_ENV'] = 'test'

FAKE_LINKEDIN_CLIENT_ID = '86179201039-eks5VfVc46WoFYyZVUDpQHeZFDRCqno3.apps.linkedinusercontent.com'
FAKE_LINKEDIN_CLIENT_SECRET = 'r(XsBajmyMddruvf$jDgLyPK'

require_relative '../test/dummy/config/environment'

require 'rails/test_help'
require 'webmock/minitest'
require 'byebug'

require 'openssl'
LINKEDIN_PRIVATE_KEY = OpenSSL::PKey::RSA.new(File.read(File.expand_path('key.pem', __dir__)))
LINKEDIN_X509_CERTIFICATE = OpenSSL::X509::Certificate.new(File.read(File.expand_path('certificate.pem', __dir__)))

if LINKEDIN_X509_CERTIFICATE.not_after <= Time.now
  raise "Test certificate is expired. Generate a new one and run the tests again: `bundle exec rake test:certificate:generate`."
end

class ActionView::TestCase
  private
    def assert_dom_equal(expected, actual, message = nil)
      super expected.remove(/(\A|\n)\s*/), actual, message
    end
end
