Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  root to: 'home#index'

  get '404', to: 'application#page_not_found'
  get '500', to: 'application#server_error'

  resources :vendors do
    post :favorite
    resources :products, only: %i[show index new create edit update destroy favorite] do
      post :favorite
      member do
        get :patients
        get :report
        get :supplemental_test_artifact
      end
    end
  end

  resources :products, only: %i[show edit update destroy favorite] do
    post :favorite
    resources :product_tests, only: %i[index show]
    resources :checklist_tests, only: %i[create show update destroy] do
      member do
        get :print_criteria
      end
    end
    member do
      get :download_full_test_deck
    end
  end

  resources :checklist_tests, only: %i[create show update destroy] do
    member do
      get 'measure/:measure_id', action: 'measure', as: 'measure'
    end
  end

  resources :product_tests, only: [:show] do
    member do
      get :patients
      get :html_patients
    end
    resources :tasks, only: %i[index show]
    resources :records, only: %i[index show] do
      collection do
        resources :tasks, :controller => :records, :only => [:by_filter_task] do
          get :by_filter_task
        end
      end
    end
  end

  resources :tasks, :only => [:show] do
    member do
      get :good_results
    end
    resources :test_executions, :only => %i[index show new create destroy]
  end

  resources :test_executions, :only => %i[show destroy] do
    member do
      get 'file_result/:file_name', :action => 'file_result', :as => 'file_result'
    end
  end

  resources :bundles, :only => %i[index show] do
    resources :records, :only => %i[index show] do
      collection do
        get :by_measure
      end
    end
    resources :measures, :only => [:index] do
      collection do
        get :grouped
        get 'filtered(/:filter)', :to => 'measures#filtered'
      end
    end
  end

  resources :records, :only => %i[index show] do
    collection do
      get :download_mpl
    end
  end

  resource :admin, :only => [:show], :controller => 'admin'

  namespace 'admin' do
    resource :settings, :only => %i[show edit update]
    get 'users/send_invitation'
    get :download_logs
    resources :users, :except => %i[new create] do
      member do
        get :unlock
        get :toggle_approved
      end
    end
    resources :bundles, :except => %i[show edit update] do
      member do
        post :set_default
        post :deprecate
      end
    end
    resources :trackers, :only => [:destroy]
  end

  get 'terms_and_conditions' => 'static_pages#terms_and_conditions'
end
