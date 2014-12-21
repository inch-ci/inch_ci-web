class User < ActiveRecord::Base
  def projects
    Project.where('uid LIKE ?', "#{provider}/#{user_name}/%")
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

#  validates :provider, :uid, :name, :presence => true
end
