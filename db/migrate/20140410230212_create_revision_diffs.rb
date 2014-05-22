class CreateRevisionDiffs < ActiveRecord::Migration
  def change
    create_table :revision_diffs do |t|
      t.references :branch

      t.references :before_revision
      t.references :after_revision

      t.timestamps
    end
  end
end
