module ShopifyLiquidTestHelper
  class RenderTag < Liquid::Tag
    SYNTAX = /(#{Liquid::QuotedFragment}+)(\s+(?:with|for)\s+(#{Liquid::QuotedFragment}+))?(\s+as\s+(#{Liquid::QuotedFragment}+))?/o

    def initialize(tag_name, markup, tokens)
      super
      parse_markup(markup)
      @params = extract_params(markup)
    end

    def render(context)
      snippet_name = resolve_snippet_name(context)
      snippet = fetch_snippet(snippet_name)

      temp_context = create_isolated_context(context)
      variable = resolve_variable(context)

      if @for_loop
        render_for_loop(snippet, variable, temp_context)
      else
        render_with_variable(snippet, variable, temp_context)
      end
    end

    private

    def parse_markup(markup)
      unless markup =~ SYNTAX
        raise Liquid::SyntaxError,
              "Syntax Error in 'render' - Valid syntax: render 'snippet' [with object|for array] [as alias]"
      end

      @snippet_name = ::Regexp.last_match(1)
      @variable_name = ::Regexp.last_match(3)
      @alias = ::Regexp.last_match(5)
      @for_loop = ::Regexp.last_match(2) =~ /\s+for\s+/
    end

    def extract_params(markup)
      params = {}
      markup.scan(Liquid::TagAttributes) { |key, value| params[key] = value }
      params
    end

    def resolve_snippet_name(context)
      snippet_name = context[@snippet_name] || @snippet_name
      snippet_name.gsub(/['"]/, '')
    end

    def fetch_snippet(snippet_name)
      snippet = ShopifyLiquidTestHelper.get_snippet(snippet_name)
      raise Liquid::SyntaxError, "Unknown snippet '#{snippet_name}'" unless snippet

      snippet
    end

    def resolve_variable(context)
      @variable_name ? context[@variable_name] : nil
    end

    def render_for_loop(snippet, array, context)
      return unless array.respond_to?(:each)

      array.each_with_index.map do |item, index|
        item_context = create_item_context(context, item, index, array.size)
        Liquid::Template.parse(snippet).render(item_context)
      end.join
    end

    def create_item_context(context, item, index, array_size)
      item_context = context.new_isolated_subcontext
      item_context[@alias || 'item'] = item

      item_context['forloop'] = {
        'first' => index.zero?,
        'index' => index + 1,
        'index0' => index,
        'last' => index == array_size - 1,
        'length' => array_size,
        'rindex' => array_size - index,
        'rindex0' => array_size - index - 1
      }

      @params.each do |key, value|
        item_context[key] = context[value] || context.evaluate(value) || value
      end

      item_context
    end

    def render_with_variable(snippet, variable, context)
      context[@alias || 'object'] = variable if @variable_name

      @params.each do |key, value|
        context[key] = context[value] || context.evaluate(value) || value
      end

      Liquid::Template.parse(snippet).render(context)
    end

    def create_isolated_context(context)
      new_context = context.new_isolated_subcontext
      @params.each { |key, value| new_context[key] = context[value] || context.evaluate(value) || value }
      new_context
    end
  end
end
