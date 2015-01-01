class AddHookActiveToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :github_hook_active, :boolean, :default => false
  end
end
