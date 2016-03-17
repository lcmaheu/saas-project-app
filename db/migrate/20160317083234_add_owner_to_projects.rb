class AddOwnerToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :owner, :integer
    add_index :projects, :owner
  end
end
