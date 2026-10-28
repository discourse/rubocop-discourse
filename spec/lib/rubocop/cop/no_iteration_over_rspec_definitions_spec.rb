# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Discourse::NoIterationOverRSpecDefinitions, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::ConfigLoader.load_file(
      File.join(Gem.loaded_specs.fetch("rubocop-rspec").full_gem_path, "config/default.yml"),
    )
  end

  it "reports examples generated with each" do
    expect_offense(<<~RUBY)
      RSpec.describe User do
        [:admin, :moderator].each do |role|
          it "allows access for \#{role}" do
          ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
            expect(access_for(role)).to be_allowed
          end
        end
      end
    RUBY
  end

  it "reports a generated context without repeating offenses for its examples" do
    expect_offense(<<~RUBY)
      roles.each do |role|
        context "with \#{role}" do
        ^^^^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
          it("allows access") { expect(access_for(role)).to be_allowed }
        end
      end
    RUBY
  end

  it "reports explicit RSpec groups inside iterators" do
    expect_offense(<<~RUBY)
      models.map do |model|
        ::RSpec.describe model do
                ^^^^^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
        end
      end
    RUBY
  end

  it "reports examples declared without a block" do
    expect_offense(<<~RUBY)
      roles.each do |role|
        it "allows access for \#{role}"
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports focused and skipped aliases" do
    expect_offense(<<~RUBY)
      roles.each do |role|
        fcontext "with \#{role}" do
        ^^^^^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
        end
        xit("allows access") { expect(access_for(role)).to be_allowed }
        ^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports the specify alias" do
    expect_offense(<<~RUBY)
      roles.each do |role|
        specify("access") { expect(access_for(role)).to be_allowed }
        ^^^^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports definitions in numbered blocks" do
    expect_offense(<<~RUBY)
      roles.each do
        describe(_1) do
        ^^^^^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
        end
      end
    RUBY
  end

  it "reports examples nested under a conditional in an iterator" do
    expect_offense(<<~RUBY)
      roles.each do |role|
        if supported?(role)
          it("allows access") { expect(access_for(role)).to be_allowed }
          ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
        end
      end
    RUBY
  end

  it "reports definitions inside nested iterator blocks once" do
    expect_offense(<<~RUBY)
      roles.each do |role|
        states.each_with_index do |state, index|
          it("allows access") { expect(access_for(role, state)).to be_allowed }
          ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
        end
      end
    RUBY
  end

  it "reports definitions inside times" do
    expect_offense(<<~RUBY)
      3.times do |index|
        it("allows access") { expect(access_for(index)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports definitions inside chained enumerators" do
    expect_offense(<<~RUBY)
      roles.each.with_index do |role, index|
        it("allows access") { expect(access_for(role)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports definitions inside Enumerable blocks" do
    expect_offense(<<~RUBY)
      roles.sort_by do |role|
        it("allows access") { expect(access_for(role)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports definitions inside array combination blocks" do
    expect_offense(<<~RUBY)
      roles.combination(2) do |pair|
        it("allows access") { expect(access_for(pair)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports definitions inside iterators using safe navigation" do
    expect_offense(<<~RUBY)
      roles&.each do |role|
        it("allows access") { expect(access_for(role)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports definitions inside for loops" do
    expect_offense(<<~RUBY)
      for role in roles
        it("allows access") { expect(access_for(role)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports definitions inside while loops" do
    expect_offense(<<~RUBY)
      while role = roles.shift
        it("allows access") { expect(access_for(role)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports definitions inside until loops" do
    expect_offense(<<~RUBY)
      until roles.empty?
        it("allows access") { expect(access_for(roles.shift)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "reports definitions inside postcondition loops" do
    expect_offense(<<~RUBY)
      begin
        it("allows access") { expect(access_for(role)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end while next_role?
    RUBY
  end

  it "reports definitions inside loop blocks" do
    expect_offense(<<~RUBY)
      loop do
        it("allows access") { expect(access_for(role)).to be_allowed }
        ^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
        break
      end
    RUBY
  end

  it "recognizes configured group aliases" do
    config["RSpec"]["Language"]["ExampleGroups"]["Regular"] << "custom_group"

    expect_offense(<<~RUBY)
      roles.each do |role|
        custom_group "access" do
        ^^^^^^^^^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
        end
      end
    RUBY
  end

  it "uses upstream aliases without loading the RSpec plugin configuration" do
    config.delete("RSpec")

    expect_offense(<<~RUBY)
      roles.each do |role|
        context "with \#{role}" do
        ^^^^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
        end
      end
    RUBY
  end

  it "recognizes configured example aliases" do
    config["RSpec"]["Language"]["Examples"]["Regular"] << "custom_example"

    expect_offense(<<~RUBY)
      roles.each do |role|
        custom_example("access") { expect(access_for(role)).to be_allowed }
        ^^^^^^^^^^^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "allows explicit groups and examples" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        context "with an admin" do
          it("allows access") { expect(access_for(:admin)).to be_allowed }
        end
      end
    RUBY
  end

  it "ignores custom names unless they are configured as aliases" do
    expect_no_offenses(<<~RUBY)
      roles.each do |role|
        custom_group "access" do
        end
        custom_example("access") { expect(access_for(role)).to be_allowed }
      end
    RUBY
  end

  it "reports skipped and pending declarations at group scope" do
    expect_offense(<<~RUBY)
      roles.each do |role|
        skip("allows access") { expect(access_for(role)).to be_allowed }
        ^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
        pending "checks access for \#{role}"
        ^^^^^^^ Do not generate RSpec examples or groups with iterators. Write each definition explicitly.
      end
    RUBY
  end

  it "allows runtime skip and pending inside example loops" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        it "checks adapters" do
          adapters.each do |adapter|
            skip "unsupported adapter" unless adapter.supported?
            pending "not implemented" if adapter.unimplemented?
          end
        end
      end
    RUBY
  end

  it "allows runtime skip inside setup loops" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        before do
          adapters.each { |adapter| skip "unsupported adapter" unless adapter.supported? }
        end
      end
    RUBY
  end

  it "allows runtime controls inside helpers and subjects" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        let(:adapters) do
          configured_adapters.map { |adapter| skip "unsupported" unless adapter.supported? }
        end
        subject do
          adapters.map { |adapter| pending "not implemented" if adapter.unimplemented? }
        end
      end
    RUBY
  end

  it "allows implicit it references in setup loops under the shared Ruby target" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        before { users.each { it.activate! } }
      end
    RUBY
  end

  it "allows runtime controls inside numbered example blocks" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        it("checks adapters") do
          adapters.each { |adapter| skip "unsupported" unless adapter.supported? }
          expect(_1).to be_present
        end
      end
    RUBY
  end

  it "allows iteration inside examples and hooks" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        before { users.each { |user| user.activate! } }

        it "allows access" do
          roles.each { |role| expect(access_for(role)).to be_allowed }
        end
      end
    RUBY
  end

  it "allows iteration that builds example arguments" do
    expect_no_offenses(<<~RUBY)
      RSpec.describe User do
        it(roles.map(&:name).join(", ")) { expect(access).to be_allowed }
      end
    RUBY
  end

  it "allows unrelated methods with RSpec names" do
    expect_no_offenses(<<~RUBY)
      objects.each do |object|
        object.describe "access" do
        end
        object.context "access"
        object.it "access"
      end
    RUBY
  end

  it "allows blocks that do not iterate" do
    expect_no_offenses(<<~RUBY)
      freeze_time do
        describe User do
          it("allows access") { expect(access).to be_allowed }
        end
      end
    RUBY
  end

  it "does not follow an iterator into a method definition" do
    expect_no_offenses(<<~RUBY)
      objects.each do |object|
        def define_examples
          it("allows access") { expect(access).to be_allowed }
        end
      end
    RUBY
  end
end
