module ShopifyLiquidTestHelper
  class CaptureTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @variable_name = markup.strip
    end

    def render(context)
      result = super
      context.scopes.last[@variable_name] = result
      ''
    end
  end
end
