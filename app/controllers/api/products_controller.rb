module Api
  class ProductsController < ApiController
    before_filter :authenticate_user!
    before_filter :find_vendor
    before_filter :find_product , :only=>[:show, :update, :destroy]
    respond_to :json
    
    def index
      @products = @vendor.products
      render json: @products
    end
    
    def create
      prod = JSON.parse(request.body.read)
      @product = @vendor.products.create prod
      @product.save
      redirect_to api_vendor_product_path(@vendor,@product)
    end
    
    def update
      prod = JSON.parse(request.body.read)
      @product.update_attributes prod
      @product.save
      redirect_to api_vendor_product_path(@vendor,@product)
    end
    
    def show
      render :json=>@product
    end
    
    def destroy
      @product.destroy
      render text: "", status: 201
    end
    
    
    private 
    
    def find_product
      find_vendor unless @vendor
      @product = @vendor.products.find(params[:id])
    end
    
  end
  
end