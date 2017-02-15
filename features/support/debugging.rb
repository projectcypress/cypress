After do |scenario|
  if scenario.failed?
    # When a scenario fails, print the page source and stop running tests.
    Cucumber.logger.info page.html
    Cucumber.wants_to_quit = true
  end
end
