$:.push File.expand_path("../lib", __FILE__)
require "omniauth-rcpsych/version"

Gem::Specification.new do |s|
  s.name        = 'omniauth-rcpsych'
  s.version     = OmniAuth::RCPsych::VERSION
  s.summary     = "Omniauth Strategy for concept"
  s.authors     = ["Simon Bettison"]
  s.email       = 'simon@bettison.org'
  s.require_paths = ["lib"]
  s.files = Dir["{lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

end
