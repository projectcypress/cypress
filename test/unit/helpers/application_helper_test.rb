require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
	test "Should return formatted time" do
		assert display_time(1301529600) == '03/30/2011'
		assert display_time('fail') == '?'
	end
end
