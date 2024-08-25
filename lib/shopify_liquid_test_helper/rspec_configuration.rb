require 'rspec'
require 'shopify_liquid_test_helper'
require 'shopify_liquid_test_helper/matchers'

RSpec.configure do |config|
  config.include ShopifyLiquidTestHelper::Matchers
  config.include ShopifyLiquidTestHelper::TestHelpers

  config.before(:each) do
    ShopifyLiquidTestHelper.register_custom_tags
    ShopifyLiquidTestHelper.reset_snippets
  end
end
