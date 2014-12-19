class AddIndexOnCodeObjectRoles < ActiveRecord::Migration
  def change
    add_index :code_object_roles, :code_object_id
  end
end
