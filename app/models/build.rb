class Build < ActiveRecord::Base
  has_one :project, :through => :branch
  belongs_to :branch
  belongs_to :revision

  validates :branch, :presence => true
  validates :status, :presence => true
end
