class AddIndexOnCodeObjectReferences < ActiveRecord::Migration
  def change
    add_index :code_object_references, [:code_object_id, :revision_id], unique: true
  end
end
