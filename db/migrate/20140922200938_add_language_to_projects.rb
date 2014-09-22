class AddLanguageToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :language, :string
  end
end
