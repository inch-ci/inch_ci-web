class CodeObjectReference < ActiveRecord::Base
  belongs_to :revision
  belongs_to :code_object

  validates :revision, :presence => true
  validates :code_object, :presence => true
end
