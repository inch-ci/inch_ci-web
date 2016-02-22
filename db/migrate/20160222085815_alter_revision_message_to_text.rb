class AlterRevisionMessageToText < ActiveRecord::Migration
  def change
    change_column :revisions, :message, :text
  end
end
