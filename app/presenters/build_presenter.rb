class BuildPresenter < BasePresenter
  def_delegators :build, :status, :trigger, :started_at, :finished_at
  def_delegators :build, :branch, :revision, :number, :stderr

  use_presenters :revision

  def duration
    finished_at.to_i - started_at.to_i
  end
end
