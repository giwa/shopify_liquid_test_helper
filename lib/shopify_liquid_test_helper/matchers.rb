module ShopifyLiquidTestHelper
  module Matchers
    extend RSpec::Matchers::DSL

    matcher :render_liquid_template do |expected|
      match do |template|
        @rendered = if template.is_a?(String)
                      Liquid::Template.parse(template).render(@assigns)
                    elsif template.is_a?(Liquid::Template)
                      template.render(@assigns)
                    else
                      raise ArgumentError, "Template must be a String or Liquid::Template object"
                    end
        @rendered == expected
      end

      chain :with do |assigns|
        @assigns = assigns
      end

      failure_message do |template|
        "expected that Liquid template \"#{template}\" " \
        "would render as \"#{expected}\", but got \"#{@rendered}\""
      end

      failure_message_when_negated do |template|
        "expected that Liquid template \"#{template}\" " \
        "would not render as \"#{expected}\", but it did"
      end

      description do
        "render Liquid template to \"#{expected}\""
      end
    end

    def expect_liquid_template_result(template, expected, assigns = {})
      expect(template).to render_liquid_template(expected).with(assigns)
    end
  end
end
