class AddInchVersionToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :inch_version, :string
  end
end
