Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: "reports#index"

  resources :reports, only: [:index] do
    collection do
      get "batch", action: :batch, as: "by_batch"
      get "date", action: :date, as: "by_date"
    end
  end

  resources :batches, only: [:show] do
    collection do
      post 'upload'
      get 'upload', to: redirect("reports#index")
    end
  end
end
