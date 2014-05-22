class CreateCodeObjectDiffs < ActiveRecord::Migration
  def change
    create_table :code_object_diffs do |t|
      t.references :revision_diff

      t.references :before_object
      t.references :after_object

      t.string :change

      t.timestamps
    end
  end
end
