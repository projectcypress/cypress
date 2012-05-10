require 'atna'

Warden::Manager.after_authentication do |user,auth,opts|
  Log.create(:username => user.email, :event => 'login')
end

Warden::Manager.before_failure do |env, opts|
  request = Rack::Request.new(env)
  attempted_login_name = request.params["user"].try(:[], "email")
  attempted_login_name ||= 'unknown'
  Log.create(:username => attempted_login_name, :event => 'failed login attempt')
end

Warden::Manager.before_logout do |user,auth,opts|
  Log.create(:username => user.email, :event => 'logout')
end