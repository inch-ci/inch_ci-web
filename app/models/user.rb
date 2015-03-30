class User < ActiveRecord::Base
  serialize :follows
  serialize :organizations

  def projects
    all_user_names = (organizations || []) + [user_name]
    uids = all_user_names.map do |username|
      uid = InchCI::ProjectUID.new({
          :service => provider, :user => username, :repo => '%'
        }).project_uid
    end
    like_condition = (['uid LIKE ?'] * uids.size).join(' OR ')
    Project.includes(:default_branch).where(like_condition, *uids)
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
