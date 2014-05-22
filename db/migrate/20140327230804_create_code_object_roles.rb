class CreateCodeObjectRoles < ActiveRecord::Migration
  def change
    create_table :code_object_roles do |t|
      t.references :code_object
      t.references :code_object_role_name

      t.string :ref_name

      t.integer :priority
      t.integer :score
      t.integer :potential_score
      t.integer :min_score
      t.integer :max_score

      t.timestamps
    end
  end
end
