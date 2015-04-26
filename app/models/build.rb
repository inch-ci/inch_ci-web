class Build < ActiveRecord::Base
  has_one :project, :through => :branch
  belongs_to :branch
  belongs_to :revision
  has_one :revision_diff, :primary_key => "revision_id", :foreign_key => "after_revision_id"

  validates :branch, :presence => true
  validates :status, :presence => true
end
