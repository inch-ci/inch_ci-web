class CreateCodeObjects < ActiveRecord::Migration
  def change
    create_table :code_objects do |t|
      t.references :project

      t.string  :type
      t.text    :fullname
      t.text    :docstring
      t.integer :score
      t.string  :grade, :limit => 1
      t.integer :priority
      t.string  :location

      t.string  :digest, :limit => 28

      t.timestamps
    end
    add_index :code_objects, :digest
  end
end
