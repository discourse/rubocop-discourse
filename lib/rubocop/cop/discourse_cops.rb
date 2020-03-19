# frozen_string_literal: true

module RuboCop
  module Cop
    module DiscourseCops
      # Avoid using chdir - it is not thread safe.
      #
      # Instead, you may be able to use:
      # Discourse::Utils.execute_command(chdir: 'test') do |runner|
      #   runner.exec('pwd')
      # end
      #
      # @example
      #   # bad
      #   Dir.chdir('test')
      class NoChdir < Cop
        MSG = 'Chdir is not thread safe.'

        def_node_matcher :using_dir_chdir?, <<-MATCHER
          (send (const nil? :Dir) :chdir ...)
        MATCHER

        def_node_matcher :using_fileutils_cd?, <<-MATCHER
          (send (const nil? :FileUtils) :cd ...)
        MATCHER

        def on_send(node)
          return if !(using_dir_chdir?(node) || using_fileutils_cd?(node))
          add_offense(node, message: MSG)
        end
      end

      # Do not use URI.escape and its ilk, they are deprecated
      # with a warning in the ruby source. Instead use
      # Addressable::URI, which has encode, encode_component,
      # and unencode methods. UrlHelper has helper methods for this.
      #
      # # @example
      #   # bad
      #   URI.encode("https://a%20a.com?a='a%22")
      #
      #   # good
      #   UrlHelper.encode("https://a%20a.com?a='a%22")
      #   Addressable::URI.encode("https://a%20a.com?a='a%22")
      class NoURIEscapeEncode < Cop
        MSG = 'URI.escape, URI.encode, URI.unescape, URI.decode are deprecated and should not be used.'

        def_node_matcher :using_uri_escape?, <<-MATCHER
          (send (const nil? :URI) :escape ...)
        MATCHER

        def_node_matcher :using_uri_encode?, <<-MATCHER
          (send (const nil? :URI) :encode ...)
        MATCHER

        def_node_matcher :using_uri_unescape?, <<-MATCHER
          (send (const nil? :URI) :unescape ...)
        MATCHER

        def_node_matcher :using_uri_decode?, <<-MATCHER
          (send (const nil? :URI) :decode ...)
        MATCHER

        def on_send(node)
          return if [
            using_uri_escape?(node),
            using_uri_encode?(node),
            using_uri_unescape?(node),
            using_uri_decode?(node)
          ].none?
          add_offense(node, message: MSG)
        end
      end

      # Use `Time.zone.now` instead of `Time.new` without arguments.
      #
      # @example
      #   # bad
      #   now = Time.new
      #
      #   # good
      #   now = Time.zone.now
      class NoTimeNewWithoutArgs < Cop
        MSG = "Use `Time.zone.now` instead of `Time.new` without arguments."

        def_node_matcher :time_new_without_args?, <<-MATCHER
          (send (const nil? :Time) :new)
        MATCHER

        def on_send(node)
          return unless time_new_without_args?(node)

          add_offense(node, message: MSG)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, "Time.zone.now")
          end
        end
      end
    end
  end
end
