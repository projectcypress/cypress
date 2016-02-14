Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }
  root to: 'home#index'

  resources :vendors do
    resources :products, only: [:show, :index, :new, :create, :edit, :update, :destroy] do
    end
  end

  resources :products, only: [:show, :edit, :update, :destroy] do
    resources :product_tests, only: [:index, :new, :create, :show]
    resources :checklist_tests, only: [:create, :show, :update, :destroy]
  end

  resources :product_tests, only: [:show, :edit, :update, :destroy] do
    member do
      get :download
    end
    resources :tasks, only: [:index, :new, :create]
    resources :records, only: [:index]
  end

  resources :tasks, only: [:show, :edit, :update, :destroy] do
    resources :test_executions, only: [:show, :new]
  end

  resources :test_executions, only: [:show, :create, :destroy]

  resources :bundles do
    member do
      post :set_default
    end

    resources :records, only: [:index]
  end

  resources :records, only: [:index, :show] do
    collection do
      get :by_measure
    end

    member do
      get :download_full_test_deck
    end
  end
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
