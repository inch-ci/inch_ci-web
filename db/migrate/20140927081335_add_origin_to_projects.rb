class AddOriginToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :origin, :string
  end
end
