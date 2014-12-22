class AddMoreInfosToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :languages, :text
    add_column :projects, :fork, :boolean
  end
end
