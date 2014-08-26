class Branch < ActiveRecord::Base
  belongs_to :project
  has_many :revisions, -> { order 'created_at DESC' }, :dependent => :destroy
  has_many :revision_diffs, :dependent => :destroy
  has_many :builds, -> { order 'number DESC' }, :dependent => :destroy

  belongs_to :latest_revision, :class_name => 'Revision'

  validate :name, :presence => true, :uniqueness => {:scope => :project}
end
