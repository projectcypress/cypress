After do |scenario|
  if scenario.failed?
    # When a scenario fails, stop running tests and open the current page.
    Cucumber.wants_to_quit = true
  end
end
