require 'spec_helper'

RSpec.describe ShopifyLiquidTestHelper do
  before(:all) do
    ShopifyLiquidTestHelper.register_snippet('simple', 'Hello, {{ name }}!')
    ShopifyLiquidTestHelper.register_snippet('for_loop', 'Item: {{ item }}')
    ShopifyLiquidTestHelper.register_snippet('with_object', 'Name: {{ object.name }}')
  end

  def render(template, assigns = {})
    Liquid::Template.parse(template).render(assigns)
  end

  describe 'render tag' do
    it 'renders a simple snippet' do
      template = "{% render 'simple', name: 'World' %}"
      expect(template).to render_liquid_template('Hello, World!')
    end

    it 'renders a snippet with a for loop' do
      template = "{% render 'for_loop' for items as item %}"
      assigns = { 'items' => %w[A B C] }
      expect(template).to render_liquid_template('Item: AItem: BItem: C').with(assigns)
    end

    it 'renders a snippet with an object' do
      template = "{% render 'with_object' with user as object %}"
      assigns = { 'user' => { 'name' => 'John' } }
      expect(template).to render_liquid_template('Name: John').with(assigns)  
    end

    it 'does not allow access to variables outside the snippet' do
      ShopifyLiquidTestHelper.register_snippet('isolated', '{{ outside_var }}')
      template = "{% assign outside_var = 'Outside' %}{% render 'isolated' %}"
      expect(template).to render_liquid_template('').with('outside_var' => 'Outside') 
    end

    it 'provides all forloop variables in for loop rendering' do
      ShopifyLiquidTestHelper.register_snippet('forloop_vars',
                                        '{{ forloop.index }},{{ forloop.index0 }},{{ forloop.first }},{{ forloop.last }},{{ forloop.length }},{{ forloop.rindex }},{{ forloop.rindex0 }}|')
      template = "{% render 'forloop_vars' for items as item %}"
      assigns = { 'items' => %w[A B C] }
      expect(template).to render_liquid_template('1,0,true,false,3,3,2|2,1,false,false,3,2,1|3,2,false,true,3,1,0|').with(assigns) 
    end

    it 'allows using an alias for the rendered variable' do
      template = "{% render 'simple' with 'Alias' as name %}"
      expect(template).to render_liquid_template('Hello, Alias!')
    end

    it 'does not pollute the outer scope' do
      template = "{% render 'simple' with 'Inner' as name %}{{ name }}"
      assigns = { 'name' => 'Outer' }
      expect(template).to render_liquid_template('Hello, Inner!Outer').with(assigns)
    end
  end
end
