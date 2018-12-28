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

    get 'v2/builds' => 'builds#hint'
    post 'v2/builds' => 'builds#run'
  end

  # Help section
  get 'learn_more' => 'help#about', :as => :about
  get 'help' => 'help#index', :as => :help
  get 'lets_do_javascript' => 'help#javascript_beta', :as => :lets_do_javascript

  get 'help/webhook' => 'help#webhook', :as => :help_webhook
  get 'help/badge' => 'help#badge', :as => :help_badge
  get 'help/grades' => 'help#grades', :as => :help_grades
  get 'help/config_file_yaml' => 'help#config_file_yaml', :as => :help_configuration_yaml
  get 'help/config_file_json' => 'help#config_file_json', :as => :help_configuration_json

  # legacy URLs
  get 'howto/webhook' => 'help#webhook'
  get 'howto/config_file_yaml' => 'help#config_file_yaml'
  get 'howto/config_file_json' => 'help#config_file_json'

  root 'page#welcome'

  namespace :admin do
    get 'overview' => 'overview#index'
    get 'cli' => 'cli#index'
    get 'badges/added' => 'badges#added'
    get 'badges/in_readme' => 'badges#in_readme'

    resources :builds
    resources :projects
    resources :statistics do
      collection do
        get 'added_badges', :as => :added_badges
        get 'days', :as => :daily
        get 'weeks', :as => :weekly
        get 'months', :as => :monthly
      end
    end
    resources :users
  end

  duo    = ':service/:user'
  triple = ':service/:user/:repo'
  triple_constraints = {:service => /(github)/, :repo => /[^\/]+/}
  badge_constraints = {:format => /(png|svg)/}.merge(triple_constraints)
  json_constraints = {:format => /json/}.merge(triple_constraints)

  get "#{duo}" => 'users#show', :format => false
  post "init_projects" => 'users#init_projects', :as => :init_projects
  post "sync_projects" => 'users#sync_projects', :as => :sync_projects
  get "welcome" => 'users#welcome', :as => :welcome

  get "#{triple}/revision/:revision/code_object/:code_object" => 'code_objects#show', :constraints => triple_constraints

  get "#{triple}.:format" => 'projects#badge', :constraints => badge_constraints
  get "#{triple}.:format" => 'projects#show', :constraints => json_constraints

  get "(#{triple})/builds" => 'builds#index', :as => :builds, :constraints => triple_constraints
  #get "#{triple}(/revision/:revision)/list" => 'projects#show', :constraints => triple_constraints
  get "#{triple}(/revision/:revision)/suggestions" => 'projects#suggestions', :constraints => triple_constraints
  get "#{triple}(/revision/:revision)/history" => 'projects#history', :constraints => triple_constraints
  get "#{triple}(/revision/:revision)" => 'projects#show', :constraints => triple_constraints, :format => false

  post "#{triple}/rebuild" => 'projects#rebuild', :constraints => triple_constraints
  post "#{triple}/update_info" => 'projects#update_info', :constraints => triple_constraints
  post "#{triple}/create_hook" => 'projects#create_hook', :constraints => triple_constraints
  post "#{triple}/remove_hook" => 'projects#remove_hook', :constraints => triple_constraints

  get  "#{triple}/edit" => 'projects#edit', :constraints => triple_constraints
  put  "#{triple}" => 'projects#update', :constraints => triple_constraints

  post 'rebuild' => 'projects#rebuild_via_hook'

  resources :builds do
    member do
      get :history_show
    end
  end
  resources :projects

end
