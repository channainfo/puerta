
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "puerta/version"

Gem::Specification.new do |spec|
  spec.name          = "puerta"
  spec.version       = Puerta::VERSION
  spec.authors       = ["Channa Ly"]
  spec.email         = ["channa.info@gmail.com"]

  spec.summary       = %q{
    A gem to config env variable in development in dotenv, yaml, aws ssm parameter store, heroku in ruby and rails project.
  }
  spec.description   = %q{
    This gem aims to load config to ENV varaible easily. Currently configuration can be done by a .env, a yaml file or by loading from
    AWS System Manager Parameter Store which is recommended for production deployment.

  }
  spec.homepage      = "https://github.com/channainfo/puerta"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # spec.add_dependency "activesupport", "~> 4.2.0"
  spec.add_dependency "faraday", "~> 0.9"
  spec.add_dependency "nokogiri"


  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "rspec",   "~> 3.0"
  spec.add_development_dependency "webmock"

end
