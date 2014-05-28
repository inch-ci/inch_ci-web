class RevisionPresenter < BasePresenter
  def_delegators :revision, :diff, :tag_uid
  def_delegators :message, :author_name, :author_email, :authored_at

  def_delegators :revision, :branch, :project
  use_presenters :builds, :code_objects

  def uid(short = true)
    short ? revision.uid[0..7] : revision.uid
  end
end
