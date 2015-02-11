require 'inch_ci/controller'

class Admin::BuildsController < ApplicationController
  include InchCI::Controller

  layout 'admin'

  PER_PAGE = 200
  def index
    set_builds
    @languages = %w(Elixir JavaScript Ruby)
  end

  def show
    view = Action::Build::Show.new(params, load_dump: true)
    expose view
  end

  private

  def set_builds
    @builds = find_builds.map do |build|
        BuildPresenter.new(build)
      end
    @scheduled_builds = @builds.select { |b| b.status == 'created' }
    @running_builds = @builds.select { |b| b.status == 'running' }
    @completed_builds = @builds.select { |b| !%w(created running).include?(b.status) }
  end

  def filter_collection(arel)
    arel = arel.references(:branch).joins(:project)
    if params[:language].present?
      arel = arel.where('LOWER(projects.language) = ?', params[:language].to_s.downcase)
    end
    if params[:statuses].present?
      @statuses = params[:statuses]
      arel = arel.where(:status => @statuses)
    end
    if params[:triggers].present?
      @triggers = params[:triggers]
      arel = arel.where(:trigger => @triggers)
    end
    if uid = params[:uid].presence
      arel = arel.where('projects.uid LIKE ?', "%#{uid}%")
    end
    if params[:service]
      arel = filter_by_service_and_user(arel, params[:service], params[:user])
    end
    arel
  end

  def filter_by_service_and_user(arel, service, user_name)
    like = "#{service}:"
    if user_name
      like << "#{user_name}/"
    end
    arel.where('projects.uid LIKE ?', like+'%')
  end

  def find_builds
    filter_collection(Build).order('created_at DESC').limit(PER_PAGE)
  end
end
