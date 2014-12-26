class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :github_access_token
      t.string :display_name
      t.string :user_name
      t.string :email

      t.text :follows

      t.datetime :last_signin_at
      t.datetime :last_synced_projects_at

      t.timestamps
    end
  end
end
