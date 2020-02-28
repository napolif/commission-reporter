Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: "reports#index"

  resources :reports, only: [:index] do
    collection do
      get 'batch/:batch_id', action: :batch, as: 'by_batch'
      # get 'date/:date_from/to/:date_to', action: :date, as: 'by_date'
    end
  end

  resources :batches, only: [] do
    collection do
      post 'upload'
      get 'upload', to: redirect("reports#index")
    end
  end
end
