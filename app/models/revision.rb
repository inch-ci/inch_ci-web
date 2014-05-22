class Revision < ActiveRecord::Base
  belongs_to :branch

  has_one :diff, :class_name => "RevisionDiff", :foreign_key => :after_revision_id

  has_many :builds
  has_many :code_object_references, :dependent => :destroy
  has_many :code_objects, :through => :code_object_references

  validates :uid, :presence => true
end
