class CreateCodeObjectReferences < ActiveRecord::Migration
  def change
    create_table :code_object_references do |t|
      t.references :revision
      t.references :code_object

      t.timestamps
    end
  end
end
