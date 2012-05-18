Cypress::Application.routes.draw do
  root :to => "vendors#index"
  
  devise_for :users
  
  resources :vendors, :products

  namespace :api do
    resources :vendors do
      resources :products do
        resources :product_tests do
          resources :patient_population 
          resources :test_executions
        end
      end
    end
  end

  resources :product_tests  do
    member do
      get 'download'
      post 'process_pqri'
      post 'add_note'
      delete 'delete_note'
      post 'email'
    end
    
    resources :patients
    resources :measures do
      member do
        get 'patients'
      end
    end
  end

  resources :patients do
    member do
      get 'download'
    end
    
    collection do
      get 'table'
      get 'table_all'
      get 'table_measure'
      get 'download'
    end
  end
  
  get "/information/about"
  get "/information/feedback"
  get "/information/help"
  
  get '/services/index'
  get '/services/validate_pqri'
  post '/services/validate_pqri'

  match '/measures/minimal_set' => 'measures#minimal_set'
  match '/product_tests/period', :to=>'product_tests#period', :as => :period, :via=> :post
  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
