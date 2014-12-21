require 'sidekiq/web'

InchCI::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  get "/auth/:provider/callback" => "sessions#create"
  get "/signout" => "sessions#destroy", :as => :signout

  namespace :api do
    get 'v1/cli' => 'cli#hint'
    post 'v1/cli' => 'cli#run'
    get 'v1/builds' => 'builds#hint'
    post 'v1/builds' => 'builds#run'
  end

  duo    = ':service/:user'
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

  get "#{duo}" => 'users#show', :format => false

  get 'learn_more' => 'page#about', :as => :about
  get 'howto/webhook' => 'page#help_webhook', :as => :help_webhook
  root 'page#welcome'

  post "#{triple}(/branch/:branch)/rebuild" => 'projects#rebuild', :constraints => triple_constraints
  post "#{triple}(/branch/:branch)/update_info" => 'projects#update_info', :constraints => triple_constraints

  post 'rebuild' => 'projects#rebuild_via_hook'

  resources :builds
  resources :projects

  namespace :admin do
    get 'overview' => 'overview#index'
    get 'cli' => 'cli#index'
    get 'builds' => 'builds#index'

    resources :projects
  end
end
