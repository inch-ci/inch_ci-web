class AddBadgeFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :badge_generated, :boolean, :default => false
    add_column :projects, :badge_filled_in_percent, :integer
    add_column :projects, :badge_in_readme, :boolean, :default => false
    add_column :projects, :badge_in_readme_added_at, :datetime
    add_column :projects, :badge_in_readme_removed_at, :datetime
  end
end
