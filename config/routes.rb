Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'welcome#index'

  get 'welcome/index'

  resources :demographics
  resources :divisions
  resources :schools
  resources :scores do
    get 'chart', :on => :collection
  end

  # resources :solIds

end
