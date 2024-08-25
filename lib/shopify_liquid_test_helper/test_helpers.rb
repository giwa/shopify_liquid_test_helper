module ShopifyLiquidTestHelper
  module TestHelpers
    def parse_liquid(template)
      Liquid::Template.parse(template)
    end

    def parse_liquid_file(template_name)
      Liquid::Template.parse(File.read(template_name))
    end

    def render_liquid(template, assigns = {})
      case template
      when String
        parse_liquid(template).render(assigns)
      when Liquid::Template
        template.render(assigns)
      else
        raise ArgumentError, "Template must be a String or Liquid::Template object"
      end
    end

    def register_snippet(name, content)
      ShopifyLiquidTestHelper.register_snippet(name, content)
    end
  end
end
