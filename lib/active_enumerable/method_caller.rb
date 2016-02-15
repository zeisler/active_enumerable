module ActiveEnumerable
  # @private
  class MethodCaller
    attr_reader :object, :raise_no_method

    def initialize(object, raise_no_method: true)
      @object          = object
      @raise_no_method = raise_no_method
    end

    def call(method)
      if object.is_a? Hash
        object.fetch(method)
      else
        object.public_send(method)
      end
    rescue NoMethodError => e
      raise e if raise_no_method
    rescue KeyError => e
      raise e, "#{e.message} for #{object}" if raise_no_method
    end
  end
end
