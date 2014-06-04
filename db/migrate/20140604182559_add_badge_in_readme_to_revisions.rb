class AddBadgeInReadmeToRevisions < ActiveRecord::Migration
  def change
    add_column :revisions, :badge_in_readme, :boolean, :default => false
  end
end
