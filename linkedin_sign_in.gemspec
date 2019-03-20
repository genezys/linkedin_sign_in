Gem::Specification.new do |s|
  s.name     = 'linkedin_sign_in'
  s.version  = '0.3.2'
  s.authors  = ['Vincent Robert']
  s.email    = ['vincent.robert@genezys.net']
  s.summary  = 'Sign in (or up) with Linkedin for Rails applications'
  s.homepage = 'https://github.com/genezys/linkedin_sign_in'
  s.license  = 'MIT'

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'rails', '>= 5.2.0'
  s.add_dependency 'oauth2', '>= 1.4.0'

  s.add_development_dependency 'bundler', '~> 1.17.2'
  s.add_development_dependency 'jwt', '>= 1.5.6'
  s.add_development_dependency 'webmock', '>= 3.4.2'

  s.files      = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
end
