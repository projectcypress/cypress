object @vendor

attributes :address, :created_at, :name, :state, :updated_at, :url, :vendor_id, :zip
child(:pocs) { attributes :contact_type, :created_at, :name, :phone, :updated_at }