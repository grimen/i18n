# encoding: utf-8
I18n::Backend::Base.class_eval do
  include ::I18n::Backend::KeyInterpolation
end

module Tests
  module Api
    module KeyInterpolation
      def interpolate(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        key = args.pop
        ::I18n.backend.translate('en', key, options)
      end

      define_method "test key interpolation: given interpolation key but missing this key it raises I18n::MissingInterpolationArgument" do
        assert_raise(::I18n::MissingInterpolationArgument) do
          interpolate(:default => 'Hi {{:name}}!')
        end

        assert_raise(::I18n::MissingInterpolationArgument) do
          interpolate(:default => 'Hi {{:name}}!', :name => 'David')
        end
      end

      define_method "test key interpolation: given valid interpolation translation key it should interpolate the valid translation string" do
        ::I18n.backend.store_translations(:en, :name => 'David')
        assert_equal 'Hi David!', interpolate(:default => 'Hi {{:name}}!')

        ::I18n.backend.store_translations(:en, :"a.deeply.nested.name" => 'Goliath')
        assert_equal 'Hi Goliath!', interpolate(:default => 'Hi {{:a.deeply.nested.name}}!')
      end

      define_method "test interpolation: given the translation is in utf-8 it still works" do
        ::I18n.backend.store_translations(:en, :name => 'David')
        assert_equal 'Häi David!', interpolate(:default => 'Häi {{:name}}!')

        ::I18n.backend.store_translations(:en, :"a.deeply.nested.name" => 'Goliath')
        assert_equal 'Hi Goliath!', interpolate(:default => 'Hi {{:a.deeply.nested.name}}!')
      end

      define_method "test interpolation: given the value is in utf-8 it still works" do
        ::I18n.backend.store_translations(:en, :name => 'ゆきひろ')
        assert_equal 'Hi ゆきひろ!', interpolate(:default => 'Hi {{:name}}!')

        ::I18n.backend.store_translations(:en, :"a.deeply.nested.name" => 'デビッド')
        assert_equal 'Hi デビッド!', interpolate(:default => 'Hi {{:a.deeply.nested.name}}!')
      end

      define_method "test interpolation: given the translation and the value are in utf-8 it still works" do
        ::I18n.backend.store_translations(:en, :name => 'ゆきひろ')
        assert_equal 'こんにちは、ゆきひろさん!', interpolate(:default => 'こんにちは、{{:name}}さん!')

        ::I18n.backend.store_translations(:en, :"a.deeply.nested.name" => 'デビッド')
        assert_equal 'こんにちは デビッドさん!', interpolate(:default => 'こんにちは {{:a.deeply.nested.name}}さん!')
      end

    end
  end
end
