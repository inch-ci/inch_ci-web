class User < ActiveRecord::Base
  serialize :follows

  def projects
    uid = InchCI::ProjectUID.new({
        :service => provider, :user => user_name, :repo => '%'
      })
    Project.includes(:default_branch).where('uid LIKE ?', uid.project_uid)
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.display_name = auth["info"]["name"]
      user.user_name = auth["info"]["nickname"]
      user.email = auth["info"]["email"]
    end
  end

  def self.find_or_create_with_omniauth(auth)
    find_with_omniauth(auth) || create_with_omniauth(auth)
  end

  def self.find_with_omniauth(auth)
    find_by_provider_and_uid(auth["provider"], auth["uid"])
  end

#  validates :provider, :uid, :name, :presence => true
end
