Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: "admin/dashboard#index"

  resources :reports, only: [:index] do
    collection do
      get 'batch/:batch_id', action: :batch
      get 'date/:date_from/to/:date_to', action: :date
    end
  end
end
