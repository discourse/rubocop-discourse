# rubocop-discourse

Custom Discourse RuboCop cops plus our shared project configuration (RSpec, Rails, Capybara, FactoryBot). Most Discourse projects use Syntax Tree for formatting, so we recommend the Syntax Tree-compatible config by default.

## Installation

Add the gem to your development group:

```ruby
group :development, :test do
  gem "rubocop-discourse"
end
```

## Configuration

Recommended (Syntax Tree-friendly, omits Layout cops so it can be used with the formatter):

```yml
inherit_gem:
  rubocop-discourse: stree-compat.yml
```

`stree-compat.yml` includes Discourse cops plus core/RSpec/Rails/Capybara/FactoryBot, but leaves layout to Syntax Tree.

Base config with layout cops (for projects not using Syntax Tree):

```yml
inherit_gem:
  rubocop-discourse: default.yml
```

`default.yml` is kept for backwards compatibility and pulls in `stree-compat.yml` plus `rubocop-layout.yml`.

Then run `bundle exec rubocop` as usual.

Switching an existing project to Syntax Tree:

```diff
 inherit_gem:
-  rubocop-discourse: default.yml # includes layout cops
+  rubocop-discourse: stree-compat.yml # defers layout to Syntax Tree
```

## RSpec definitions in iterators

`Discourse/NoIterationOverRSpecDefinitions` enforces the RSpec style guide's
[rule against generating tests with iterators](https://rspec.rubystyle.guide/#it-in-iterators).
It reports example and group declarations inside iterator blocks or Ruby loops.
Write separate `describe`, `context`, and `it` declarations for each scenario.
Loops inside examples and setup hooks remain allowed.

For example, replace an iterator that defines examples:

```ruby
RSpec.describe "topic lists", type: :request do
  %w[latest top].each do |filter|
    it "returns the #{filter} list" do
      get "/#{filter}"
      expect(response.status).to eq(200)
    end
  end
end
```

Write each example explicitly instead:

```ruby
RSpec.describe "topic lists", type: :request do
  it "returns the latest list" do
    get "/latest"
    expect(response.status).to eq(200)
  end

  it "returns the top list" do
    get "/top"
    expect(response.status).to eq(200)
  end
end
```

Prefer these direct examples for small cases, even when a few lines repeat.
For a repeated contract or a larger input matrix, use named shared examples
with explicit inclusions. Each case remains an independently runnable RSpec
example:

```ruby
RSpec.describe "topic lists", type: :request do
  shared_examples "a public topic list" do |filter|
    it "returns the #{filter} list" do
      get "/#{filter}.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body).to include("topic_list")
    end
  end

  it_behaves_like "a public topic list", "latest"
  it_behaves_like "a public topic list", "top"
end
```

`it_behaves_like` creates a separate group for each inclusion, so selecting an
inclusion by file and line runs that case. Keep each case as its own example.
Moving the input matrix into a loop inside one `it` block makes an individual
case harder to rerun. Shared examples are optional, and should name the
behavior they share.

The cop recognizes RSpec aliases configured through `RSpec/Language` and is
enabled for spec files by default. It does not autocorrect generated tests.
