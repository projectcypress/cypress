AfterStep do
  next unless ENV['IN_BROWSER'] == 'true'

  pause = ENV.fetch('PAUSE', '0').to_i
  sleep(pause) if pause > 0
end
