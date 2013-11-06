CarrierWave.configure do |config|

	if Rails.env.test? 
		config.root = "./tmp"
	else
		config.root = Rails.root
	end
end