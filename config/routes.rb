require 'sidekiq/web'

InchCI::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  triple = ':service/:user/:repo'
  triple_constraints = {:branch => /[^\/]+(?<!\.js)/}

  get "#{triple}.png" => 'projects#badge', :constraints => triple_constraints
  get "#{triple}.svg" => 'projects#badge', :constraints => triple_constraints
  get "(#{triple}(/branch/:branch))/builds" => 'builds#index', :as => :builds, :constraints => triple_constraints
  get "#{triple}(/branch/:branch)(/revision/:revision)/list" => 'projects#show', :constraints => triple_constraints
  get "#{triple}(/branch/:branch)(/revision/:revision)" => 'projects#page', :constraints => triple_constraints

  get 'learn_more' => 'page#about', :as => :about
  get 'howto/webhook' => 'page#help_webhook', :as => :help_webhook
  root 'page#welcome'

  post "#{triple}(/branch/:branch)/rebuild" => 'projects#rebuild', :constraints => triple_constraints
  post "#{triple}(/branch/:branch)/update_info" => 'projects#update_info', :constraints => triple_constraints

  post 'rebuild' => 'projects#rebuild_via_hook'

  resources :builds
  resources :projects
end
