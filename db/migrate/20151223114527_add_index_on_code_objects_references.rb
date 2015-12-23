class AddIndexOnCodeObjectsReferences < ActiveRecord::Migration
  def change
    add_index :code_object_references, [:revision_id]
  end
end
