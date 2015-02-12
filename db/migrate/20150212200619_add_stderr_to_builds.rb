class AddStderrToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :stderr, :text
  end
end
