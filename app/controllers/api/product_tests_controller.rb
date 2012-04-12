module Api
  class ProductTestsController < ApiController
     before_filter :authenticate_user!
     before_filter :find_product
     before_filter :find_product_test, only: [:show,:destroy]
     respond_to :json
     
     def index
       @product_tests = @product.product_tests
       render :json=>@product_tests
     end

     def create
       pt = JSON.parse(request.body.read)
       product_test = @product.product_tests.create pt
       product_test.save
       #somewhere in here need to create results
       redirect_to api_vendor_product_product_test_url(@vendor,@product,product_test)
     end

     def show
       render :json=>@product_test
     end

     def destroy
       @product_test.destroy
       render text: "", status: 201
     end
     
     
     private 
     
     def find_product_test
       @product_test = @product.product_tests.find(params[:id])
     end
    
  end
  
end