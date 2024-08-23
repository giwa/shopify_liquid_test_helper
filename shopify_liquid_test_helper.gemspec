Gem::Specification.new do |spec|
  spec.name          = "shopify_liquid_test_helper"
  spec.version       = "0.1.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]

  spec.summary       = "A helper for testing Shopify Liquid templates"
  spec.description   = "This gem provides helper methods and custom tags for testing Shopify Liquid templates"
  spec.homepage      = "https://github.com/yourusername/shopify_liquid_test_helper"
  spec.license       = "MIT"

  spec.files         = Dir.glob("{lib,spec}/**/*") + %w(README.md Rakefile)
  spec.require_paths = ["lib"]

  spec.add_dependency "liquid", "~> 5.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
