class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.datetime  :date
      t.string    :name
      t.integer   :value
      t.timestamps
    end
  end
end
