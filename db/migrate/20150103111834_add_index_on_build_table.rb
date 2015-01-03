class AddIndexOnBuildTable < ActiveRecord::Migration
  def change
    add_index :builds, [:branch_id]
  end
end
