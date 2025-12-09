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
