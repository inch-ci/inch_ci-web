class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.references :project
      t.string :name

      t.references :latest_revision

      t.timestamps
    end
    add_index :branches, [:project_id, :name]
  end
end
