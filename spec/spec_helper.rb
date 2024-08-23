require 'shopify_liquid_test_helper'

RSpec.configure do |config|
  config.before(:all) do
    ShopifyLiquidTestHelper.register_custom_tags
  end
end
