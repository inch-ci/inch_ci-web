class RevisionDiff < ActiveRecord::Base
  belongs_to :branch

  belongs_to :before_revision, :class_name => 'Revision'
  belongs_to :after_revision, :class_name => 'Revision'

  has_many :code_object_diffs, :dependent => :destroy

  validate :branch, :presence => true
  validate :before_revision, :presence => true
  validate :after_revision, :presence => true
end
