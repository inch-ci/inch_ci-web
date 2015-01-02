class AddIndexOnDiffTables < ActiveRecord::Migration
  def change
    add_index :revision_diffs, [:branch_id]
    add_index :code_object_diffs, [:revision_diff_id]
  end
end
