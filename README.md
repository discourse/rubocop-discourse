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

Recommended (Syntax Tree-friendly, omits formatter-owned Layout cops):

```yml
inherit_gem:
  rubocop-discourse: stree-compat.yml
```

`stree-compat.yml` includes Discourse cops plus core/RSpec/Rails/Capybara/FactoryBot, but leaves formatting to Syntax Tree. It still enables `Layout/ClassStructure` because that cop enforces semantic class organization instead of whitespace.

Base config with layout cops (for projects not using Syntax Tree):

```yml
inherit_gem:
  rubocop-discourse: default.yml
```

`default.yml` is kept for backwards compatibility and pulls in `stree-compat.yml` plus `rubocop-layout.yml`.

Both configurations group class methods in a `class << self` block. They order class bodies as module inclusions, constants, the singleton-class block, `initialize`, then public, protected, and private instance methods.

Every class and module constant must also be declared with `public_constant` or `private_constant`.

`Layout/ClassStructure` autocorrection is disabled because moving class definitions can change runtime behavior. Reorder existing classes manually when adopting this configuration.

Then run `bundle exec rubocop` as usual.

Switching an existing project to Syntax Tree:

```diff
 inherit_gem:
-  rubocop-discourse: default.yml # includes layout cops
+  rubocop-discourse: stree-compat.yml # defers layout to Syntax Tree
```
