class Project < ActiveRecord::Base
  has_many :branches, :dependent => :destroy
  has_many :code_objects, :dependent => :destroy

  belongs_to :default_branch, :class_name => 'Branch'

  has_many :builds, :through => :branches

  # TODO: implement another way
  def service_name
    uid.split(':').first
  end

  # TODO: implement another way
  def user_name
    uid.split(':').last.split('/').first
  end

  # TODO: implement another way
  def repo_name
    uid.split(':').last.split('/').last
  end

  validates :uid, :presence => true, :uniqueness => true
  validates :repo_url, :presence => true, :uniqueness => true
end
