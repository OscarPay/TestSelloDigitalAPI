Rails.application.routes.draw do

  root to: 'invoices#index'

  resources :invoices, only: [:index, :new, :edit, :destroy]
  get "invoices/new_full" => "invoices#new_full"

end
