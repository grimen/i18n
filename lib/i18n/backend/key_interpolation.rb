module I18n
  module Backend
    module KeyInterpolation
      KEY_INTERPOLATION_SYNTAX_PATTERN = /(\\)?\{\{\:([^\}]+)\}\}/

      def self.included(base)
        base.class_eval do
          alias_method_chain :interpolate, :key_interpolation
        end
      end

      protected

        # Interpolates values into a given string; with extended behavior to support for interpolating
        # explicit I18n keys (reference sub-translations within same document) for DRYer translations.
        #
        # == Base interpolation:
        #
        #   interpolate "file {{file}} opened by \\{{user}}", :file => 'test.txt', :user => 'Mr. X'
        #   # => "file test.txt opened by {{user}}"
        #
        # == Key interpolation:
        #
        #   #   translate :"file.name"
        #   # => "manifesto.txt"
        #
        #   #   interpolate "file {{:file.name}} opened by \\{{user}}", :user => 'Mr. X'
        #   # => "file manifesto.txt opened by {{user}}"
        #
        # Note that you have to double escape the <tt>\\</tt> when you want to escape
        # the <tt>{{...}}</tt> key in a string (once for the string and once for the
        # interpolation).
        def interpolate_with_key_interpolation(locale, string, values = {})
          return string unless string.is_a?(::String)

          preserve_encoding(string) do
            s = string.gsub(KEY_INTERPOLATION_SYNTAX_PATTERN) do
              escaped, key = $1, $2.to_sym

              if escaped
                "\\{{:#{key}}}"
              elsif ::I18n::Backend::Base::RESERVED_KEYS.include?(key)
                raise ReservedInterpolationKey.new(key, string)
              else
                begin
                  value = self.translate(locale, key)
                rescue
                  # DISCUSS: A leaner approach would be: self.translate(locale, key, :default => "{{:#{key}}}")
                  raise KeyError
                end
                # NOTE: Didn't want to mess with I18n String::INTERPOLATION_PATTERN; so using "_" instead of ":".
                key = key.to_s.tr('.', '_').to_sym
                values.merge!(:"_#{key}" => value)
                "{{_#{key}}}"
              end
            end

            self.interpolate_without_key_interpolation(locale, s, values)
          end

        rescue KeyError => e
          raise MissingInterpolationArgument.new(values, string)
        end

    end
  end
end
