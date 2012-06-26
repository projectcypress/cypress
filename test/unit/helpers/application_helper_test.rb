require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
	test "Should return formatted time" do
		now = Time.now
		formatted_time = now.strftime('%m/%d/%Y')

		assert display_time(now) == formatted_time
		assert display_time('fail') == '?'
	end
end
