module VendorsHelper

  def vendors_by_status(vendors)
    passing_vendors = []
    failing_vendors = []
    vendors.all.each do |vendor|
      if !vendor.products.empty? && vendor.passing?
        passing_vendors << vendor
      else
        failing_vendors << vendor
      end
    end
   { 'fail' => failing_vendors, 'pass' => passing_vendors }
  end
    
    
  def products_by_status(vendor)
    
    failing_products = vendor.failing_products
    passing_products = vendor.passing_products
    { 'fail' => failing_products, 'pass' => passing_products }  
    
  end  
  

  
end