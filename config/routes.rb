Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  root to: 'home#index'

  get '404', to: 'application#page_not_found'
  get '500', to: 'application#server_error'

  resources :vendors do
    post :favorite
    resources :products, only: [:show, :index, :new, :create, :edit, :update, :destroy, :favorite] do
      post :favorite
      member do
        get :patients
        get :report
      end
    end
  end

  resources :products, only: [:show, :edit, :update, :destroy, :favorite] do
    post :favorite
    resources :product_tests, only: [:index, :show]
    resources :checklist_tests, only: [:create, :show, :update, :destroy] do
      member do
        get :print_criteria
      end
    end
    member do
      get :download_full_test_deck
    end
  end

  resources :checklist_tests, only: [:create, :show, :update, :destroy] do
    member do
      get 'measure/:measure_id', action: 'measure', as: 'measure'
    end
  end

  resources :product_tests, only: [:show] do
    member do
      get :patients
      get :html_patients
    end
    resources :tasks, only: [:index, :show]
    resources :records, only: [:index, :show]
  end

  resources :tasks, only: [:show] do
    member do
      get :good_results
    end
    resources :test_executions, only: [:index, :show, :new, :create, :destroy]
  end

  resources :test_executions, only: [:show, :destroy] do
    member do
      get 'file_result/:file_name', action: 'file_result', as: 'file_result'
    end
  end

  resources :bundles, only: [:index, :show] do
    resources :records, only: [:index, :show] do
      collection do
        get :by_measure
      end
    end
    resources :measures, only: [:index] do
      collection do
        get :grouped
        get 'filtered(/:filter)', to: 'measures#filtered'
      end
    end
  end

  resources :records, only: [:index, :show] do
    collection do
      get :download_mpl
    end
  end

  resource :admin, only: [:show], controller: 'admin'

  namespace 'admin' do
    resource :settings, only: [:show, :edit, :update]
    get 'users/send_invitation'
    get :download_logs
    resources :users do
      member do
        get :unlock
        get :toggle_approved
      end
    end
    resources :bundles, except: [:update] do
      member do
        post :set_default
      end
    end
    resources :trackers, only: [:destroy]
  end

  get 'terms_and_conditions' => 'static_pages#terms_and_conditions'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
