module ActiveEnumerable
  module Scopes
    include ScopeMethod
    def method_missing(meth, *args, &block)
      if create_scope_method(meth)
        send(meth, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(meth, _include_private = false)
      create_scope_method(meth)
    end

    def create_scope_method(meth)
      if (scope = self.class.__scoped_methods__.find { |a| a.first == meth })
        self.define_singleton_method(scope.first) do
          scope(&scope.last)
        end
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
