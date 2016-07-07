require 'sidekiq/web'
require 'sidekiq/cron/web'
Rails.application.routes.draw do
  resources :products
  mount Sidekiq::Web => '/sidekiq'
end
