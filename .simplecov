SimpleCov.start 'rails' do
  merge_timeout 3600
end

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov
