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

  get 'learn_more' => 'page#about', :as => :about
  get 'howto/webhook' => 'page#help_webhook', :as => :help_webhook
  root 'page#welcome'

  namespace :admin do
    get 'overview' => 'overview#index'
    get 'cli' => 'cli#index'

    resources :builds
    resources :projects
    resources :statistics do
      collection do
        get 'days', :as => :daily
        get 'weeks', :as => :weekly
        get 'months', :as => :monthly
      end
    end
    resources :users
  end

  duo    = ':service/:user'
  triple = ':service/:user/:repo'
  triple_constraints = {:repo => /[^\/]+/, :branch => /[^\/]+/}
  badge_constraints = {:format => /(png|svg)/}.merge(triple_constraints)

  get "#{duo}" => 'users#show', :format => false
  post "init_projects" => 'users#init_projects', :as => :init_projects
  post "sync_projects" => 'users#sync_projects', :as => :sync_projects
  get "welcome" => 'users#welcome', :as => :welcome

  get "#{triple}/branch/:branch/revision/:revision/code_object/:code_object" => 'code_objects#show', :constraints => triple_constraints

  get "#{triple}.:format" => 'projects#badge', :constraints => badge_constraints

  get "/dashboard" => 'builds#dashboard', :as => :dashboard
  get "(#{triple}(/branch/:branch))/builds" => 'builds#index', :as => :builds, :constraints => triple_constraints
  #get "#{triple}(/branch/:branch)(/revision/:revision)/list" => 'projects#show', :constraints => triple_constraints
  get "#{triple}(/branch/:branch)(/revision/:revision)/suggestions" => 'projects#suggestions', :constraints => triple_constraints
  get "#{triple}(/branch/:branch)(/revision/:revision)/history" => 'projects#history', :constraints => triple_constraints
  get "#{triple}(/branch/:branch)(/revision/:revision)" => 'projects#show', :constraints => triple_constraints, :format => false

  post "#{triple}(/branch/:branch)/rebuild" => 'projects#rebuild', :constraints => triple_constraints
  post "#{triple}(/branch/:branch)/update_info" => 'projects#update_info', :constraints => triple_constraints
  post "#{triple}(/branch/:branch)/create_hook" => 'projects#create_hook', :constraints => triple_constraints
  post "#{triple}(/branch/:branch)/remove_hook" => 'projects#remove_hook', :constraints => triple_constraints

  post 'rebuild' => 'projects#rebuild_via_hook'

  resources :builds
  resources :projects

end
