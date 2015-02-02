Cypress::Application.routes.draw do
  root :to => "vendors#index"
  #match "/delayed_job" => DelayedJobMongoidWeb, :anchor => false
  devise_for :users

  get '/admin' => 'admin#index'
  get "/admin/index"
  get "/admin/users"
  post "/admin/promote"
  post "/admin/demote"
  post "/admin/approve"
  post "/admin/disable"
  post "/admin/import_bundle"
  post "/admin/activate_bundle"
  get "/admin/delete_bundle"
  post "/admin/clear_database"



  resources :vendors, :products

    resources :vendors do
      resources :products do
        resources :product_tests do
          resources :patient_population
          resources :test_executions
        end
      end
    end

   resources :measures do
     get 'definition'
   end

  resources :test_executions do
    member do
      get 'download'
    end
  end

  resources :product_tests  do
    resources :test_executions
    member do
      get 'download'
      post 'process_pqri'
      post 'add_note'
      delete 'delete_note'
      post 'email'
      get 'qrda_cat3'
      get 'status'
      get 'generate_cat1_test'
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

  resources :measures do
      member do
        get 'patients'
      end
    end

  get "/information/feedback"

  get '/services/index'
  get '/services/validate_pqri'
  post '/services/validate_pqri'

  match '/measures/minimal_set' => 'measures#minimal_set', via: [:post]
  match '/measures/by_type' => 'measures#by_type', via: [:post]
  match '/product_tests/period', :to=>'product_tests#period', :as => :period, :via=> :post

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', to: 'errors#error_404', via: [:get, :post]
  end

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
   #match ':controller(/:action(/:id(.:format)))'
end
