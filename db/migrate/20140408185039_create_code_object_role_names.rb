class CreateCodeObjectRoleNames < ActiveRecord::Migration
  def change
    create_table :code_object_role_names do |t|
      t.string :name
      t.timestamps
    end
  end
end
