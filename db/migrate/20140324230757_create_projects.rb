class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :uid

      t.string :name
      t.string :description

      t.string :homepage_url
      t.string :source_code_url
      t.string :repo_url
      t.string :documentation_url

      t.references :default_branch

      t.timestamps
    end
    add_index :projects, :uid
  end
end
