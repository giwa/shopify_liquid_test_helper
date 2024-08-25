require 'shopify_liquid_tags'
require 'liquid'

module ShopifyLiquidTestHelper
  class << self
    attr_accessor :snippets_dir
    attr_writer :snippet_provider

    def parse_liquid_file(template_name)
      Liquid::Template.parse(File.read(template_name))
    end

    def register_custom_tags
      ShopifyLiquidTags.register_tags
      ShopifyLiquidTags::RenderTag.snippet_provider = method(:get_snippet)
    end

    def register_snippet(name, content)
      snippets[name] = content
    end

    def get_snippet(name)
      snippet_provider.call(name)
    end

    def reset_snippets
      Thread.current[:snippets] = {}
    end

    def snippet_provider
      @snippet_provider ||= method(:default_snippet_provider)
    end

    private

    def snippets
      Thread.current[:snippets] ||= {}
    end

    def default_snippet_provider(name)
      snippets[name] || load_snippet(name)
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

  @snippets_dir = 'snippets'
end

require 'shopify_liquid_test_helper/integration' if defined?(RSpec)
