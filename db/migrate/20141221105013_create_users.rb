class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :display_name
      t.string :user_name
      t.string :email

      t.timestamps
    end
  end
end
