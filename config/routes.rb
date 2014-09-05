require 'sidekiq/web'

InchCI::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  get 'api/v1/cli' => 'api/cli#hint'
  post 'api/v1/cli' => 'api/cli#run'

  triple = ':service/:user/:repo'
  triple_constraints = {:repo => /[^\/]+/, :branch => /[^\/]+/}
  badge_constraints = {:format => /(png|svg)/}.merge(triple_constraints)

  get "#{triple}/branch/:branch/revision/:revision/code_object/:code_object" => 'code_objects#show', :constraints => triple_constraints

  get "#{triple}.:format" => 'projects#badge', :constraints => badge_constraints

  get "/dashboard" => 'builds#dashboard', :as => :dashboard
  get "(#{triple}(/branch/:branch))/builds" => 'builds#index', :as => :builds, :constraints => triple_constraints
  #get "#{triple}(/branch/:branch)(/revision/:revision)/list" => 'projects#show', :constraints => triple_constraints
  get "#{triple}(/branch/:branch)(/revision/:revision)/suggestions" => 'projects#suggestions', :constraints => triple_constraints
  get "#{triple}(/branch/:branch)(/revision/:revision)/history" => 'projects#history', :constraints => triple_constraints
  get "#{triple}(/branch/:branch)(/revision/:revision)" => 'projects#show', :constraints => triple_constraints, :format => false

  get 'learn_more' => 'page#about', :as => :about
  get 'howto/webhook' => 'page#help_webhook', :as => :help_webhook
  root 'page#welcome'

  post "#{triple}(/branch/:branch)/rebuild" => 'projects#rebuild', :constraints => triple_constraints
  post "#{triple}(/branch/:branch)/update_info" => 'projects#update_info', :constraints => triple_constraints

  post 'rebuild' => 'projects#rebuild_via_hook'

  resources :builds
  resources :projects
end
