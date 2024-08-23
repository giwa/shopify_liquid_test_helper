require 'liquid'
require 'shopify_liquid_test_helper/render_tag'
require 'shopify_liquid_test_helper/capture_tag'

module ShopifyLiquidTestHelper
  class << self
    attr_accessor :snippets_dir

    def parse_template(template_name)
      Liquid::Template.parse(File.read(template_name))
    end

    def render_template(template, assigns)
      template.render(assigns).strip
    end

    def register_custom_tags
      Liquid::Template.register_tag('render', RenderTag)
      Liquid::Template.register_tag('capture', CaptureTag)
    end

    def register_snippet(name, content)
      snippets[name] = content
    end

    def get_snippet(name)
      snippets[name] || load_snippet(name)
    end

    private

    def snippets
      @snippets ||= {}
    end

    def load_snippet(name)
      snippet_path = File.join(snippets_dir || 'snippets', "#{name}.liquid")
      if File.exist?(snippet_path)
        snippet = File.read(snippet_path)
        snippets[name] = snippet
      else
        puts "Snippet not found: #{snippet_path}"
        nil
      end
    end
  end

  # デフォルトのsnippetsディレクトリを設定
  @snippets_dir = 'snippets'
end