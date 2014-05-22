class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.references :branch

      t.string :uid
      t.string :tag_uid

      t.string :message
      t.string :author_name
      t.string :author_email
      t.datetime :authored_at

      t.timestamps
    end
  end
end
