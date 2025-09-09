# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  root to: 'home#index'

  get '404', to: 'application#page_not_found'
  get '500', to: 'application#server_error'

  resources :vendors do
    post :favorite, on: :member
    get :preferences
    post :update_preferences
    resources :products, only: %i[show index new create edit update destroy] do
      post :favorite, on: :member
      member do
        get :patients
        get :report
        get :supplemental_test_artifact
      end
    end
    scope module: :vendors do
      resources :records, only: %i[index show new create] do
        collection do
          post :destroy_multiple
          get :by_measure
          get :patient_analysis
        end
      end
    end
  end

  resources :products, only: %i[show edit update destroy] do
    post :favorite, on: :member
    resources :product_tests, only: %i[index show]
    resources :program_tests, only: %i[index show update]
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
        get :by_filter_task
        get :html_filter_patients
      end
    end
  end

  resources :tasks, only: [:show] do
    member do
      get :good_results
    end
    resources :test_executions, only: %i[index show new create destroy]
  end

  resources :test_executions, only: %i[show destroy] do
    member do
      get 'file_result/:file_name', action: 'file_result', as: 'file_result'
    end
  end

  resources :bundles, only: %i[index show] do
    resources :records, only: %i[index show] do
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

  resources :records, only: %i[index show create] do
    collection do
      get :download_mpl
    end
    member do
      get 'highlighted_results/:calculation_result_id', action: 'highlighted_results', as: 'highlighted_results'
    end
  end

  resources :version, only: [:index]

  resources :bundle_downloads, only: %i[index create]

  resources :qrda_uploads, only: [:create], path: '/qrda_validation/:year/:qrda_type/:organization'
  resources :qrda_uploads, only: [:index], path: '/qrda_validation'

  resource :admin, only: [:show], controller: 'admin'

  namespace 'admin' do
    resource :settings, only: %i[show edit update]
    get 'users/send_invitation'
    get :download_logs
    resources :users, except: %i[new create] do
      member do
        get :unlock
        get :toggle_approved
      end
    end
    resources :bundles, except: %i[show edit update] do
      member do
        post :set_default
        post :deprecate
      end
    end
    resources :trackers, only: [:destroy]
  end

  get 'terms_and_conditions' => 'static_pages#terms_and_conditions'
end
