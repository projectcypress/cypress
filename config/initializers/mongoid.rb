module BSON
  class ObjectId
    def to_json(*args)
      to_s.to_json
    end

    def as_json(*args)
      to_s.as_json
    end
  end
end

Mongoid::Tasks::Database.create_indexes if Rails.env.production? && !ENV['DISABLE_DB']
