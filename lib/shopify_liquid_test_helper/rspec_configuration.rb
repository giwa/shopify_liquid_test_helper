require 'rspec'
require 'shopify_liquid_test_helper/test_helpers'
require 'shopify_liquid_test_helper/matchers'

RSpec.configure do |config|
  config.include ShopifyLiquidTestHelper::Matchers
  config.include ShopifyLiquidTestHelper::TestHelpers

  config.before(:all) do
    ShopifyLiquidTestHelper.register_custom_tags
  end
  
  config.before(:each) do
    ShopifyLiquidTestHelper.reset_snippets
  end
end
