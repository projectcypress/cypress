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

  get "/information/about"
  get "/information/feedback"
  get "/information/help"

  match '/measures/minimal_set' => 'measures#minimal_set', via: [:post]
  match '/measures/by_type' => 'measures#by_type', via: [:post]
  match '/product_tests/period', :to=>'product_tests#period', :as => :period, :via=> :post

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', to: 'errors#error_404', via: [:get, :post]
  end

end
