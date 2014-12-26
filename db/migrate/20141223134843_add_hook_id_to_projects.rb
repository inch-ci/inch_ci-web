class AddHookIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :github_hook_id, :integer
  end
end
