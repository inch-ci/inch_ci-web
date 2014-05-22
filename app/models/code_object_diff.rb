class CodeObjectDiff < ActiveRecord::Base
  belongs_to :revision_diff

  belongs_to :before_object, :class_name => 'CodeObject'
  belongs_to :after_object, :class_name => 'CodeObject'

  validate :revision_diff, :presence => true
  validate :before_object, :presence => true
  validate :after_object, :presence => true
end
