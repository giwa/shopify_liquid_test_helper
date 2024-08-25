# ShopifyLiquidTestHelper

ShopifyLiquidTestHelper is a Ruby gem designed to assist in testing Shopify Liquid templates. It provides custom Liquid tags and helper methods that simulate Shopify-specific functionality, making it easier to test your Liquid templates in isolation.

## Implementation Status

See: https://github.com/giwa/shopify_liquid_simulator?tab=readme-ov-file#implementation-status

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shopify_liquid_test_helper'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install shopify_liquid_test_helper
```

## Usage with RSpec

### Setup

In your `spec_helper.rb` or at the beginning of your test file, require and configure the helper:

```ruby
require 'shopify_liquid_test_helper'

RSpec.configure do |config|
  config.before(:each) do
    ShopifyLiquidTestHelper.register_custom_tags
  end
end
```

### Testing Liquid Templates

Here are some examples of how you can use ShopifyLiquidTestHelper in your RSpec tests:

1. Testing a simple render tag:

```ruby
RSpec.describe "Product template" do
  before do
    ShopifyLiquidTestHelper.register_snippet('product_title', '<h1>{{ product.title }}</h1>')
  end

  it "renders the product title" do
    template = "{% render 'product_title' %}"
    assigns = { 'product' => { 'title' => 'Awesome T-Shirt' } }
    result = Liquid::Template.parse(template).render(assigns)
    expect(result).to eq '<h1>Awesome T-Shirt</h1>'
  end
end
```

2. Testing a for loop in a render tag:

```ruby
RSpec.describe "Collection template" do
  before do
    ShopifyLiquidTestHelper.register_snippet('product_list', '{% for product in products %}{{ product.title }}{% endfor %}')
  end

  it "renders a list of product titles" do
    template = "{% render 'product_list' for products %}"
    assigns = { 'products' => [{ 'title' => 'Shirt' }, { 'title' => 'Pants' }] }
    result = Liquid::Template.parse(template).render(assigns)
    expect(result).to eq 'ShirtPants'
  end
end
```

3. Testing the capture tag:

```ruby
RSpec.describe "Capture tag" do
  it "captures content into a variable" do
    template = "{% capture my_variable %}Hello, {{ name }}!{% endcapture %}{{ my_variable }}"
    assigns = { 'name' => 'World' }
    result = Liquid::Template.parse(template).render(assigns)
    expect(result).to eq 'Hello, World!'
  end
end
```

### Loading Snippets from Directory

ShopifyLiquidTestHelper can load snippets from a specific directory. By default, it looks for snippets in a `snippets` directory relative to your current working directory. You can use this feature as follows:

1. Create a `snippets` directory in your project:

```
mkdir snippets
```

2. Add your Liquid snippet files to this directory. For example, create a file named `product_card.liquid`:

```liquid
<!-- snippets/product_card.liquid -->
<div class="product-card">
  <h2>{{ product.title }}</h2>
  <p>Price: {{ product.price | money }}</p>
</div>
```

3. In your tests, you can now render this snippet:

```ruby
RSpec.describe "Product listing" do
  it "renders a product card" do
    template = "{% render 'product_card' %}"
    assigns = {
      'product' => {
        'title' => 'Awesome T-Shirt',
        'price' => 1999
      }
    }
    result = Liquid::Template.parse(template).render(assigns)
    expect(result).to include('Awesome T-Shirt')
    expect(result).to include('Price: $19.99')
  end
end
```

ShopifyLiquidTestHelper will automatically load the `product_card` snippet from the `snippets` directory when you use the `render` tag in your Liquid template.


### Mocking render

ShopifyLiquidTestHelper provides functionality to mock Liquid snippets using ShopifyLiquidTestHelper.register_snippet method. This is particularly useful when testing templates that depend on other snippets.

Here's a simple example of how to use `allow` for mocking:

```liquid
<!-- snippets/product.liquid -->
<div class="product">
  <h1>{{ product.title }}</h1>
  <div class="price">
    {% render 'product_price' %}
  </div>
  <div class="description">
    {{ product.description }}
  </div>
  {% if product.available %}
    <button type="button" class="add-to-cart">Add to Cart</button>
  {% else %}
    <p>Sold Out</p>
  {% endif %}
</div>
```


```ruby
RSpec.describe 'ProductTemplate' do
  let(:template) { ShopifyLiquidTestHelper.parse_template('snippets/product.liquid') }
  let(:product) { { 'title' => 'Test Product', 'price' => 1000 } }

  before do
    # Mock the 'product_price' snippet to return a formatted price
    ShopifyLiquidTestHelper.register_snippet('product_price', '{{ product.price | money }}')
  end

  it 'renders the product title and price' do
    rendered = template.render('product' => product)
    expect(rendered).to include('Test Product')
    expect(rendered).to include('$10.00')
  end

  context 'when the product is on sale' do
    before do
      # Override the mock for a specific test
      ShopifyLiquidTestHelper.register_snippet('product_price', 'On Sale: {{ product.price | money }}')
    end

    it 'shows the sale price' do
      rendered = template.render('product' => product)
      expect(rendered).to include('On Sale: $10.00')
    end
  end
end

### Customizing the Snippets Directory

If your snippets are located in a different directory, you can specify the path when initializing ShopifyLiquidTestHelper:

```ruby
ShopifyLiquidTestHelper.snippets_dir = 'path/to/your/snippets'
```

This allows you to organize your snippets in a way that best fits your project structure.

### Combining Registered and File-based Snippets

You can use both registered snippets (using `ShopifyLiquidTestHelper.register_snippet`) and file-based snippets in the same test suite. ShopifyLiquidTestHelper will first check for registered snippets, and if not found, it will look for a matching file in the snippets directory.

```ruby
RSpec.describe "Mixed snippet sources" do
  before do
    ShopifyLiquidTestHelper.register_snippet('inline_snippet', 'This is an inline snippet')
  end

  it "renders both registered and file-based snippets" do
    template = """
      {% render 'inline_snippet' %}
      {% render 'product_card' %}
    """
    assigns = {
      'product' => {
        'title' => 'Cool Product',
        'price' => 2499
      }
    }
    result = Liquid::Template.parse(template).render(assigns)
    expect(result).to include('This is an inline snippet')
    expect(result).to include('Cool Product')
    expect(result).to include('Price: $24.99')
  end
end
```

### Advanced Usage

For more complex scenarios, you can create helper methods in your specs to simplify template rendering:

```ruby
def render_template(template, assigns = {})
  Liquid::Template.parse(template).render(assigns)
end

RSpec.describe "Complex template" do
  it "renders a complex structure" do
    template = """
      {% render 'header' %}
      {% for product in collection.products %}
        {% render 'product_card' %}
      {% endfor %}
      {% render 'footer' %}
    """
    assigns = {
      'collection' => {
        'products' => [
          { 'title' => 'Product 1', 'price' => 19.99 },
          { 'title' => 'Product 2', 'price' => 24.99 }
        ]
      }
    }
    result = render_template(template, assigns)
    expect(result).to include('Product 1')
    expect(result).to include('Product 2')
    expect(result).to include('19.99')
    expect(result).to include('24.99')
  end
end
```

This gem allows you to test your Shopify Liquid templates thoroughly, ensuring they render correctly with various inputs and scenarios.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/giwa/shopify_liquid_test_helper.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).