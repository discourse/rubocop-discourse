# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::FabricatorShorthand, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "registers an offense when not using the fabricator shorthand" do
    expect_offense(<<~RUBY)
      RSpec.describe "Foo" do
        fab!(:foo) { Fabricate(:foo) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/FabricatorShorthand: Use the fabricator shorthand: `fab!(:foo)`
      end
    RUBY
  end

  it "does not register an offense when the fabricator has attributes" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe "Foo" do
        fab!(:foo) { Fabricate(:foo, bar: 1) }
      end
    RUBY
  end

  it "registers an offense when the identifier doesn't match and can be simplified" do
    expect_offense(<<~RUBY)
      RSpec.describe "Foo" do
        fab!(:bar) { Fabricate(:foo) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/FabricatorShorthand: Use the fabricator shorthand: `fab!(:bar, :foo)`
      end
    RUBY
  end

  it "does not register an offense when the identifier doesn't match and the fabricator has attributes" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe "Foo" do
        fab!(:bar) { Fabricate(:foo, bar: 1) }
      end
    RUBY
  end

  it "supports autocorrect when the name and fabricator matches" do
    expect_offense(<<~RUBY)
      RSpec.describe "Foo" do
        fab!(:foo) { Fabricate(:foo) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/FabricatorShorthand: Use the fabricator shorthand: `fab!(:foo)`
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe "Foo" do
        fab!(:foo)
      end
    RUBY
  end

  it "supports autocorrect when the name and fabricator don't match" do
    expect_offense(<<~RUBY)
      RSpec.describe "Foo" do
        fab!(:bar) { Fabricate(:foo) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Discourse/FabricatorShorthand: Use the fabricator shorthand: `fab!(:bar, :foo)`
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe "Foo" do
        fab!(:bar, :foo)
      end
    RUBY
  end
end
