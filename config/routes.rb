Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  root to: 'home#index'

  get '404', to: 'application#page_not_found'
  get '500', to: 'application#server_error'

  resources :vendors do
    post :favorite
    get :preferences
    post :update_preferences
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

  resources :bundles, only: %i[index show] do
    resources :records, only: %i[index show] do
      collection do
        get :by_measure
      end
    end
    resources :measures, only: [:index]
  end

  resources :records, only: %i[index show create] do
    collection do
      get :download_mpl
    end
  end

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
