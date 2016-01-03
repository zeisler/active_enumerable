module ActiveEnumerable
  module Scopes
    def method_missing(meth, *args, &block)
      if create_scope_method(meth)
        send(meth, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(meth, include_private = false)
      if create_scope_method(meth)
        true
      else
        super
      end
    end

    def create_scope_method(meth)
      if (scope = self.class.__scoped_methods__.find { |a| a.first == meth })
        self.define_singleton_method(scope.first) do
          scope(&scope.last)
        end
      end
    end

    def scope(&block)
      result = instance_exec(&block)
      if result.is_a? Array
        __new_relation__(result)
      else
        result
      end
    end

    private :create_scope_method

    module ClassMethods
      def scope(name, block)
        __scoped_methods__ << [name, block]
      end

      def __scoped_methods__
        @__scoped_methods__ ||= []
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
