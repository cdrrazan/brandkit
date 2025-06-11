# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'brandkit'
  spec.version       = '0.1.0'
  spec.authors       = ['Rajan Bhattarai']
  spec.email         = ['publisher@rajanbhattarai.com']
  
  spec.summary       = 'A CLI tool to check domain and social username availability'
  spec.description   = 'BrandKit is a Ruby CLI that helps check domain availability via Namecheap API and social media username availability across multiple platforms.'
  spec.homepage      = 'https://github.com/cdrrazan/brandkit'
  spec.license       = 'MIT'
  
  spec.files         = Dir.glob('lib/**/*') + Dir.glob('bin/*') + %w[README.md LICENSE]
  spec.bindir        = 'bin'
  spec.executables   = ['brandkit'] # Name of your CLI executable file (adjust accordingly)
  spec.require_paths = ['lib']
  
  # Runtime dependencies (add as needed)
  spec.add_runtime_dependency 'httparty', '~> 0.18'
  spec.add_runtime_dependency 'tty-prompt', '~> 0.23'
  spec.add_runtime_dependency 'tty-table', '~> 0.12'
  spec.add_runtime_dependency 'colorize', '~> 0.8'
  spec.add_runtime_dependency 'artii', '~> 2.0'
  
  # Development dependencies (optional, for testing, debugging)
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'byebug', '~> 11.1'
  
  spec.required_ruby_version = '>= 3.2'
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
end
