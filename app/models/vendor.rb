class Vendor
  include Mongoid::Document
  

  has_many :products, dependent: :destroy

  
  # Vendor Details
  field :name, type: String
  field :url, type: String
  field :address, type: String
  field :state, type: String
  field :zip, type: String
  field :poc, type: String
  field :email, type: String
  field :tel, type: String
  field :fax, type: String
  field :vendor_id, type: String
  field :accounts_poc, type: String
  field :accounts_email, type: String
  field :accounts_tel, type: String
  field :tech_poc, type: String
  field :tech_email, type: String
  field :tech_tel, type: String
  field :press_poc, type: String
  field :press_email, type: String
  field :press_tel, type: String  
  
  validates_presence_of :name
  # Get the products owned by this vendor that are failing
  def failing_products
    return self.products.select do |product|
      !product.passing?
    end
  end
  
  # Get the products owned by this vendor that are passing
  def passing_products
    return self.products.select do |product|
      product.passing?
    end
  end
  
  
  # Returns true if all associated Products are passing
  def passing?
    return (self.products.size > 0) ? (self.failing_products.size == 0) : true
  end
  
  # Return the number of currently passing Products
  def count_passing
    return self.passing_products.size
  end
  
  # The percentage of passing products. Returns 0 if no products
  def success_rate
    return 0 if self.products.empty?
    return self.count_passing.to_f / self.products.size
  end
end
