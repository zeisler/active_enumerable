module ActiveEnumerable
  module Comparable
    include ::Comparable

    def <=>(anOther)
      if anOther.is_a?(Array) || self.class == anOther.class
        to_a <=> anOther.to_a
      end
    end
  end
end
