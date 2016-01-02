$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_enumerable'

RSpec.configure do |config|

  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end

end
