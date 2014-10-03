require 'inch_ci/project_uid'

class Project < ActiveRecord::Base
  UID_FORMAT = /\A([a-z0-9\-\_\.]+)\:([a-z0-9\-\_\.]+)\/([a-z0-9\-\_\.]+)\Z/i

  has_many :branches, :dependent => :destroy
  has_many :code_objects, :dependent => :destroy

  belongs_to :default_branch, :class_name => 'Branch'

  has_many :builds, :through => :branches

  # TODO: implement another way
  def service_name
    @service_name ||= InchCI::ProjectUID.new(uid).service
  end

  # TODO: implement another way
  def user_name
    @user_name ||= InchCI::ProjectUID.new(uid).user_name
  end

  # TODO: implement another way
  def repo_name
    @repo_name ||= InchCI::ProjectUID.new(uid).repo_name
  end

  validates :uid, :format => UID_FORMAT, :presence => true, :uniqueness => true
  validates :repo_url, :presence => true, :uniqueness => true
end
