class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.references :branch
      t.references :revision
      t.datetime :started_at
      t.datetime :finished_at
      t.string :status
      t.string :trigger
      t.integer :number

      t.timestamps
    end
  end
end
